//
//  ACRContainerCollapseTests.mm
//  AdaptiveCardsTests
//
//  Copyright © 2026 Microsoft. All rights reserved.
//

#import "ACOAdaptiveCard.h"
#import "ACOAdaptiveCardParseResult.h"
#import "ACOHostConfig.h"
#import "ACOHostConfigParseResult.h"
#import "ACRRenderResult.h"
#import "ACRRenderer.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

/// Regression coverage for container collapsing.
///
/// A Container whose children are visible must never be collapsed. This broke once
/// before: the emptiness check was evaluated while children were still rendering, at
/// which point a child container always reports "no visible content", so every nested
/// container was collapsed and its content disappeared. FactSets nested in a Container
/// were the most visible casualty.
@interface ACRContainerCollapseTests : XCTestCase
@end

@implementation ACRContainerCollapseTests {
    NSString *_hostConfig;
}

- (void)setUp
{
    [super setUp];
    _hostConfig = @"{\"supportsInteractivity\":true}";
}

- (NSArray<UILabel *> *)labelsIn:(UIView *)view
{
    NSMutableArray<UILabel *> *found = [NSMutableArray array];
    if ([view isKindOfClass:[UILabel class]]) {
        [found addObject:(UILabel *)view];
    }
    for (UIView *sub in view.subviews) {
        [found addObjectsFromArray:[self labelsIn:sub]];
    }
    return found;
}

- (NSArray<NSString *> *)visibleTextIn:(UIView *)view
{
    NSMutableArray<NSString *> *texts = [NSMutableArray array];
    for (UILabel *label in [self labelsIn:view]) {
        // Ignore text that is not actually on screen.
        BOOL hidden = label.isHidden;
        UIView *ancestor = label.superview;
        while (!hidden && ancestor) {
            hidden = ancestor.isHidden;
            ancestor = ancestor.superview;
        }
        NSString *text = label.text ?: label.attributedText.string;
        if (!hidden && text.length) {
            [texts addObject:text];
        }
    }
    return texts;
}

- (UIView *)renderPayload:(NSString *)payload
{
    ACOAdaptiveCardParseResult *parsed = [ACOAdaptiveCard fromJson:payload];
    XCTAssertTrue(parsed.isValid, @"payload failed to parse");

    ACOHostConfigParseResult *config = [ACOHostConfig fromJson:_hostConfig resourceResolvers:nil];
    XCTAssertTrue(config.isValid, @"host config failed to parse");

    ACRRenderResult *result = [ACRRenderer render:parsed.card
                                           config:config.config
                                   widthConstraint:320.0f
                                            theme:ACRThemeLight];
    XCTAssertTrue(result.succeeded, @"render failed");
    XCTAssertNotNil(result.view);

    [result.view setNeedsLayout];
    [result.view layoutIfNeeded];
    return result.view;
}

/// A FactSet inside a Container must still render. Regression: the container was
/// collapsed and the card came back visually empty.
- (void)testContainerWithFactSetIsNotCollapsed
{
    NSString *payload = @"{"
                         "\"type\":\"AdaptiveCard\",\"version\":\"1.5\",\"body\":[{"
                         "\"type\":\"Container\",\"items\":[{"
                         "\"type\":\"FactSet\",\"facts\":["
                         "{\"title\":\"Severity\",\"value\":\"Severity A\"},"
                         "{\"title\":\"Location\",\"value\":\"Zone 1\"}]}]}]}";

    UIView *rendered = [self renderPayload:payload];
    NSArray<NSString *> *texts = [self visibleTextIn:rendered];

    XCTAssertTrue([texts containsObject:@"Severity"], @"fact title missing, container was collapsed. got: %@", texts);
    XCTAssertTrue([texts containsObject:@"Severity A"], @"fact value missing, container was collapsed. got: %@", texts);
    XCTAssertTrue([texts containsObject:@"Location"], @"fact title missing, container was collapsed. got: %@", texts);
    XCTAssertGreaterThan(CGRectGetHeight(rendered.frame), 0.0f, @"card rendered with zero height");
}

/// Same shape one level deeper, since the collapse walked nested content stack views.
- (void)testNestedContainerWithVisibleChildIsNotCollapsed
{
    NSString *payload = @"{"
                         "\"type\":\"AdaptiveCard\",\"version\":\"1.5\",\"body\":[{"
                         "\"type\":\"Container\",\"items\":[{"
                         "\"type\":\"Container\",\"items\":[{"
                         "\"type\":\"TextBlock\",\"text\":\"Nested survives\"}]}]}]}";

    NSArray<NSString *> *texts = [self visibleTextIn:[self renderPayload:payload]];
    XCTAssertTrue([texts containsObject:@"Nested survives"], @"nested container was collapsed. got: %@", texts);
}

/// ColumnSet is the other shape the collapse targeted.
- (void)testColumnSetWithVisibleColumnIsNotCollapsed
{
    NSString *payload = @"{"
                         "\"type\":\"AdaptiveCard\",\"version\":\"1.5\",\"body\":[{"
                         "\"type\":\"ColumnSet\",\"columns\":[{"
                         "\"type\":\"Column\",\"items\":[{"
                         "\"type\":\"TextBlock\",\"text\":\"Column content\"}]}]}]}";

    NSArray<NSString *> *texts = [self visibleTextIn:[self renderPayload:payload]];
    XCTAssertTrue([texts containsObject:@"Column content"], @"column was collapsed. got: %@", texts);
}

/// The genuinely-empty case must still be allowed to collapse, so a future re-land of
/// the feature has a target to satisfy rather than silently regressing this file.
- (void)testContainerWithOnlyInvisibleChildrenRendersNoText
{
    NSString *payload = @"{"
                         "\"type\":\"AdaptiveCard\",\"version\":\"1.5\",\"body\":[{"
                         "\"type\":\"Container\",\"items\":[{"
                         "\"type\":\"TextBlock\",\"text\":\"Hidden\",\"isVisible\":false}]}]}";

    NSArray<NSString *> *texts = [self visibleTextIn:[self renderPayload:payload]];
    XCTAssertFalse([texts containsObject:@"Hidden"], @"invisible child should not be visible. got: %@", texts);
}

@end
