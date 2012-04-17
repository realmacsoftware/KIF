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
+ (id)stepToWaitForFocusedWindowWithTitle:(NSString*)title;


/*!
 @method stepToSelectCellInViewWithAccessibilityIdentifier:cellTitle:
 @abstract A step that selects a cell in a view that is a list still (tableview, IKImageBrowser etc.)
 @discussion A step to select a cell in a view.
 
 @param identifier The accessibility identifier of view to select the cell in.
 @param title The title of the cell to select in the view.
 @result A configured test step.
 */

+ (id)stepToSelectCellInViewWithAccessibilityIdentifier:(NSString*)identifier cellTitle:(NSString*)title;

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

/*!
 @method stepToWaitForFocusedWindowWithAccessibilityIdentifier:
 @abstract A step that waits for a window to be focussed.
 @discussion The current focussed window is checked for a match with the given accesibility identifier. If the window isn't found or isn't found, then the step will attempt to wait until it is. Once the window is present and focussed, this step succeeds.
 @param identifier the accessibility identifier for the window.
 @result A configured test step.
 */
+ (id)stepToWaitForFocusedWindowWithAccessibilityIdentifier:(NSString*)identifier;

/*!
 @method stepToWaitForSheetWithAccessibilityIdentifier:
 @abstract A step that waits for a sheet to be presented.
 @discussion The current focussed window is checked for an accesibility element with the NSAccessibilitySheetRole, and a matching accesibility identifier. If no sheet is found or it doesn't have a matching accessibility identifier, then the step will attempt to wait until it is. Once the sheet is present, this step succeeds.
 @param identifier the accessibility identifier for the sheet.
 @result A configured test step.
 */
+ (id)stepToWaitForSheetWithAccessibilityIdentifier:(NSString*)identifier;

/*!
 @method stepToWaitForViewInSheetWithAccessibilityIdentifier:
 @abstract A step that waits for a view inside a presented sheet to be available.
 @discussion The current focussed window is checked for an accesibility element with the NSAccessibilitySheetRole, and then the children of this item are searched for a view matching the provided accesibility identifier. If no sheet is found or it doesn't have a child element matching accessibility identifier, then the step will attempt to wait until it is. Once the sheet is present, this step succeeds.
 @param identifier the accessibility identifier for the sheet.
 @result A configured test step.
 */
+ (id)stepToWaitForViewInSheetWithAccessibilityIdentifier:(NSString *)identifier;

/*!
 @method stepToFocusOnViewWithAccessibilityIdentifier:
 @abstract A step that sets the focussed attribute to YES for a view with the matching accessibilty identifier.
 @discussion The current focussed window is searched for an accesibility element matching the provided accessibility identifier.  If not matching item is found, this test fails.  If a matching element is found and it does not have the NSAccessibilityFocusedAttribute, this test fails.  If a matching element is found and focus is not able to be set, this test fails. If a matching element is found and NSAccessibilityFocusedAttribute was successfully set to YES, this step succeeds.
 @param identifier the accessibility identifier for the view.
 @result A configured test step.
 */
+ (id)stepToFocusOnViewWithAccessibilityIdentifier:(NSString*)identifier;

/*!
 @method stepToDoubleClickCellAtIndex:inCollectionViewWithAccessibilityIdentifier:
 @abstract A step that performs a double click action on a collection view with provided accessibility identifier.
 @discussion The current focussed window is searched for an accesibility element matching the provided accessibility identifier.  If not matching item is found, this test fails.  If a matching element is found and does not have a NSAccessibilityGridRole, this test fails.  If a child cannot be found for the provided index, this test fails. If a child is found at this index, and we are able to perform the press action (equivalent to dbl click) successfully then this step succeeds.
 @param cellIndex the index of the cell to double click.
 @param identifier the accessibility identifier for the view.
 @result A configured test step.
 */
+ (id)stepToDoubleClickCellAtIndex:(NSUInteger)cellIndex inCollectionViewWithAccessibilityIdentifier:(NSString*)identifier;


+ (id)stepToCheckCollectionViewWithIdentifier:(NSString*)identifier hasNumberOfCells:(NSUInteger)numberOfCells;

/*!
 @method stepToTypeText:inViewWithAccessibilityIdentifier:
 @abstract A step that types text into a view with the provided accessibility identifier.
 @discussion The current focussed window is searched for an accesibility element matching the provided accessibility identifier.  If no matching item is found, this test fails.  If a matching element is found and does not have a NSAccessibilityTextFieldRole or NSAccessibilityTextAreaRole, this test fails.  If the element's text cannot be succesfullt set, this test fails. If the text is set successfully, this step succeeds.
 @param text the text to type into the view
 @param identifier the accessibility identifier for the view.
 @result A configured test step.
 */
+ (id)stepToTypeText:(NSString*)text inViewWithAccessibilityIdentifier:(NSString*)identifier;

+ (id)stepToClickRowAtIndex:(NSUInteger)index inTableViewWithAccessibilityIdentifier:(NSString*)identifier;
+ (id)stepToClickRowWithTitle:(NSString*)title inTableViewWithAccessibilityIdentifier:(NSString*)identifier;
+ (id)stepToClickMenuItemWithTitle:(NSString*)title inMenuWithTitle:(NSString*)menuTitle;

- (KIFElement*)childOfSheetWithIdentifier:(NSString*)identifier error:(NSError **)error;
- (KIFElement *)elementWithIdentifier:(NSString *)identifier error:(NSError **)error;
- (KIFElement *)elementWithTitle:(NSString *)title error:(NSError **)error;
- (KIFElement *)menuWithTitle:(NSString *)title error:(NSError **)error;

@end
