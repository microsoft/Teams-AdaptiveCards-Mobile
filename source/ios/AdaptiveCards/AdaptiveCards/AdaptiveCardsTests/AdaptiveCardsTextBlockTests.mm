//
//  AdaptiveCardsTextBlockTests.m
//  AdaptiveCardsTests
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "Enums.h"
#import "TextBlock.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ACRViewAttachingTextView.h"
#import "ACRViewTextAttachment.h"

@interface AdaptiveCardsTextBlockTests : XCTestCase

@end

@implementation AdaptiveCardsTextBlockTests

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testTextBlockTextProperty
{
    std::shared_ptr<AdaptiveCards::TextBlock> textblock = std::make_shared<AdaptiveCards::TextBlock>();
    textblock->SetText("Text test");
    XCTAssert(textblock->GetText() == "Text test");
}

- (void)testTextBlockTextPropertySerialization
{
    std::shared_ptr<AdaptiveCards::TextBlock> textblock = std::make_shared<AdaptiveCards::TextBlock>();
    textblock->SetText("Text test");
    XCTAssert(textblock->Serialize() == "{\"text\":\"Text test\",\"type\":\"TextBlock\"}\n");
}

- (void)verifyTextColorIsSet:(AdaptiveCards::ForegroundColor)color
                 onTextBlock:(std::shared_ptr<AdaptiveCards::TextBlock> &)textblock
{
    textblock->SetTextColor(color);
    XCTAssert(textblock->GetTextColor() == color);
}

- (void)testTextBlockColorProperty
{
    std::shared_ptr<AdaptiveCards::TextBlock> textblock = std::make_shared<AdaptiveCards::TextBlock>();
    [self verifyTextColorIsSet:AdaptiveCards::ForegroundColor::Default
                   onTextBlock:textblock];
    [self verifyTextColorIsSet:AdaptiveCards::ForegroundColor::Dark
                   onTextBlock:textblock];
    [self verifyTextColorIsSet:AdaptiveCards::ForegroundColor::Light
                   onTextBlock:textblock];
    [self verifyTextColorIsSet:AdaptiveCards::ForegroundColor::Accent
                   onTextBlock:textblock];
    [self verifyTextColorIsSet:AdaptiveCards::ForegroundColor::Good
                   onTextBlock:textblock];
    [self verifyTextColorIsSet:AdaptiveCards::ForegroundColor::Warning
                   onTextBlock:textblock];
    [self verifyTextColorIsSet:AdaptiveCards::ForegroundColor::Attention
                   onTextBlock:textblock];
}

- (void)verifyTextColorIsSerialized:(AdaptiveCards::ForegroundColor)color
                                 as:(const std::string &)serializedString
                        onTextBlock:(std::shared_ptr<AdaptiveCards::TextBlock> &)textblock
{
    textblock->SetTextColor(color);
    std::string serializedTextBlock = textblock->Serialize();
    XCTAssert(serializedTextBlock == "{\"color\":\"" + serializedString + "\",\"text\":\"\",\"type\":\"TextBlock\"}\n");
}

- (void)testTextBlockColorPropertySerialization
{
    std::shared_ptr<AdaptiveCards::TextBlock> textblock = std::make_shared<AdaptiveCards::TextBlock>();
    XCTAssert(textblock->Serialize() == "{\"text\":\"\",\"type\":\"TextBlock\"}\n");

    [self verifyTextColorIsSerialized:AdaptiveCards::ForegroundColor::Dark
                                   as:"Dark"
                          onTextBlock:textblock];
    [self verifyTextColorIsSerialized:AdaptiveCards::ForegroundColor::Light
                                   as:"Light"
                          onTextBlock:textblock];
    [self verifyTextColorIsSerialized:AdaptiveCards::ForegroundColor::Accent
                                   as:"Accent"
                          onTextBlock:textblock];
    [self verifyTextColorIsSerialized:AdaptiveCards::ForegroundColor::Good
                                   as:"Good"
                          onTextBlock:textblock];
    [self verifyTextColorIsSerialized:AdaptiveCards::ForegroundColor::Warning
                                   as:"Warning"
                          onTextBlock:textblock];
    [self verifyTextColorIsSerialized:AdaptiveCards::ForegroundColor::Attention
                                   as:"Attention"
                          onTextBlock:textblock];
}

@end

#pragma mark - Accessibility container for embedded citation views

// Verifies that a text view embedding interactive citation views (ACRViewTextAttachment) exposes those
// views to assistive technologies instead of collapsing into a single accessibility leaf.
@interface ACRCitationAccessibilityTests : XCTestCase
@end

@implementation ACRCitationAccessibilityTests

// Builds "See " + [citation pill button] + " for details." laid out in an ACRViewAttachingTextView.
- (ACRViewAttachingTextView *)textViewWithOneCitationPill:(UIButton **)outPill {
    UIButton *pill = [UIButton buttonWithType:UIButtonTypeSystem];
    [pill setTitle:@"1" forState:UIControlStateNormal];
    pill.accessibilityLabel = @"Citation 1";
    pill.frame = CGRectMake(0, 0, 22, 22);

    ACRViewTextAttachment *attachment = [[ACRViewTextAttachment alloc] initWithView:pill size:CGSizeMake(22, 22)];

    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"See "];
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:@" for details."]];

    ACRViewAttachingTextView *textView = [[ACRViewAttachingTextView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    textView.attributedText = string;
    [textView layoutIfNeeded];
    // Force glyph layout so the behavior inserts and positions the attachment subview.
    (void)[textView.layoutManager glyphRangeForTextContainer:textView.textContainer];

    if (outPill) {
        *outPill = pill;
    }
    return textView;
}

- (void)testTextViewWithCitationBecomesAccessibilityContainer {
    UIButton *pill = nil;
    ACRViewAttachingTextView *textView = [self textViewWithOneCitationPill:&pill];

    XCTAssertFalse(textView.isAccessibilityElement,
                   @"A text view embedding citation views must be a container, not a single leaf");

    NSArray *elements = textView.accessibilityElements;
    XCTAssertNotNil(elements, @"Container must vend accessibility elements");
    XCTAssertTrue(elements.count >= 2,
                  @"Expected surrounding text plus the citation view (got %lu)",
                  (unsigned long)elements.count);
    XCTAssertTrue([elements containsObject:pill],
                  @"The real citation button must be exposed as an accessibility element");
}

- (void)testCitationPillExposesLinkSemantics {
    UIButton *pill = nil;
    ACRViewAttachingTextView *textView = [self textViewWithOneCitationPill:&pill];
    (void)textView.accessibilityElements; // triggers configuration of the pill

    XCTAssertTrue((pill.accessibilityTraits & UIAccessibilityTraitLink) != 0,
                  @"Citation pill should expose link semantics to assistive technologies");
    XCTAssertTrue(pill.isAccessibilityElement,
                  @"Citation pill must remain an accessibility element");
}

- (void)testCitationFollowsLeadingTextInReadingOrder {
    UIButton *pill = nil;
    ACRViewAttachingTextView *textView = [self textViewWithOneCitationPill:&pill];

    NSArray *elements = textView.accessibilityElements;
    NSUInteger pillIndex = [elements indexOfObject:pill];
    XCTAssertTrue(pillIndex != NSNotFound, @"Citation must be present in the element list");
    XCTAssertTrue(pillIndex > 0, @"Leading text must precede the citation in reading order");
    XCTAssertTrue([elements.firstObject isKindOfClass:[UIAccessibilityElement class]],
                  @"First element should be the leading static-text run");
}

- (void)testPlainTextBlockDoesNotEngageContainer {
    // No attachments: our accessibility container must not engage at all — it defers entirely to
    // the ACRUILabel single-element path, so it must not synthesize its own accessibility elements.
    ACRViewAttachingTextView *textView = [[ACRViewAttachingTextView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    textView.attributedText = [[NSAttributedString alloc] initWithString:@"A plain text block with no citations."];
    [textView layoutIfNeeded];
    (void)[textView.layoutManager glyphRangeForTextContainer:textView.textContainer];

    NSArray *elements = textView.accessibilityElements;
    XCTAssertTrue(elements == nil || elements.count == 0,
                  @"Plain text without citations must not engage the citation accessibility container");
}

@end
