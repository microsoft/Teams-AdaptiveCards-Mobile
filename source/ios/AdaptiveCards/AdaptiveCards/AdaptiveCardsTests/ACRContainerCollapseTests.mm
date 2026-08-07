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
#import "ACRContentStackView.h"
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
///
/// These tests assert on **hidden state** rather than on rendered text. Text is not a
/// usable signal here for two reasons:
///   1. TextBlock renders into an ACRViewAttachingTextView (a UITextView), not a UILabel.
///   2. Text content is populated by background preprocessing on ACRView's serial text
///      queue, and the SDK never awaits it during render, so no text is present
///      synchronously.
/// A text-based assertion therefore passes or fails for reasons unrelated to collapsing,
/// and a "text is absent" assertion would pass vacuously.
///
/// The collapse path itself is synchronous and deterministic:
///   registerInvisibleView: -> applyVisibilityToSubviews -> hideView:
/// and hideView: sets `hidden = YES` on the target view. That is what is asserted below.
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

#pragma mark - Helpers

/// Every ACRContentStackView in the tree. Containers, Columns and ColumnSets are all
/// content stack views, and collapsing manifests as one of them being hidden.
- (NSArray<ACRContentStackView *> *)contentStacksIn:(UIView *)view
{
    NSMutableArray<ACRContentStackView *> *found = [NSMutableArray array];
    if ([view isKindOfClass:[ACRContentStackView class]]) {
        [found addObject:(ACRContentStackView *)view];
    }
    for (UIView *sub in view.subviews) {
        [found addObjectsFromArray:[self contentStacksIn:sub]];
    }
    return found;
}

- (NSArray<ACRContentStackView *> *)hiddenContentStacksIn:(UIView *)view
{
    NSMutableArray<ACRContentStackView *> *hidden = [NSMutableArray array];
    for (ACRContentStackView *stack in [self contentStacksIn:view]) {
        if (stack.isHidden) {
            [hidden addObject:stack];
        }
    }
    return hidden;
}

- (NSUInteger)hiddenViewCountIn:(UIView *)view
{
    NSUInteger count = view.isHidden ? 1 : 0;
    for (UIView *sub in view.subviews) {
        count += [self hiddenViewCountIn:sub];
    }
    return count;
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

    UIView *rendered = (UIView *)result.view;
    [rendered setNeedsLayout];
    [rendered layoutIfNeeded];
    return rendered;
}

/// Shared assertion. Guards against passing vacuously: if the payload produced no
/// content stack views at all then "nothing is hidden" would be trivially true, so the
/// presence of at least `expectedStacks` of them is asserted first.
- (void)assertNothingCollapsedIn:(UIView *)rendered
                 atLeastStacks:(NSUInteger)expectedStacks
                       message:(NSString *)message
{
    NSArray<ACRContentStackView *> *stacks = [self contentStacksIn:rendered];
    XCTAssertGreaterThanOrEqual(stacks.count, expectedStacks,
                                @"%@: expected at least %lu content stack views, found %lu - "
                                @"the payload did not render the shape under test",
                                message, (unsigned long)expectedStacks, (unsigned long)stacks.count);

    NSArray<ACRContentStackView *> *hidden = [self hiddenContentStacksIn:rendered];
    XCTAssertEqual(hidden.count, 0u, @"%@: %lu of %lu content stack views were collapsed",
                   message, (unsigned long)hidden.count, (unsigned long)stacks.count);
}

#pragma mark - Tests

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
    [self assertNothingCollapsedIn:rendered atLeastStacks:1 message:@"Container with FactSet"];
}

/// Same shape one level deeper, since the collapse walked nested content stack views.
- (void)testNestedContainerWithVisibleChildIsNotCollapsed
{
    NSString *payload = @"{"
                         "\"type\":\"AdaptiveCard\",\"version\":\"1.5\",\"body\":[{"
                         "\"type\":\"Container\",\"items\":[{"
                         "\"type\":\"Container\",\"items\":[{"
                         "\"type\":\"TextBlock\",\"text\":\"Nested survives\"}]}]}]}";

    UIView *rendered = [self renderPayload:payload];
    [self assertNothingCollapsedIn:rendered atLeastStacks:2 message:@"Nested Container"];
}

/// ColumnSet is the other shape the collapse targeted.
- (void)testColumnSetWithVisibleColumnIsNotCollapsed
{
    NSString *payload = @"{"
                         "\"type\":\"AdaptiveCard\",\"version\":\"1.5\",\"body\":[{"
                         "\"type\":\"ColumnSet\",\"columns\":[{"
                         "\"type\":\"Column\",\"items\":[{"
                         "\"type\":\"TextBlock\",\"text\":\"Column content\"}]}]}]}";

    UIView *rendered = [self renderPayload:payload];
    [self assertNothingCollapsedIn:rendered atLeastStacks:2 message:@"ColumnSet with Column"];
}

/// The explicit isVisible:false path must still hide its target. This is the control:
/// it proves the visibility machinery is actually running in these tests, so the
/// "nothing is hidden" assertions above are meaningful rather than vacuous.
- (void)testExplicitlyInvisibleChildIsStillHidden
{
    NSString *payload = @"{"
                         "\"type\":\"AdaptiveCard\",\"version\":\"1.5\",\"body\":[{"
                         "\"type\":\"Container\",\"items\":["
                         "{\"type\":\"TextBlock\",\"text\":\"Visible\"},"
                         "{\"type\":\"TextBlock\",\"text\":\"Hidden\",\"isVisible\":false}]}]}";

    UIView *rendered = [self renderPayload:payload];

    XCTAssertGreaterThan([self hiddenViewCountIn:rendered], 0u,
                         @"isVisible:false produced no hidden view - the visibility "
                         @"machinery did not run, so the collapse assertions would be vacuous");

    // The container itself still holds a visible child and must survive.
    [self assertNothingCollapsedIn:rendered atLeastStacks:1 message:@"Container with one hidden child"];
}

@end
