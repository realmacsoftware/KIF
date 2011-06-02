//
//  KIFTestController.m
//  KIF
//
//  Created by Michael Thole on 5/20/11.
//  Copyright 2011 Square, Inc. All rights reserved.
//

#import "KIFTestController.h"
#import "KIFTestScenario.h"
#import "KIFTestStep.h"
#import "NSFileManager-KIFAdditions.h"
#import <QuartzCore/QuartzCore.h>


@interface KIFTestController ()

@property (nonatomic, retain) KIFTestScenario *currentScenario;
@property (nonatomic, retain) KIFTestStep *currentStep;
@property (nonatomic, retain) NSArray *scenarios;
@property (nonatomic, getter=isTesting) BOOL testing;
@property (nonatomic, retain) NSDate *currentScenarioStartDate;
@property (nonatomic, retain) NSDate *currentStepStartDate;
@property (nonatomic, copy) KIFTestControllerCompletionBlock completionBlock;

- (void)_initializeScenariosIfNeeded;
- (void)_scheduleCurrentTestStep;
- (void)_performTestStep:(KIFTestStep *)step;
- (void)_advanceWithResult:(KIFTestStepResult)result error:(NSError*) error;
- (KIFTestStep *)_nextStep;
- (KIFTestScenario *)_nextScenario;
- (void)_writeScreenshotForStep:(KIFTestStep *)step;
- (void)_logTestingDidStart;
- (void)_logTestingDidFinish;
- (void)_logDidStartScenario:(KIFTestScenario *)scenario;
- (void)_logDidFinishScenario:(KIFTestScenario *)scenario duration:(NSTimeInterval)duration;
- (void)_logDidFailStep:(KIFTestStep *)step duration:(NSTimeInterval)duration error:(NSError *)error;
- (void)_logDidPassStep:(KIFTestStep *)step duration:(NSTimeInterval)duration;

@end


@implementation KIFTestController

@synthesize scenarios;
@synthesize testing;
@synthesize failureCount;
@synthesize currentScenario;
@synthesize currentStep;
@synthesize currentScenarioStartDate;
@synthesize currentStepStartDate;
@synthesize completionBlock;

#pragma mark Static Methods

static KIFTestController *sharedInstance = nil;

static void releaseInstance()
{
    [sharedInstance release];
    sharedInstance = nil;
}

+ (id)sharedInstance;
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        atexit(releaseInstance);
    });
    
    return sharedInstance;
}

#pragma mark Initialization Methods

- (id)init;
{
    NSAssert(!sharedInstance, @"KIFTestController should not be initialized manually. Use +sharedInstance instead.");
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)dealloc;
{
    self.scenarios = nil;
    self.currentScenarioStartDate = nil;
    self.currentStepStartDate = nil;
    
    [super dealloc];
}

#pragma mark Public Methods

- (void)initializeScenarios;
{
    // For subclassers
}

- (NSArray *)scenarios
{
    [self _initializeScenariosIfNeeded];
    return scenarios;
}

- (void)addScenario:(KIFTestScenario *)scenario;
{
    NSAssert(![self.scenarios containsObject:scenario], @"The scenario %@ is already added", scenario);
    NSAssert(scenario.description.length, @"Cannot add a scenario that does not have a description");
    
    [self _initializeScenariosIfNeeded];
    [scenarios addObject:scenario];
}

- (void)startTestingWithCompletionBlock:(KIFTestControllerCompletionBlock)inCompletionBlock
{
    NSAssert(!self.testing, @"Testing is already in progress");
    
    self.testing = YES;
    self.currentScenario = (self.scenarios.count ? [self.scenarios objectAtIndex:0] : nil);
    self.currentScenarioStartDate = [NSDate date];
    self.currentStep = (self.currentScenario.steps.count ? [self.currentScenario.steps objectAtIndex:0] : nil);
    self.currentStepStartDate = [NSDate date];
    self.completionBlock = inCompletionBlock;
    
    [self _logTestingDidStart];
    [self _logDidStartScenario:self.currentScenario];
    
    [self _scheduleCurrentTestStep];
}

- (void)_testingDidFinish
{
    [self _logTestingDidFinish];
    self.testing = NO;
    self.completionBlock();
}

#pragma mark Private Methods

- (void)_initializeScenariosIfNeeded
{
    if (!scenarios) {
        self.scenarios = [NSMutableArray array];
        [self initializeScenarios];
    }
}

- (void)_scheduleCurrentTestStep;
{
    [self performSelector:@selector(_delayedScheduleCurrentTestStep) withObject:nil afterDelay:0.01f];
}

- (void)_delayedScheduleCurrentTestStep;
{
    [self _performTestStep:self.currentStep];
}

- (void)_performTestStep:(KIFTestStep *)step;
{
    NSError *error = nil;
    
    KIFTestStepResult result = [step executeAndReturnError:&error];
    
    [self _advanceWithResult:result error:error];
    
    if (self.currentStep) {
        [self _scheduleCurrentTestStep];
    } else {
        [self _testingDidFinish];
    }
}

- (void)_advanceWithResult:(KIFTestStepResult)result error:(NSError *)error;
{
    NSAssert((!self.currentStep || result == KIFTestStepResultSuccess || error), @"The step \"%@\" returned a non-successful result but did not include an error", self.currentStep.description);
    
    KIFTestStep *previousStep = self.currentStep;
    NSTimeInterval currentStepDuration = -[self.currentStepStartDate timeIntervalSinceNow];
    
    switch (result) {
        case KIFTestStepResultFailure: {
            [self _logDidFailStep:self.currentStep duration:currentStepDuration error:error];
            [self _writeScreenshotForStep:self.currentStep];
            
            self.currentScenario = [self _nextScenario];
            self.currentScenarioStartDate = [NSDate date];
            self.currentStep = (self.currentScenario.steps.count ? [self.currentScenario.steps objectAtIndex:0] : nil);
            self.currentStepStartDate = [NSDate date];
            if (error) {
                NSLog(@"The step \"%@\" failed: %@", self.currentStep, [error description]);
            }
            failureCount++;
            break;
        }
        case KIFTestStepResultSuccess: {
            [self _logDidPassStep:self.currentStep duration:currentStepDuration];
            self.currentStep = [self _nextStep];
            if (!self.currentStep) {
                self.currentScenario = [self _nextScenario];
                self.currentScenarioStartDate = [NSDate date];
                self.currentStep = (self.currentScenario.steps.count ? [self.currentScenario.steps objectAtIndex:0] : nil);
            }
            self.currentStepStartDate = [NSDate date];
            break;
        }
        case KIFTestStepResultWait: {
            // Don't do anything; the current step will be scheduled for execution again.
            // If there's a timeout, then fail.
            if (currentStepDuration > self.currentStep.timeout) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:error, NSUnderlyingErrorKey, [NSString stringWithFormat:@"The step timed out after %.2f seconds.", self.currentStep.timeout], NSLocalizedDescriptionKey, nil];
                error = [NSError errorWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:userInfo];
                [self _advanceWithResult:KIFTestStepResultFailure error:error];
            }
            break;
        }
    }
    
    NSAssert(!self.currentStep || self.currentStep.description.length, @"The step following the step \"%@\" is missing a description", previousStep.description);
}

- (KIFTestStep *)_nextStep;
{
    NSArray *steps = self.currentScenario.steps;
    NSUInteger currentStepIndex = [steps indexOfObjectIdenticalTo:self.currentStep];
    NSAssert(currentStepIndex != NSNotFound, @"Current step %@ not found in current scenario %@, but should be!", self.currentStep, self.currentScenario);
    
    NSUInteger nextStepIndex = currentStepIndex + 1;
    KIFTestStep *nextStep = nil;
    if ([steps count] > nextStepIndex) {
        nextStep = [steps objectAtIndex:nextStepIndex];
    }
    
    return nextStep;
}

- (KIFTestScenario *)_nextScenario;
{
    if (self.currentScenario) {
        [self _logDidFinishScenario:self.currentScenario duration:-[self.currentScenarioStartDate timeIntervalSinceNow]];
    }
    
    NSUInteger currentScenarioIndex = [self.scenarios indexOfObjectIdenticalTo:self.currentScenario];
    NSAssert(currentScenarioIndex != NSNotFound, @"Current scenario %@ not found in test scenarios %@, but should be!", self.currentScenario, self.scenarios);
    
    NSUInteger nextScenarioIndex = currentScenarioIndex + 1;
    KIFTestScenario *nextScenario = nil;
    if ([self.scenarios count] > nextScenarioIndex) {
        nextScenario = [self.scenarios objectAtIndex:nextScenarioIndex];
    }
    
    if (nextScenario) {
        [self _logDidStartScenario:nextScenario];
    }
    
    return nextScenario;
}

- (void)_writeScreenshotForStep:(KIFTestStep *)step;
{
    char *path = getenv("KIF_SCREENSHOTS");
    if (!path) {
        return;
    }
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *outputPath = [fileManager stringWithFileSystemRepresentation:path length:strlen(path)];
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    if (windows.count == 0) {
        return;
    }
    
    UIGraphicsBeginImageContext([[windows objectAtIndex:0] bounds].size);
    for (UIWindow *window in windows) {
        [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    outputPath = [outputPath stringByExpandingTildeInPath];
    outputPath = [outputPath stringByAppendingPathComponent:[step.description stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    outputPath = [outputPath stringByAppendingPathExtension:@"png"];
    [UIImagePNGRepresentation(image) writeToFile:outputPath atomically:YES];
    [fileManager release];
}

#pragma mark Logging

#define KIFLog(...) [[self _logFileHandleForWriting] writeData:[[NSString stringWithFormat:@"%@\n", [NSString stringWithFormat:__VA_ARGS__]] dataUsingEncoding:NSUTF8StringEncoding]]; NSLog(__VA_ARGS__);
#define KIFLogBlankLine() KIFLog(@" ");
#define KIFLogSeparator() KIFLog(@"---------------------------------------------------");

- (NSFileHandle *)_logFileHandleForWriting;
{
    static NSFileHandle *fileHandle = nil;
    if (!fileHandle) {
        NSString *logsDirectory = [[NSFileManager defaultManager] createUserDirectory:NSLibraryDirectory];
        
        if (logsDirectory) {
            logsDirectory = [logsDirectory stringByAppendingPathComponent:@"Logs"];
        }
        if (![[NSFileManager defaultManager] recursivelyCreateDirectory:logsDirectory]) {
            logsDirectory = nil;
        }
        
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterLongStyle];
        dateString = [dateString stringByReplacingOccurrencesOfString:@"/" withString:@"."];
        dateString = [dateString stringByReplacingOccurrencesOfString:@":" withString:@"."];
        NSString *fileName = [NSString stringWithFormat:@"KIF Tests %@.log", dateString];
        
        NSString *logFilePath = [logsDirectory stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:logFilePath]) {
            [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:[NSData data] attributes:nil];
        }
        
        fileHandle = [[NSFileHandle fileHandleForWritingAtPath:logFilePath] retain];
        
        if (fileHandle) {
            NSLog(@"Logging KIF test activity to %@", logFilePath);
        }
    }
    
    return fileHandle;
}

- (void)_logTestingDidStart;
{
    KIFLog(@"BEGIN KIF TEST RUN: %d scenarios", self.scenarios.count);
}

- (void)_logTestingDidFinish;
{
    KIFLogBlankLine();
    KIFLogSeparator();
    KIFLog(@"KIF TEST RUN FINISHED: %d failures", failureCount);
    KIFLogSeparator();
    
    // Also log the failure count to stdout, for easier integration with CI tools.
    NSLog(@"*** KIF TESTING FINISHED: %d failures", failureCount);
}

- (void)_logDidStartScenario:(KIFTestScenario *)scenario;
{
    KIFLogBlankLine();
    KIFLogSeparator();
    KIFLog(@"BEGIN SCENARIO %d/%d (%d steps)", [self.scenarios indexOfObjectIdenticalTo:scenario] + 1, self.scenarios.count, scenario.steps.count);
    KIFLog(@"%@", scenario.description);
    KIFLogSeparator();
}

- (void)_logDidFinishScenario:(KIFTestScenario *)scenario duration:(NSTimeInterval)duration
{
    KIFLogSeparator();
    KIFLog(@"END OF SCENARIO (duration %.2fs)", duration);
    KIFLogSeparator();
}

- (void)_logDidFailStep:(KIFTestStep *)step duration:(NSTimeInterval)duration error:(NSError *)error;
{
    KIFLog(@"FAIL (%.2fs): %@", duration, step);
    KIFLog(@"FAILING ERROR: %@", error);
}

- (void)_logDidPassStep:(KIFTestStep *)step duration:(NSTimeInterval)duration;
{
    KIFLog(@"PASS (%.2fs): %@", duration, step);
}

@end