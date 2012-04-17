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

+ (id)stepToWaitForFocusedWindowWithTitle:(NSString*)title {
	NSString *description = [NSString stringWithFormat:@"Wait for window with accessibility title \"%@\"", title];
	
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [KIFApplication currentApplication].focusedWindow;
		BOOL waitCondition = (element != nil && [[element title] isEqualToString:title]); 

        KIFTestWaitCondition(waitCondition, error, @"Waiting for presence of focused window with title \"%@\"", title);
		
		return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToWaitForFocusedWindowWithAccessibilityIdentifier:(NSString*)identifier {
	NSString *description = [NSString stringWithFormat:@"Wait for window with accessibility identifier \"%@\"", identifier];
	
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [KIFApplication currentApplication].focusedWindow;
		BOOL waitCondition = (element != nil && [[element identifier] isEqualToString:identifier]); 
		
        KIFTestWaitCondition(waitCondition, error, @"Waiting for presence of focused window with identifier \"%@\"", identifier);
		
		return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToFocusOnViewWithAccessibilityIdentifier:(NSString*)identifier {
	NSString *description = [NSString stringWithFormat:@"Set focus on view with accessibility identifier \"%@\"", identifier];
	
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [KIFApplication currentApplication].focusedWindow;

		KIFElement *view = [element childWithIdentifier:identifier];
		
		KIFTestCondition([[view attributes] containsObject:NSAccessibilityFocusedAttribute], error, @"view with identifier \"%@\" does not have a focussed attribute", identifier);
				
		BOOL focussed = [view setValue:kCFBooleanTrue forAttribute:NSAccessibilityFocusedAttribute];
		
        KIFTestCondition((view != nil && focussed), error, @"Error setting focus on view with identifier \"%@\"", identifier);
		
		return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToTypeText:(NSString*)text inViewWithAccessibilityIdentifier:(NSString*)identifier {
	NSString *description = [NSString stringWithFormat:@"Type text in view with accessibility identifier \"%@\"", identifier];
	
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [KIFApplication currentApplication].focusedWindow;
		
		KIFElement *view = [element childWithIdentifier:identifier];
		
		KIFTestCondition([[view role] isEqualToString:NSAccessibilityTextFieldRole] || [[view role] isEqualToString:NSAccessibilityTextAreaRole], error, @"View with identifier \"%@\" is not a text field or text view", identifier);
		
		BOOL result = [view typeText:text];
		
        KIFTestCondition((view != nil && result), error, @"Error typing text in view with identifier \"%@\"", identifier);
		
		return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToWaitForViewInSheetWithAccessibilityIdentifier:(NSString *)identifier {
	NSString *description = [NSString stringWithFormat:@"Wait for view in sheet with accessibility identifier \"%@\"", identifier];
	
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step childOfSheetWithIdentifier:identifier error:error];
		
		KIFTestWaitCondition(element, error, @"Waiting for view in sheet with accesibility identifier \"%@\"", identifier);
		
		return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToWaitForSheetWithAccessibilityIdentifier:(NSString*)identifier {
	NSString *description = [NSString stringWithFormat:@"Wait for sheet with accessibility identifier \"%@\"", identifier];
	
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [KIFApplication currentApplication].focusedWindow;
		BOOL waitCondition = (element != nil && [[[element childWithRole:NSAccessibilitySheetRole] identifier] isEqualToString:identifier]); 
		
        KIFTestWaitCondition(waitCondition, error, @"Waiting for presence of sheet with identifier \"%@\"", identifier);
		
		return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToSelectCellInViewWithAccessibilityIdentifier:(NSString*)identifier cellTitle:(NSString*)title {
	NSString *description = [NSString stringWithFormat:@"Select cell with title \"%@\" in view with accessibility identifier \"%@\"", title, identifier];
	
	return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		//KIFElement *element = [step elementWithIdentifier:identifier error:error];
		
		// TODO: NOT YET IMPLEMENTED!
		
		//KIFTestWaitCondition(element, error, @"Waiting for view with accesibility identifier \"%@\"", identifier);
		
		return KIFTestStepResultFailure;
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

+ (id)stepToClickRowAtIndex:(NSUInteger)index inTableViewWithAccessibilityIdentifier:(NSString*)identifier {
	NSString *description = [NSString stringWithFormat:@"Click row with index %lu in table view with accessibility identifier \"%@\"", index, identifier];

	return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step elementWithIdentifier:identifier error:error];
		
		KIFTestCondition(element, error, @"Failed to locate view to click with accessibility identifier \"%@\"", identifier);
		
		KIFTestCondition([[element role] isEqualToString:NSAccessibilityTableRole] || [[element role] isEqualToString:NSAccessibilityOutlineRole], error, @"view with accessibility identifier \"%@\" is not a Table or Outline", identifier);

		KIFElement* child = [element childWithIndex:index];
		
		KIFTestCondition(child, error, @"view with identifier \"%@\" has no child at index %lu", identifier, index);
		
		BOOL selected = [child selectElement];
		
		KIFTestCondition(selected, error, @"failed to select child at index %lu of view with identifier \"%@\"", index, identifier);
	
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, false);
	
		return KIFTestStepResultSuccess;
	}];
}

+ (id)stepToClickRowWithTitle:(NSString*)title inTableViewWithAccessibilityIdentifier:(NSString*)identifier {
	NSString *description = [NSString stringWithFormat:@"Click row with title %@ in table view with accessibility identifier \"%@\"", title, identifier];
	
	return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step elementWithIdentifier:identifier error:error];
		
		KIFTestCondition(element, error, @"Failed to locate view to click with accessibility identifier \"%@\"", identifier);
		
		KIFElement* child = [element childWithTitle:title];
		
		KIFTestCondition(child, error, @"view with identifier \"%@\" has no child with title \"%@\"", identifier, title);
		
		// The Child is the cell, but we want to select the row
		
		KIFElement* row = [child parent];
				
		[row selectElement];
		
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, false);
		
		return KIFTestStepResultSuccess;
	}];
}

+ (id)stepToDoubleClickCellAtIndex:(NSUInteger)cellIndex inCollectionViewWithAccessibilityIdentifier:(NSString*)identifier {
	NSString *description = [NSString stringWithFormat:@"Double click cell at index %lu in collection view with accessibility identifier \"%@\"", cellIndex, identifier];
	
	return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step elementWithIdentifier:identifier error:error];
		
		KIFTestCondition(element, error, @"Failed to locate collection view with accessibility identifier \"%@\"", identifier);
		
		KIFTestCondition([[element role] isEqualToString:NSAccessibilityGridRole], error, @"Accessibility element with identifier \"%@\" is not a collection view", identifier);
		
		KIFElement *child = [element childWithIndex:cellIndex];
		
		KIFTestCondition(child, error, @"Accessibility element with identifier \"%@\" does not have a child with index %lu", cellIndex);

		BOOL success = [child performPressAction];
						
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, false);
		
		KIFTestCondition(success, error, @"Failed to double click cell at index %lu with accesibility identifier \"%@\"", cellIndex, identifier);
		
		return KIFTestStepResultSuccess;
	}];
}

+ (id)stepToCheckCollectionViewWithIdentifier:(NSString*)identifier hasNumberOfCells:(NSUInteger)numberOfCells {
	NSString *description = [NSString stringWithFormat:@"Check collection view with accessibility identifier \"%@\" has %lu cells", identifier, numberOfCells];
	
	return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		KIFElement *element = [step elementWithIdentifier:identifier error:error];
		
		KIFTestCondition(element, error, @"Failed to locate collection view with accessibility identifier \"%@\"", identifier);
		
		NSUInteger childrenCount = [element numberOfChildren];
		
		KIFTestCondition(childrenCount == numberOfCells, error, @"view with identifier \"%@\" has has %lu children, expecting %lu children", identifier, childrenCount, numberOfCells);
				
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

+ (id)stepToClickMenuItemWithTitle:(NSString*)title inMenuWithTitle:(NSString*)menuTitle {
	NSString *description = [NSString stringWithFormat:@"Click menu item with title \"%@\"", title];
    
    return [self stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError **error) {
		
		KIFElement *menu = [step menuWithTitle:menuTitle error:error];
		
		KIFTestCondition(menu, error, @"Failed to locate menu to click with title \"%@\"", title);

		KIFElement *element = [menu childWithTitle:title];
						
		KIFTestCondition(element, error, @"Failed to locate menu item to click with title \"%@\"", title);
		
		[element performPressAction];
		
		CFRunLoopRunInMode(kCFRunLoopCommonModes, 0.5, false);

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

- (KIFElement*)childOfSheetWithIdentifier:(NSString*)identifier error:(NSError **)error {
	KIFElement *element = [[KIFApplication currentApplication].focusedWindow childWithIdentifier:identifier];
	KIFElement *sheet = [element childWithRole:NSAccessibilitySheetRole];
	
	if (sheet == nil && error != NULL) {
		*error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Failed to find sheet for focussed window", NSLocalizedDescriptionKey, nil]] autorelease];

		return  nil;
	}
	KIFElement* child = [sheet childWithIdentifier:identifier];
	
	if(child == nil && error != NULL) {
		*error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to find accessibility element with the identifier \"%@\"", identifier], NSLocalizedDescriptionKey, nil]] autorelease];
	}
	return child;
}

- (KIFElement *)elementWithTitle:(NSString *)title error:(NSError **)error {
	KIFElement *element = [[KIFApplication currentApplication].focusedWindow childWithTitle:title];
	if(element == nil && error != NULL) {
		*error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to find accessibility element with the title \"%@\"", title], NSLocalizedDescriptionKey, nil]] autorelease];
	}
	
	return element;
}

- (KIFElement *)menuWithTitle:(NSString *)title error:(NSError **)error {
	KIFElement *element = [[KIFApplication currentApplication].menuBar immediateChildWithTitle:title];
	if (element == nil && error != NULL) {
		*error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to find accessibility element with the title \"%@\"", title], NSLocalizedDescriptionKey, nil]] autorelease];
	}
	return element;
}

@end
