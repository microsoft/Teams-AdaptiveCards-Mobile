//
//  ACRCitationManagerTests.m
//  AdaptiveCardsTests
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ACRCitationManager.h"
#import "ACRCitationParser.h"
#import "ACRCitationManagerDelegate.h"
#import "ACRTextBlockCitationParser.h"
#import "ACRViewTextAttachment.h"
#import <objc/runtime.h>

@interface MockCitationDelegate : NSObject <ACRCitationManagerDelegate>
@property (nonatomic, strong) UIViewController *mockViewController;
@property (nonatomic, strong) NSArray<NSDictionary *> *mockReferences;
@property (nonatomic, strong) NSMutableArray<NSString *> *presentedCitations;
@property (nonatomic, strong) NSMutableArray<NSString *> *dismissedCitations;
@end

@implementation MockCitationDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _mockViewController = [[UIViewController alloc] init];
        _mockReferences = @[
            @{@"title": @"First Reference", @"abstract": @"First abstract", @"url": @"http://example1.com"},
            @{@"title": @"Second Reference", @"abstract": @"Second abstract", @"url": @"http://example2.com"}
        ];
        _presentedCitations = [NSMutableArray array];
        _dismissedCitations = [NSMutableArray array];
    }
    return self;
}

- (UIViewController *)parentViewControllerForCitationPresentation {
    return self.mockViewController;
}

- (NSArray<NSDictionary *> *)referencesForCitations {
    return self.mockReferences;
}

- (void)citationWillPresent:(NSString *)citationId referenceData:(NSDictionary *)referenceData {
    [self.presentedCitations addObject:citationId];
}

- (void)citationDidDismiss:(NSString *)citationId {
    [self.dismissedCitations addObject:citationId];
}

@end

@interface ACRCitationManagerTests : XCTestCase
@property (nonatomic, strong) ACRCitationManager *citationManager;
@property (nonatomic, strong) MockCitationDelegate *mockDelegate;
@end

@implementation ACRCitationManagerTests

// TEST CASES BELOW THIS POINT

- (void)setUp {
    [super setUp];
    
    // Given
    self.mockDelegate = [[MockCitationDelegate alloc] init];
    self.citationManager = [[ACRCitationManager alloc] initWithDelegate:self.mockDelegate];
}

- (void)tearDown {
    self.citationManager = nil;
    self.mockDelegate = nil;
    [super tearDown];
}

/// Test that citation manager initializes correctly with delegate
- (void)testInitializationWithDelegate {
    // Given
    MockCitationDelegate *delegate = [[MockCitationDelegate alloc] init];
    
    // When
    ACRCitationManager *manager = [[ACRCitationManager alloc] initWithDelegate:delegate];
    
    // Then
    XCTAssertNotNil(manager, @"Citation manager should not be nil");
}

/// Test building citations from attributed string with TextBlock citations
- (void)testBuildCitationsFromAttributedStringWithTextBlockCitations {
    // Given
    NSString *inputText = @"This text has [1](cite:0) and [Reference 2](cite:1) citations.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When
    NSMutableAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString references:@[]];
    
    // Then
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertTrue([result isKindOfClass:[NSMutableAttributedString class]], @"Result should be NSMutableAttributedString");
    
    // The text should be processed (citations replaced with attachments)
    XCTAssertNotEqual(result.length, inputText.length, @"Result length should be different due to citation processing");
}

/// Test building citations from attributed string without citations
- (void)testBuildCitationsFromAttributedStringWithoutCitations {
    // Given
    NSString *inputText = @"This text has no citations in it at all.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When
    NSMutableAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString references:@[]];
    
    // Then
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertEqual(result.length, inputText.length, @"Result length should be same as input when no citations");
    XCTAssertEqualObjects(result.string, inputText, @"Result string should be same as input when no citations");
}

/// Test building citations from attributed string with malformed citations
- (void)testBuildCitationsFromAttributedStringWithMalformedCitations {
    // Given
    NSString *inputText = @"This text has [malformed](not-cite:0) and [incomplete](cite: citations.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When
    NSMutableAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString references:@[]];
    
    // Then
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertEqual(result.length, inputText.length, @"Result should be unchanged for malformed citations");
    XCTAssertEqualObjects(result.string, inputText, @"Result string should be same as input for malformed citations");
}

/// Test building citations from attributed string with multiple valid citations
- (void)testBuildCitationsFromAttributedStringWithMultipleCitations {
    // Given
    NSString *inputText = @"Start [1](cite:0) middle [A](cite:1) and [Long Citation Text](cite:0) end.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When
    NSMutableAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString references:@[]];
    
    // Then
    XCTAssertNotNil(result, @"Result should not be nil");
    
    // Check for text attachments in the result
    __block NSInteger attachmentCount = 0;
    [result enumerateAttribute:NSAttachmentAttributeName
                       inRange:NSMakeRange(0, result.length)
                       options:0
                    usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
        if (attachment != nil) {
            attachmentCount++;
        }
    }];
    
    XCTAssertEqual(attachmentCount, 3, @"Should have 3 text attachments for 3 citations");
}

/// Test empty attributed string
- (void)testBuildEmptyAttributedString {
    // Given
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:@""];
    
    // When
    NSMutableAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString references:@[]];
    
    // Then
    XCTAssertNotNil(result, @"Result should not be nil for empty string");
    XCTAssertEqual(result.length, 0, @"Result should be empty for empty input");
}

/// Test RichTextBlock parsing (currently returns unchanged)
- (void)testParseAttributedStringWithCitations {
    // Given
    NSString *inputText = @"This is rich text block content.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When
    NSMutableAttributedString *result = [self.citationManager parseAttributedStringWithCitations:inputAttributedString];
    
    // Then
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertEqualObjects(result.string, inputText, @"RichTextBlock parser should return unchanged text for now");
}

/// Test TextBlockCitationParser directly
- (void)testTextBlockCitationParserExtractsCitationData {
    // Given
    ACRTextBlockCitationParser *parser = [[ACRTextBlockCitationParser alloc] init];
    NSString *inputText = @"Text with [Citation 1](cite:0) and [Ref B](cite:1) citations.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When
    NSArray<ACRCitationData *> *citations = [parser extractCitationData:inputAttributedString];
    
    // Then
    XCTAssertNotNil(citations, @"Citations array should not be nil");
    XCTAssertEqual(citations.count, 2, @"Should extract 2 citations");
    
    // Check first citation
    ACRCitationData *firstCitation = citations[0];
    XCTAssertEqualObjects(firstCitation.displayText, @"Citation 1", @"First citation display text should match");
    XCTAssertEqualObjects(firstCitation.referenceId, @"0", @"First citation reference ID should match");
    
    // Check second citation
    ACRCitationData *secondCitation = citations[1];
    XCTAssertEqualObjects(secondCitation.displayText, @"Ref B", @"Second citation display text should match");
    XCTAssertEqualObjects(secondCitation.referenceId, @"1", @"Second citation reference ID should match");
}

/// Test edge case with citation at start and end of text
- (void)testBuildCitationsFromAttributedStringWithCitationsAtBoundaries {
    // Given
    NSString *inputText = @"[Start](cite:0) middle text [End](cite:1)";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When
    NSMutableAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString references:@[]];
    
    // Then
    XCTAssertNotNil(result, @"Result should not be nil");
    
    // Check for text attachments
    __block NSInteger attachmentCount = 0;
    [result enumerateAttribute:NSAttachmentAttributeName
                       inRange:NSMakeRange(0, result.length)
                       options:0
                    usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
        if (attachment != nil) {
            attachmentCount++;
        }
    }];
    
    XCTAssertEqual(attachmentCount, 2, @"Should have 2 text attachments for citations at boundaries");
}

/// Test citation button tap functionality with mock tap handler
- (void)testCitationButtonTapFunctionality {
    // Given
    NSString *inputText = @"This has a [Test Citation](cite:123) in it.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    __block BOOL tapHandlerCalled = NO;
    __block NSDictionary *receivedCitationData = nil;
    __block id receivedSender = nil;
    
    // Create a citation parser with a mock tap handler
    ACRTextBlockCitationParser *parser = [[ACRTextBlockCitationParser alloc] init];
    parser.tapHandler = ^(id sender, NSDictionary *citationData) {
        tapHandlerCalled = YES;
        receivedCitationData = citationData;
        receivedSender = sender;
    };
    
    // When
    NSMutableAttributedString *result = [parser parseAttributedString:inputAttributedString tapHandler:parser.tapHandler];
    
    // Extract the button from the text attachment
    __block UIButton *citationButton = nil;
    [result enumerateAttribute:NSAttachmentAttributeName 
                       inRange:NSMakeRange(0, result.length) 
                       options:0 
                    usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
        if ([attachment isKindOfClass:[ACRViewTextAttachment class]]) {
            ACRViewTextAttachment *viewAttachment = (ACRViewTextAttachment *)attachment;
            // Access the button through the direct provider
            if ([viewAttachment.viewProvider respondsToSelector:@selector(view)]) {
                UIView *view = [(id)viewAttachment.viewProvider view];
                if ([view isKindOfClass:[UIButton class]]) {
                    citationButton = (UIButton *)view;
                    *stop = YES;
                }
            }
        }
    }];
    
    // Simulate button tap
    if (citationButton) {
        [parser citationButtonTapped:citationButton];
    }
    
    // Then
    XCTAssertNotNil(citationButton, @"Citation button should be found in the text attachment");
    XCTAssertTrue(tapHandlerCalled, @"Tap handler should be called when button is tapped");
    XCTAssertNotNil(receivedCitationData, @"Citation data should be passed to tap handler");
    XCTAssertEqualObjects(receivedCitationData[@"displayText"], @"Test Citation", @"Display text should match");
    XCTAssertEqualObjects(receivedCitationData[@"referenceId"], @"123", @"Reference ID should match");
    XCTAssertEqual(receivedSender, citationButton, @"Sender should be the tapped button");
}

/// Test citation data storage and retrieval from button
- (void)testCitationDataStorageInButton {
    // Given
    NSDictionary *testCitationData = @{
        @"displayText": @"Sample Citation",
        @"referenceId": @"456"
    };
    
    ACRCitationParser *parser = [[ACRTextBlockCitationParser alloc] init];
    
    // When
    ACRViewTextAttachment *attachment = [parser createCitationPillWithData:testCitationData];
    
    // Extract button from attachment
    UIButton *button = nil;
    if ([attachment.viewProvider respondsToSelector:@selector(view)]) {
        UIView *view = [(id)attachment.viewProvider view];
        if ([view isKindOfClass:[UIButton class]]) {
            button = (UIButton *)view;
        }
    }
    
    // Then
    XCTAssertNotNil(button, @"Button should be created and accessible");
    
    // Retrieve stored citation data
    NSDictionary *storedData = objc_getAssociatedObject(button, @"citationData");
    XCTAssertNotNil(storedData, @"Citation data should be stored with the button");
    XCTAssertEqualObjects(storedData[@"displayText"], @"Sample Citation", @"Stored display text should match");
    XCTAssertEqualObjects(storedData[@"referenceId"], @"456", @"Stored reference ID should match");
}

/// Test that tap handler is properly stored in parser
- (void)testTapHandlerStorageInParser {
    // Given
    ACRTextBlockCitationParser *parser = [[ACRTextBlockCitationParser alloc] init];
    
    __block BOOL testHandlerCalled = NO;
    void (^testTapHandler)(id, NSDictionary *) = ^(id sender, NSDictionary *citationData) {
        testHandlerCalled = YES;
    };
    
    NSString *inputText = @"Text with [citation](cite:1).";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When
    [parser parseAttributedString:inputAttributedString tapHandler:testTapHandler];
    
    // Then
    XCTAssertNotNil(parser.tapHandler, @"Tap handler should be stored in parser");
    
    // Test that stored handler works
    if (parser.tapHandler) {
        parser.tapHandler(nil, @{});
    }
    XCTAssertTrue(testHandlerCalled, @"Stored tap handler should be callable");
}

@end