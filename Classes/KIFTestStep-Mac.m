//
//  KIFTestStep-Mac.m
//  KIF
//
//  Created by Josh Abernathy on 7/23/11.
//  Copyright 2011 Maybe Apps, LLC. All rights reserved.
//

#import "KIFTestStep-Mac.h"
#import "KIFApplication.h"


@implementation KIFTestStep (Mac)

+ (id)stepToWaitForFocusedWindowWithAccessibilityTitle:(NSString*)title {
	NSString *description = [NSString stringWithFormat:@"Wait for window with accessibility title \"%@\"", title];
	
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [KIFApplication currentApplication].focusedWindow;
		BOOL waitCondition = (element != nil && [[element title] isEqualToString:title]); 

        KIFTestWaitCondition(waitCondition, error, @"Waiting for presence of focused window with title \"%@\"", title);
		
		return KIFTestStepResultSuccess;
    }];

}

+ (id)stepToWaitForViewWithAccessibilityIdentifier:(NSString *)identifier {
	NSString *description = [NSString stringWithFormat:@"Wait for view with accessibility identifier \"%@\"", identifier];
        
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step elementWithIdentifier:identifier error:error];
		
		KIFTestWaitCondition(element, error, @"Waiting for view with accesibility identifier \"%@\"", identifier);

		return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToClickViewWithAccessibilityIdentifier:(NSString *)identifier {
	NSString *description = [NSString stringWithFormat:@"Click view with accessibility identifier \"%@\"", identifier];
    
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step elementWithIdentifier:identifier error:error];

        KIFTestCondition(element, error, @"Failed to locate view to click with accessibility identifier \"%@\"", identifier);
		
        [element performPressAction];
		
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, false);
        
        return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToWaitForViewWithTitle:(NSString *)title {
	NSString *description = [NSString stringWithFormat:@"Wait for view with title \"%@\"", title];
	
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step elementWithTitle:title error:error];
		
		KIFTestWaitCondition(element, error, @"Waiting for view with title \"%@\"", title);
		
		return (element ? KIFTestStepResultSuccess : KIFTestStepResultWait);
    }];
}

+ (id)stepToClickViewWithTitle:(NSString *)title {
	NSString *description = [NSString stringWithFormat:@"Click view with title \"%@\"", title];
    
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step elementWithTitle:title error:error];
       
		KIFTestCondition(element, error, @"Failed to locate view to click with title \"%@\"", title);
        
        [element performPressAction];
		
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, false);
        
        return KIFTestStepResultSuccess;
    }];
}

- (KIFElement *)elementWithIdentifier:(NSString *)identifier error:(NSError **)error {
	KIFElement *element = [[KIFApplication currentApplication].focusedWindow childWithIdentifier:identifier];
	if(element == nil && error != NULL) {
		*error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to find accessibility element with the identifier \"%@\"", identifier], NSLocalizedDescriptionKey, nil]] autorelease];
	}
	
	return element;
}

- (KIFElement *)elementWithTitle:(NSString *)title error:(NSError **)error {
	KIFElement *element = [[KIFApplication currentApplication].focusedWindow childWithTitle:title];
	if(element == nil && error != NULL) {
		*error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to find accessibility element with the title \"%@\"", title], NSLocalizedDescriptionKey, nil]] autorelease];
	}
	
	return element;
}

@end
