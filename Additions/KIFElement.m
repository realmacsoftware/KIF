//
//  KIFElement.m
//
//  Created by Josh Abernathy on 7/16/11.
//  Copyright 2011 Maybe Apps, LLC. All rights reserved.
//

#import "KIFElement.h"
#import "KIFElement-Private.h"

#import "KIFApplication.h"

@interface KIFElement ()
@property (nonatomic, assign) AXUIElementRef elementRef;
@end


@implementation KIFElement {
	NSPointerArray* _cachedChildren;
}

- (void)dealloc {
	if(self.elementRef != NULL) {
		CFRelease(self.elementRef);
		self.elementRef = NULL;
	}
	
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p> identifier: %@, title %@, role: %@, subrole: %@, titleUIElement: %@ actions: %@", NSStringFromClass([self class]), self, self.identifier, self.title, self.role, self.subrole, self.titleUIElement, self.actions];
}


#pragma mark API

@synthesize elementRef;

+ (KIFElement *)elementWithElementRef:(AXUIElementRef)elementRef {
	return [[[self alloc] initWithElementRef:elementRef] autorelease];
}

- (id)initWithElementRef:(AXUIElementRef)ref {
	NSParameterAssert(ref != NULL);
	
	self = [super init];
	if(self == nil) return nil;
	
	self.elementRef = CFRetain(ref);
	
	return self;
}

- (KIFElement *)childWithIdentifier:(NSString *)identifier {
	NSMutableArray *parentsToInvestigate = [NSMutableArray array];
	[parentsToInvestigate addObject:self];
	
	while(parentsToInvestigate.count > 0) {
		NSMutableArray *nextSetOfParents = [NSMutableArray array];
		for(KIFElement *parent in parentsToInvestigate) {
			KIFElement *match = [parent immediateChildWithIdentifier:identifier];
			if(match != nil) {
				return match;
			} else {
				[nextSetOfParents addObjectsFromArray:parent.children];
			}
		}
		parentsToInvestigate = nextSetOfParents;
	}
	
	return nil;
}

- (KIFElement *)immediateChildWithIdentifier:(NSString *)identifier {
	for(KIFElement *child in self.children) {
		if([child.identifier isEqualToString:identifier]) {
			return child;
		}
	}
	
	return nil;
}

- (KIFElement *)childWithTitle:(NSString *)title {
	NSMutableArray *parentsToInvestigate = [NSMutableArray array];
	[parentsToInvestigate addObject:self];
	
	while(parentsToInvestigate.count > 0) {
		NSMutableArray *nextSetOfParents = [NSMutableArray array];
		for(KIFElement *parent in parentsToInvestigate) {
			KIFElement *match = [parent immediateChildWithTitle:title];
			if(match != nil) {
				return match;
			} else {
				[nextSetOfParents addObjectsFromArray:parent.children];
			}
		}
		parentsToInvestigate = nextSetOfParents;
	}
	
	return nil;
}

- (KIFElement *)immediateChildWithTitle:(NSString *)title {
	for(KIFElement *child in self.children) {
		if ([child.title isEqualToString:title]) {
			return child;
		}
		// also check for a AXTitleUIElement linkage
		if (child.titleUIElement != nil && [child.titleUIElement.value isEqualToString:title]) {
			return child;
		}
	}
	
	return nil;
}

- (KIFElement *)childWithIndex:(NSUInteger)index {
	CFArrayRef arrayRef = NULL;
	AXError error = AXUIElementCopyAttributeValues(self.elementRef, (CFStringRef)NSAccessibilityChildrenAttribute, index, 1, &arrayRef);

	if (error != kAXErrorSuccess) {
		NSLog(@"error %d, getting children for element with identifier %@", error, self.identifier);
		return nil;
	}
	
	if (arrayRef == NULL || CFArrayGetCount(arrayRef) != 1) {
		if (arrayRef != NULL) {
			CFRelease(arrayRef);
		}
		return nil;
	} else {
		if (_cachedChildren == nil) {
			_cachedChildren = [NSPointerArray pointerArrayWithStrongObjects];
			[_cachedChildren setCount:[self numberOfChildren]];
		}
		
		[_cachedChildren replacePointerAtIndex:index withPointer:[KIFElement elementWithElementRef:CFArrayGetValueAtIndex(arrayRef, 0)]];
		
		CFRelease(arrayRef);
		
		return [_cachedChildren pointerAtIndex:index];
	}
}

- (KIFElement *)childWithRole:(NSString*)role {
	for(KIFElement *child in self.children) {
		if ([child.role isEqualToString:role]) {
			return child;
		}
	}
	return nil;
}

- (KIFElement *)childWithPath:(NSString *)identifierPath {
	NSArray *elementIdentifiers = [identifierPath componentsSeparatedByString:@"/"];
	KIFElement *currentElement = self;
	for(NSString *identifier in elementIdentifiers) {
		currentElement = [currentElement immediateChildWithIdentifier:identifier];
		if(currentElement == nil) break;
	}
	return nil;
}

- (BOOL)performAction:(NSString*)action {	
	AXError error = AXUIElementPerformAction(self.elementRef, (CFStringRef)action);
	if (error != kAXErrorSuccess) {
		NSLog(@"failed to perform action %@ for element %@ with error code %d", action, self, error);
		return NO;
	}
	return YES;
}

- (BOOL)performPressAction {
	return [self performAction:NSAccessibilityPressAction];
}

- (BOOL)performCancelAction {
	return [self performAction:NSAccessibilityCancelAction];
}

- (void)stopMenuTracking {
	[[KIFApplication currentApplication].menuBar performCancelAction];
}

- (BOOL)typeText:(NSString*)string {
	return [self setValue:(CFStringRef)string forAttribute:NSAccessibilityValueAttribute];
}

- (BOOL)setValue:(CFTypeRef)value forAttribute:(NSString*)attribute {
	AXError error = AXUIElementSetAttributeValue(self.elementRef, (CFStringRef)attribute, value);
	if (error != kAXErrorSuccess) {
		NSLog(@"Unable to select element %@ with error code %d", self, error);
		return NO;
	}
	return YES;
}

- (BOOL)selectElement {
	return [self setValue:kCFBooleanTrue forAttribute:NSAccessibilitySelectedAttribute];
}

- (KIFElement *)window {
	return [self wrappedAttributeForKey:NSAccessibilityWindowAttribute];
}

- (KIFElement *)topLevelUIElement {
	return [self wrappedAttributeForKey:NSAccessibilityTopLevelUIElementAttribute];
}

- (NSArray *)children {
	return [self wrappedAttributeForKey:NSAccessibilityChildrenAttribute];
}

- (NSInteger)numberOfChildren {
	CFIndex count = 0;
	AXUIElementGetAttributeValueCount(self.elementRef, (CFStringRef)NSAccessibilityChildrenAttribute, &count);
	
	return count;
}

- (KIFElement *)parent {
	return [self wrappedAttributeForKey:NSAccessibilityParentAttribute];
}

- (NSString *)role {
	return (NSString *) [self attributeForKey:NSAccessibilityRoleAttribute];
}

- (NSString *)subrole {
	return (NSString *) [self attributeForKey:NSAccessibilitySubroleAttribute];
}

- (NSString *)identifier {
	return (NSString *) [self attributeForKey:NSAccessibilityIdentifierAttribute];
}

- (NSString *)title {
	return (NSString *) [self attributeForKey:NSAccessibilityTitleAttribute];
}

- (NSString *)value {
	return (NSString *) [self attributeForKey:NSAccessibilityValueAttribute];
}

- (NSUInteger)index {
	return [(NSNumber*)[self attributeForKey:NSAccessibilityIndexAttribute] unsignedIntegerValue];
}

- (KIFElement*)titleUIElement {
	return [self wrappedAttributeForKey:NSAccessibilityTitleUIElementAttribute];
}

- (NSArray*)actions {
	NSArray* actionNames = nil;
	AXError error = AXUIElementCopyActionNames(self.elementRef, (CFArrayRef*)&actionNames);

	if (error == kAXErrorSuccess) {
		return [actionNames autorelease];
	}
	return nil;
}

- (NSArray*)attributes {
	NSArray* attributeNames = nil;
	AXError error = AXUIElementCopyAttributeNames(self.elementRef, (CFArrayRef*)&attributeNames);
	
	if (error == kAXErrorSuccess) {
		return [attributeNames autorelease];
	}
	return nil;
}

- (NSRect)frame {
	NSPoint origin = [(NSValue *) [self attributeForKey:NSAccessibilityPositionAttribute] pointValue];
	NSSize size = [(NSValue *) [self attributeForKey:NSAccessibilitySizeAttribute] sizeValue];
	return NSMakeRect(origin.x, origin.y, size.width, size.height);
}

@end
