//
//  ACRContentStackViewDoubleTouchTests.mm
//  AdaptiveCardsTests
//
//  Tests the _hasFiredActionForCurrentTouch guard in ACRContentStackView
//  that prevents iOS 26 double-fire of touchesEnded:withEvent:.
//
//  Copyright © 2026 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ACRContentStackView.h"
#import "ACRTapGestureRecognizerEventHandler.h"

#pragma mark - Mock Select Action Target

/// Counts how many times doSelectAction is called.
@interface MockSelectActionTarget : NSObject <ACRSelectActionDelegate>
@property (nonatomic) NSInteger actionFireCount;
@end

@implementation MockSelectActionTarget

- (void)doSelectAction
{
    self.actionFireCount++;
}

@end

#pragma mark - Tests

@interface ACRContentStackViewDoubleTouchTests : XCTestCase
@end

@implementation ACRContentStackViewDoubleTouchTests

/// Single touchesEnded fires doSelectAction exactly once.
- (void)testSingleTouchFiresOnce
{
    ACRContentStackView *stackView = [[ACRContentStackView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    MockSelectActionTarget *mock = [[MockSelectActionTarget alloc] init];
    stackView.selectActionTarget = mock;

    NSSet<UITouch *> *emptyTouches = [NSSet set];
    [stackView touchesBegan:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];

    XCTAssertEqual(mock.actionFireCount, 1, @"Single touch sequence should fire action exactly once");
}

/// Two touchesEnded calls (iOS 26 re-delivery) fire doSelectAction only once.
- (void)testDoubleTouchesEndedFiresOnlyOnce
{
    ACRContentStackView *stackView = [[ACRContentStackView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    MockSelectActionTarget *mock = [[MockSelectActionTarget alloc] init];
    stackView.selectActionTarget = mock;

    NSSet<UITouch *> *emptyTouches = [NSSet set];

    // Simulate iOS 26: touchesBegan once, then touchesEnded TWICE
    [stackView touchesBegan:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];  // 1st delivery — should fire
    [stackView touchesEnded:emptyTouches withEvent:nil];  // 2nd delivery (re-delivery) — should NOT fire

    XCTAssertEqual(mock.actionFireCount, 1, @"Double touchesEnded should only fire action once (iOS 26 guard)");
}

/// touchesCancelled resets the guard so next touch sequence can fire.
- (void)testTouchesCancelledResetsGuard
{
    ACRContentStackView *stackView = [[ACRContentStackView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    MockSelectActionTarget *mock = [[MockSelectActionTarget alloc] init];
    stackView.selectActionTarget = mock;

    NSSet<UITouch *> *emptyTouches = [NSSet set];

    // First touch sequence
    [stackView touchesBegan:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];
    XCTAssertEqual(mock.actionFireCount, 1);

    // Cancel (e.g., system gesture interrupted)
    [stackView touchesCancelled:emptyTouches withEvent:nil];

    // Second touch sequence — should fire again
    [stackView touchesBegan:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];
    XCTAssertEqual(mock.actionFireCount, 2, @"After touchesCancelled, next touch should fire");
}

/// Two separate touch sequences (touchesBegan resets guard) both fire.
- (void)testTwoSeparateTouchSequencesBothFire
{
    ACRContentStackView *stackView = [[ACRContentStackView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    MockSelectActionTarget *mock = [[MockSelectActionTarget alloc] init];
    stackView.selectActionTarget = mock;

    NSSet<UITouch *> *emptyTouches = [NSSet set];

    // First tap
    [stackView touchesBegan:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];

    // Second tap (new touchesBegan resets guard)
    [stackView touchesBegan:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];

    XCTAssertEqual(mock.actionFireCount, 2, @"Two separate touch sequences should each fire once");
}

/// Triple touchesEnded (paranoia) still fires only once.
- (void)testTripleTouchesEndedFiresOnlyOnce
{
    ACRContentStackView *stackView = [[ACRContentStackView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    MockSelectActionTarget *mock = [[MockSelectActionTarget alloc] init];
    stackView.selectActionTarget = mock;

    NSSet<UITouch *> *emptyTouches = [NSSet set];

    [stackView touchesBegan:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];

    XCTAssertEqual(mock.actionFireCount, 1, @"Triple touchesEnded should only fire once");
}

/// Without selectActionTarget, touchesEnded doesn't crash or fire.
- (void)testNoSelectActionTargetNoFire
{
    ACRContentStackView *stackView = [[ACRContentStackView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    // No selectActionTarget set

    NSSet<UITouch *> *emptyTouches = [NSSet set];
    [stackView touchesBegan:emptyTouches withEvent:nil];
    [stackView touchesEnded:emptyTouches withEvent:nil];

    // Should not crash — just forwards to nextResponder
}

@end
