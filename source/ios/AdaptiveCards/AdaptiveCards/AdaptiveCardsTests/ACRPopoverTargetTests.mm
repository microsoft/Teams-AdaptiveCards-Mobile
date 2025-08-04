//
//  ACRPopoverTargetTests.mm
//  AdaptiveCardsTests
//
//  Created by Harika P on 01/08/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ACRPopoverTarget.h"
#import "ACOBaseActionElement.h"
#import "ACRView.h"

@interface ACRPopoverTargetTests: XCTestCase
@end

@implementation ACRPopoverTargetTests

- (void) testInitWithActionElementAndRootView
{
    ACOBaseActionElement *action = [[ACOBaseActionElement alloc] init];
    ACRView *rootView = [[ACRView alloc] initWithFrame:CGRectZero];
    ACRPopoverTarget *target = [[ACRPopoverTarget alloc] initWithActionElement:action rootView:rootView];
    XCTAssertNotNil(target);
}

- (void) testPrivatePropertiesSetOnInit
{
    ACOBaseActionElement *action = [[ACOBaseActionElement alloc] init];
    ACRView *rootView = [[ACRView alloc] initWithFrame:CGRectZero];
    ACRPopoverTarget *target = [[ACRPopoverTarget alloc] initWithActionElement:action rootView:rootView];
    XCTAssertEqual([target valueForKey:@"actionElement"], action);
    XCTAssertEqual([target valueForKey:@"rootView"], rootView);
}

- (void) testMultipleInstances
{
    ACOBaseActionElement *action1 = [[ACOBaseActionElement alloc] init];
    ACOBaseActionElement *action2 = [[ACOBaseActionElement alloc] init];
    ACRView *rootView1 = [[ACRView alloc] initWithFrame:CGRectZero];
    ACRView *rootView2 = [[ACRView alloc] initWithFrame:CGRectZero];
    ACRPopoverTarget *target1 = [[ACRPopoverTarget alloc] initWithActionElement:action1 rootView:rootView1];
    ACRPopoverTarget *target2 = [[ACRPopoverTarget alloc] initWithActionElement:action2 rootView:rootView2];
    XCTAssertNotEqual(target1, target2);
    XCTAssertNotEqual([target1 valueForKey:@"actionElement"], [target2 valueForKey:@"actionElement"]);
    XCTAssertNotEqual([target1 valueForKey:@"rootView"], [target2 valueForKey:@"rootView"]);
}

- (void) testInitWithNilParameters
{
    ACRPopoverTarget *target = [[ACRPopoverTarget alloc] initWithActionElement:nil rootView:nil];
    XCTAssertNotNil(target);
    XCTAssertNil([target valueForKey:@"actionElement"]);
    XCTAssertNil([target valueForKey:@"rootView"]);
}

- (void) testDeallocation
{
    __weak ACRPopoverTarget *weakTarget;
    @autoreleasepool {
        ACOBaseActionElement *action = [[ACOBaseActionElement alloc] init];
        ACRView *rootView = [[ACRView alloc] initWithFrame:CGRectZero];
        ACRPopoverTarget *target = [[ACRPopoverTarget alloc] initWithActionElement:action rootView:rootView];
        weakTarget = target;
        target = nil;
    }
    XCTAssertNil(weakTarget, @"ACRPopoverTarget should deallocate (no retain cycle)");
}

- (void) testIsSubclassOfACRBaseTarget
{
    ACOBaseActionElement *action = [[ACOBaseActionElement alloc] init];
    ACRView *rootView = [[ACRView alloc] initWithFrame:CGRectZero];
    ACRPopoverTarget *target = [[ACRPopoverTarget alloc] initWithActionElement:action rootView:rootView];
    XCTAssertTrue([target isKindOfClass:[ACRBaseTarget class]]);
}

- (void) testDescription
{
    ACOBaseActionElement *action = [[ACOBaseActionElement alloc] init];
    ACRView *rootView = [[ACRView alloc] initWithFrame:CGRectZero];
    ACRPopoverTarget *target = [[ACRPopoverTarget alloc] initWithActionElement:action rootView:rootView];
    NSString *desc = [target description];
    XCTAssertNotNil(desc);
    XCTAssertTrue([desc isKindOfClass:[NSString class]]);
}

@end
