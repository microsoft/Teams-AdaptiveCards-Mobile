//
//  ACRCitationParserTests.mm
//  AdaptiveCardsTests
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "ACRCitationParser.h"
#import "ACRCitationParserDelegate.h"
#import "ACICitationPresenter.h"
#import "ACOCitation.h"
#import "ACOReference.h"
#import "ACRViewTextAttachment.h"

#pragma mark - Mock: Parser Delegate (analytics from parser layer)

@interface MockParserDelegate : NSObject <ACRCitationParserDelegate>
@property (nonatomic, strong) NSMutableArray<ACOCitation *> *tappedCitations;
@end

@implementation MockParserDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _tappedCitations = [NSMutableArray array];
    }
    return self;
}

- (void)citationParser:(id)parser
       didTapCitation:(ACOCitation *)citation
        referenceData:(ACOReference *)referenceData {
    [self.tappedCitations addObject:citation];
}

@end

#pragma mark - Mock: Citation Presenter

@interface MockCitationPresenter : NSObject <ACICitationPresenter>
@property (nonatomic, strong) NSMutableArray<ACOCitation *> *handledCitations;
@end

@implementation MockCitationPresenter

- (instancetype)init {
    self = [super init];
    if (self) {
        _handledCitations = [NSMutableArray array];
    }
    return self;
}

- (void)presentBottomSheetFrom:(UIViewController *)activeController
                didTapCitation:(ACOCitation *)citation
                 referenceData:(ACOReference *)referenceData {
    // no-op: tests use the handleCitationTap: path
}

- (void)handleCitationTap:(ACOCitation *)citation
            referenceData:(ACOReference *)referenceData {
    [self.handledCitations addObject:citation];
}

@end

#pragma mark - Testable ACRCitationParser Subclass

/// Subclass that overrides createButtonWithTitle:size: to capture the created UIButton.
/// This enables per-button associated object assertions without using private API.
@interface TestableCitationParser : ACRCitationParser
@property (nonatomic, strong) UIButton *lastCreatedButton;
@end

/// Private-method forward declaration so the subclass can call super.
@interface ACRCitationParser (TestingPrivate)
- (UIButton *)createButtonWithTitle:(NSString *)title size:(CGSize)size;
@end

@implementation TestableCitationParser

- (UIButton *)createButtonWithTitle:(NSString *)title size:(CGSize)size {
    UIButton *button = [super createButtonWithTitle:title size:size];
    self.lastCreatedButton = button;
    return button;
}

@end

// TEST CASES BELOW THIS POINT

#pragma mark - ACRCitationParser Tests

@interface ACRCitationParserTests : XCTestCase
@property (nonatomic, strong) MockParserDelegate *mockDelegate;
@property (nonatomic, strong) ACRCitationParser *parser;
@property (nonatomic, strong) ACOReference *mockReference;
@property (nonatomic, strong) NSArray<ACOReference *> *references;
@end

@implementation ACRCitationParserTests

- (void)setUp {
    [super setUp];
    self.mockDelegate = [[MockParserDelegate alloc] init];
    self.parser = [[ACRCitationParser alloc] initWithDelegate:self.mockDelegate];
    self.mockReference = [[ACOReference alloc] init];
    self.references = @[self.mockReference];
}

- (void)tearDown {
    self.parser = nil;
    self.mockDelegate = nil;
    self.mockReference = nil;
    self.references = nil;
    [super tearDown];
}

/// findReferenceByIndex returns the correct object for an in-bounds index.
- (void)testFindReference_returnsCorrectObjectForInBoundsIndex {
    // Given: A references array with one item and a valid index
    NSNumber *referenceId = @0;

    // When: Looking up the reference by index
    ACOReference *found = [self.parser findReferenceByIndex:referenceId inReferences:self.references];

    // Then: The reference at index 0 should be returned
    XCTAssertNotNil(found, @"Should return a reference for a valid index");
    XCTAssertEqual(found, self.mockReference, @"Should return exactly the reference at the given index");
}

/// findReferenceByIndex returns nil for an index beyond the array bounds.
- (void)testFindReference_returnsNilForOutOfBoundsIndex {
    // Given: An index well beyond the array bounds
    NSNumber *referenceId = @999;

    // When: Looking up the reference
    ACOReference *found = [self.parser findReferenceByIndex:referenceId inReferences:self.references];

    // Then: Should return nil without crashing
    XCTAssertNil(found, @"Should return nil for an out-of-bounds index");
}

/// findReferenceByIndex returns nil when referenceId is nil.
- (void)testFindReference_returnsNilForNilReferenceId {
    // Given: A nil referenceId

    // When: Looking up the reference
    ACOReference *found = [self.parser findReferenceByIndex:nil inReferences:self.references];

    // Then: Should return nil without crashing
    XCTAssertNil(found, @"Should return nil when referenceId is nil");
}

/// findReferenceByIndex returns nil when the references array is nil.
- (void)testFindReference_returnsNilForNilReferencesArray {
    // Given: A valid referenceId but nil references array
    NSNumber *referenceId = @0;

    // When: Looking up the reference
    ACOReference *found = [self.parser findReferenceByIndex:referenceId inReferences:nil];

    // Then: Should return nil without crashing
    XCTAssertNil(found, @"Should return nil when references array is nil");
}

/// createAttachmentWithCitation returns nil when referenceData is nil.
- (void)testCreateAttachment_returnsNilForNilReferenceData {
    // Given: A valid citation with no matching referenceData
    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"1"
                                                      referenceIndex:@0
                                                               theme:ACRThemeLight];

    // When: Creating the attachment with nil referenceData
    ACRViewTextAttachment *attachment = [self.parser createAttachmentWithCitation:citation
                                                                    referenceData:nil];

    // Then: No attachment should be created
    XCTAssertNil(attachment, @"createAttachment should return nil when referenceData is nil");
}

/// createAttachmentWithCitation returns a non-nil attachment for valid citation and reference.
- (void)testCreateAttachment_returnsAttachmentForValidData {
    // Given: A valid citation and a matching reference
    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"1"
                                                      referenceIndex:@0
                                                               theme:ACRThemeLight];

    // When: Creating the attachment
    ACRViewTextAttachment *attachment = [self.parser createAttachmentWithCitation:citation
                                                                    referenceData:self.mockReference];

    // Then: A valid attachment should be returned
    XCTAssertNotNil(attachment, @"createAttachment should return a valid attachment for valid data");
    XCTAssertTrue([attachment isKindOfClass:[ACRViewTextAttachment class]],
                  @"Should be an ACRViewTextAttachment");
}

/// createAttachmentWithCitation stores the parser's presenter on the created button.
- (void)testCreateAttachment_storesPresenterOnButton {
    // Given: A testable parser with a mock presenter and a valid citation
    TestableCitationParser *testParser = [[TestableCitationParser alloc] initWithDelegate:self.mockDelegate];
    MockCitationPresenter *mockPresenter = [[MockCitationPresenter alloc] init];
    testParser.presenter = mockPresenter;

    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"1"
                                                      referenceIndex:@0
                                                               theme:ACRThemeLight];

    // When: Creating an attachment
    [testParser createAttachmentWithCitation:citation referenceData:self.mockReference];
    UIButton *capturedButton = testParser.lastCreatedButton;

    // Then: The presenter should be retrievable from the button via associated object
    id storedPresenter = objc_getAssociatedObject(capturedButton, (const void *)@"presenter");
    XCTAssertNotNil(capturedButton, @"A UIButton should have been created");
    XCTAssertEqual(storedPresenter, mockPresenter,
                   @"The presenter should be stored on the button at creation time");
}

/// Tapping a citation button fires the parser delegate analytics callback.
- (void)testCitationButtonTapped_invokesDelegate {
    // Given: A testable parser wired to a mock delegate, with a button created for a citation
    TestableCitationParser *testParser = [[TestableCitationParser alloc] initWithDelegate:self.mockDelegate];
    testParser.presenter = [[MockCitationPresenter alloc] init];

    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"1"
                                                      referenceIndex:@0
                                                               theme:ACRThemeLight];
    [testParser createAttachmentWithCitation:citation referenceData:self.mockReference];
    UIButton *capturedButton = testParser.lastCreatedButton;

    // When: Simulating a tap on the button
    [capturedButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    // Then: The parser delegate should receive exactly one analytics tap event
    XCTAssertEqual(self.mockDelegate.tappedCitations.count, 1,
                   @"Delegate should receive one tap event");
    XCTAssertEqual(self.mockDelegate.tappedCitations.firstObject, citation,
                   @"Delegate citation should match what was stored on the button");
}

/// Tapping a citation button invokes the presenter stored on that specific button,
/// not the parser's current presenter property (per-button isolation).
- (void)testCitationButtonTapped_routesToPerButtonPresenter {
    // Given: Two separate presenters, each used to create one button
    TestableCitationParser *testParser = [[TestableCitationParser alloc] initWithDelegate:self.mockDelegate];
    MockCitationPresenter *presenterA = [[MockCitationPresenter alloc] init];
    MockCitationPresenter *presenterB = [[MockCitationPresenter alloc] init];

    ACOCitation *citationA = [[ACOCitation alloc] initWithDisplayText:@"1"
                                                       referenceIndex:@0
                                                                theme:ACRThemeLight];
    ACOCitation *citationB = [[ACOCitation alloc] initWithDisplayText:@"2"
                                                       referenceIndex:@0
                                                                theme:ACRThemeLight];

    // Button A created with presenterA
    testParser.presenter = presenterA;
    [testParser createAttachmentWithCitation:citationA referenceData:self.mockReference];
    UIButton *buttonA = testParser.lastCreatedButton;

    // Button B created with presenterB
    testParser.presenter = presenterB;
    [testParser createAttachmentWithCitation:citationB referenceData:self.mockReference];
    UIButton *buttonB = testParser.lastCreatedButton;

    // When: Both buttons are tapped
    [buttonA sendActionsForControlEvents:UIControlEventTouchUpInside];
    [buttonB sendActionsForControlEvents:UIControlEventTouchUpInside];

    // Then: Each presenter should only receive its own citation tap
    XCTAssertEqual(presenterA.handledCitations.count, 1,
                   @"PresenterA should receive exactly one tap");
    XCTAssertEqual(presenterA.handledCitations.firstObject, citationA,
                   @"PresenterA should receive citationA, not citationB");
    XCTAssertEqual(presenterB.handledCitations.count, 1,
                   @"PresenterB should receive exactly one tap");
    XCTAssertEqual(presenterB.handledCitations.firstObject, citationB,
                   @"PresenterB should receive citationB, not citationA");
}

/// parseAttributedStringWithCitation falls back to the citation's displayText when no reference matches.
- (void)testParseStringWithCitation_returnsFallbackWhenNoMatchingReference {
    // Given: A citation with an index that does not match any reference
    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"[1]"
                                                      referenceIndex:@999
                                                               theme:ACRThemeLight];

    // When: Parsing with an empty references array
    NSAttributedString *result = [self.parser parseAttributedStringWithCitation:citation
                                                                  andReferences:@[]];

    // Then: The returned string should contain the citation's displayText
    XCTAssertNotNil(result, @"Should return a non-nil string even when no reference matches");
    XCTAssertEqualObjects(result.string, @"[1]",
                          @"Fallback should be the citation's displayText");
}

/// parseAttributedStringWithCitation embeds a text attachment when a reference is found.
- (void)testParseStringWithCitation_returnsAttachmentWhenReferenceExists {
    // Given: A citation whose index resolves to a known reference
    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"1"
                                                      referenceIndex:@0
                                                               theme:ACRThemeLight];

    // When: Parsing with valid references
    NSAttributedString *result = [self.parser parseAttributedStringWithCitation:citation
                                                                  andReferences:self.references];

    // Then: The result should contain a text attachment attribute
    __block BOOL hasAttachment = NO;
    [result enumerateAttribute:NSAttachmentAttributeName
                       inRange:NSMakeRange(0, result.length)
                       options:0
                    usingBlock:^(id _Nullable value, NSRange range, BOOL *stop) {
        if ([value isKindOfClass:[NSTextAttachment class]]) {
            hasAttachment = YES;
            *stop = YES;
        }
    }];
    XCTAssertTrue(hasAttachment,
                  @"Result should contain a NSTextAttachment for a valid reference");
}

/// The parser forwards citation tap analytics to its delegate (parser-level analytics path).
- (void)testCitationButtonTapped_forwardsAnalyticsToParserDelegate {
    // Given: A testable parser wired to a dedicated delegate
    MockParserDelegate *parserDelegate = [[MockParserDelegate alloc] init];
    TestableCitationParser *testParser = [[TestableCitationParser alloc] initWithDelegate:parserDelegate];
    testParser.presenter = [[MockCitationPresenter alloc] init];

    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"1"
                                                      referenceIndex:@0
                                                               theme:ACRThemeLight];
    [testParser createAttachmentWithCitation:citation referenceData:self.mockReference];
    UIButton *capturedButton = testParser.lastCreatedButton;

    // When: Tapping the button
    [capturedButton sendActionsForControlEvents:UIControlEventTouchUpInside];

    // Then: The parser-level delegate (analytics) should have fired
    XCTAssertEqual(parserDelegate.tappedCitations.count, 1,
                   @"Parser delegate should receive a tap event");
    XCTAssertEqual(parserDelegate.tappedCitations.firstObject, citation,
                   @"Parser delegate should receive the correct citation");
}

@end
