//
//  ACROverflowTargetTests.mm
//  AdaptiveCardsTests
//
//  Copyright © 2026 Microsoft. All rights reserved.
//

#import "ACOActionOverflow.h"
#import "ACROverflowTarget.h"
#import "ACRView.h"
#import <XCTest/XCTest.h>

@interface ACROverflowTargetTests : XCTestCase
@end

@implementation ACROverflowTargetTests

- (ACROverflowTarget *)makeTarget
{
    ACOActionOverflow *actionElement = [[ACOActionOverflow alloc] init];
    actionElement.menuActions = @[];
    ACRView *rootView = [[ACRView alloc] initWithFrame:CGRectZero];
    return [[ACROverflowTarget alloc] initWithActionElement:actionElement rootView:rootView];
}

- (UIAlertAction *)cancelActionOf:(ACROverflowTarget *)target
{
    UIAlertController *alert = [target valueForKey:@"_alert"];
    for (UIAlertAction *action in alert.actions) {
        if (action.style == UIAlertActionStyleCancel) {
            return action;
        }
    }
    return nil;
}

/// The sheet must offer a way out; that action is what hands focus back.
- (void)testOverflowSheetHasACancelAction
{
    UIAlertAction *cancel = [self cancelActionOf:[self makeTarget]];
    XCTAssertNotNil(cancel, @"the overflow sheet should offer a cancel action");
    XCTAssertEqual(cancel.style, UIAlertActionStyleCancel);
}

/// The anchor is the control the user opened the menu from.
- (void)testFocusAnchorRoundTrips
{
    ACROverflowTarget *target = [self makeTarget];
    UIView *button = [[UIView alloc] initWithFrame:CGRectZero];
    target.accessibilityFocusAnchor = button;
    XCTAssertEqual(target.accessibilityFocusAnchor, button);
}

/// The anchor is weak on purpose: the menu must never keep the button alive.
- (void)testFocusAnchorDoesNotRetainTheButton
{
    ACROverflowTarget *target = [self makeTarget];
    @autoreleasepool {
        UIView *button = [[UIView alloc] initWithFrame:CGRectZero];
        target.accessibilityFocusAnchor = button;
        XCTAssertNotNil(target.accessibilityFocusAnchor);
    }
    XCTAssertNil(target.accessibilityFocusAnchor,
                 @"the anchor must not retain the button that opened the menu");
}

/// The defect this guards: dismissing the sheet used to do nothing at all, so VoiceOver
/// fell back to the top of the card instead of the control the user came from. Driving
/// the restoration with a live anchor must complete cleanly.
///
/// Note this asserts the restoration path runs and is safe, not that VoiceOver received
/// the notification — UIAccessibility notifications are delivered to the accessibility
/// server and are not observable from a unit test with VoiceOver off.
- (void)testRestoringFocusWithAnAnchorIsSafe
{
    ACROverflowTarget *target = [self makeTarget];
    UIView *button = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    target.accessibilityFocusAnchor = button;
    XCTAssertNoThrow([target restoreAccessibilityFocusToAnchor]);
}

/// If the anchor has gone away, restoration must be a no-op rather than posting an
/// unanchored notification or touching a released view.
- (void)testRestoringFocusWithoutAnAnchorIsANoOp
{
    ACROverflowTarget *target = [self makeTarget];
    XCTAssertNil(target.accessibilityFocusAnchor);
    XCTAssertNoThrow([target restoreAccessibilityFocusToAnchor]);
}

/// The cancel handler captures self weakly; the target must still deallocate.
- (void)testTargetDeallocates
{
    __weak ACROverflowTarget *weakTarget;
    @autoreleasepool {
        ACROverflowTarget *target = [self makeTarget];
        target.accessibilityFocusAnchor = [[UIView alloc] initWithFrame:CGRectZero];
        weakTarget = target;
        target = nil;
    }
    XCTAssertNil(weakTarget, @"ACROverflowTarget should deallocate (no retain cycle)");
}

@end
