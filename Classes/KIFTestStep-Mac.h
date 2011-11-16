//
//  KIFTestStep-Mac.h
//  KIF
//
//  Created by Josh Abernathy on 7/23/11.
//  Copyright 2011 Maybe Apps, LLC. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "KIFTestStep.h"

@class KIFElement;


@interface KIFTestStep (Mac)

/*!
 @method stepToWaitForFocusedWindowWithAccessibilityIdentifier:
 @abstract A step that waits until a window with the provided identifier becomes the focused (key) window
 @discussion The current focused window is examined for a match with the given identifier.  If it doesn't match, then the step will attempt to wait until it is.
 
 @param identifier The accessibility identifier of the window to wait for.
 @result A configured test step.
 */
+ (id)stepToWaitForFocusedWindowWithAccessibilityTitle:(NSString*)title;

/*!
 @method stepToWaitForViewWithAccessibilityIdentifier:
 @abstract A step that waits until a view or accessibility element is present.
 @discussion The view or accessibility element with the given identifier is found in the view heirarchy. If the element isn't found, then the step will attempt to wait until it is. Note that the view does not necessarily have to be visible on the screen, and may be behind another view or offscreen. Views with their hidden property set to YES are ignored.
 
 @param identifier The accessibility identifier of the element to wait for.
 @result A configured test step.
 */
+ (id)stepToWaitForViewWithAccessibilityIdentifier:(NSString *)identifier;

/*!
 @method stepToClickViewWithAccessibilityIdentifier:
 @abstract A step that clicks a particular view in the view hierarchy.
 @discussion The view or accessibility element with the given identifier is searched for in the view hierarchy. If the element isn't found or isn't currently clickable, then the step will attempt to wait until it is. Once the view is present and clickable, a click event is simulated in the center of the view or element.
 @param label The accessibility identifier of the element to click.
 @result A configured test step.
 */
+ (id)stepToClickViewWithAccessibilityIdentifier:(NSString *)identifier;

/*!
 @method stepToWaitForViewWithTitle:
 @abstract A step that waits until a view or accessibility element is present.
 @discussion The view or accessibility element with the given title is found in the view heirarchy. If the element isn't found, then the step will attempt to wait until it is. Note that the view does not necessarily have to be visible on the screen, and may be behind another view or offscreen. Views with their hidden property set to YES are ignored.
 
 @param identifier The title of the element to wait for.
 @result A configured test step.
 */
+ (id)stepToWaitForViewWithTitle:(NSString *)title;

/*!
 @method stepToClickViewWithTitle:
 @abstract A step that clicks a particular view in the view hierarchy.
 @discussion The view or accessibility element with the given title is searched for in the view hierarchy. If the element isn't found or isn't currently clickable, then the step will attempt to wait until it is. Once the view is present and clickable, a click event is simulated in the center of the view or element.
 @param label The title of the element to click.
 @result A configured test step.
 */
+ (id)stepToClickViewWithTitle:(NSString *)title;

- (KIFElement *)elementWithIdentifier:(NSString *)identifier error:(NSError **)error;
- (KIFElement *)elementWithTitle:(NSString *)title error:(NSError **)error;

@end
