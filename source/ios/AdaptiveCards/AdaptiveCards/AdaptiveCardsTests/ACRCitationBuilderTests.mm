//
//  ACRCitationBuilderTests.mm
//  AdaptiveCardsTests
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ACRCitationBuilder.h"
#import "ACRCitationBuilderDelegate.h"
#import "ACICitationPresenter.h"
#import "ACOCitation.h"
#import "ACOReference.h"

#pragma mark - Mock: Builder Delegate (analytics)

@interface MockBuilderDelegate : NSObject <ACRCitationBuilderDelegate>
@property (nonatomic, strong) NSMutableArray<ACOCitation *> *tappedCitations;
@property (nonatomic, strong) NSMutableArray<ACOReference *> *tappedReferences;
@end

@implementation MockBuilderDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _tappedCitations = [NSMutableArray array];
        _tappedReferences = [NSMutableArray array];
    }
    return self;
}

- (void)citationBuilder:(ACRCitationBuilder *)citationBuilder
         didTapCitation:(ACOCitation *)citation
          referenceData:(ACOReference *)referenceData {
    [self.tappedCitations addObject:citation];
    if (referenceData) {
        [self.tappedReferences addObject:referenceData];
    }
}

@end

#pragma mark - Mock: Citation Presenter (builder tests)

@interface MockBuilderCitationPresenter : NSObject <ACICitationPresenter>
@property (nonatomic, strong) NSMutableArray<ACOCitation *> *handledCitations;
@end

@implementation MockBuilderCitationPresenter

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

// TEST CASES BELOW THIS POINT

#pragma mark - ACRCitationBuilder Tests

@interface ACRCitationBuilderTests : XCTestCase
@property (nonatomic, strong) MockBuilderDelegate *mockDelegate;
@property (nonatomic, strong) ACRCitationBuilder *builder;
@property (nonatomic, strong) MockBuilderCitationPresenter *mockPresenter;
@property (nonatomic, strong) ACOReference *mockReference;
@property (nonatomic, strong) NSArray<ACOReference *> *references;
@end

@implementation ACRCitationBuilderTests

- (void)setUp {
    [super setUp];
    self.mockDelegate = [[MockBuilderDelegate alloc] init];
    self.builder = [[ACRCitationBuilder alloc] initWithDelegate:self.mockDelegate];
    self.mockPresenter = [[MockBuilderCitationPresenter alloc] init];
    self.mockReference = [[ACOReference alloc] init];
    self.references = @[self.mockReference];
}

- (void)tearDown {
    self.builder = nil;
    self.mockDelegate = nil;
    self.mockPresenter = nil;
    self.mockReference = nil;
    self.references = nil;
    [super tearDown];
}

/// ACRCitationBuilder initializes successfully with a delegate.
- (void)testBuilderInitialization {
    // Given: A valid builder delegate

    // When: Initializing the builder
    ACRCitationBuilder *newBuilder = [[ACRCitationBuilder alloc] initWithDelegate:self.mockDelegate];

    // Then: Builder instance should be non-nil
    XCTAssertNotNil(newBuilder, @"Builder should initialize successfully with a delegate");
}

/// buildCitationsFromAttributedString returns non-nil output for text with inline tokens.
- (void)testBuildCitationsFromAttributedString_returnsNonNil {
    // Given: Input text containing an inline citation token
    NSAttributedString *input = [[NSAttributedString alloc]
                                 initWithString:@"Result with {{cite:0}} inline citation."];

    // When: Building citations
    NSAttributedString *result = [self.builder buildCitationsFromAttributedString:input
                                                                       references:self.references
                                                                        presenter:self.mockPresenter
                                                                            theme:ACRThemeLight];

    // Then: Result should be non-nil with content
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertTrue(result.length > 0, @"Result should have content");
}

/// buildCitationsFromAttributedString handles an empty input without crashing.
- (void)testBuildCitationsFromAttributedString_handlesEmptyInput {
    // Given: An empty attributed string
    NSAttributedString *emptyInput = [[NSAttributedString alloc] initWithString:@""];

    // When: Building citations on empty input
    NSAttributedString *result = [self.builder buildCitationsFromAttributedString:emptyInput
                                                                       references:self.references
                                                                        presenter:self.mockPresenter
                                                                            theme:ACRThemeLight];

    // Then: Should return an empty string without crashing
    XCTAssertNotNil(result, @"Result should not be nil even for empty input");
    XCTAssertEqual(result.length, 0, @"Result should be empty for empty input");
}

/// buildCitationsFromNSLinkAttributesInAttributedString returns non-nil output for NSLink citations.
- (void)testBuildCitationsFromNSLinkAttributes_returnsNonNil {
    // Given: An attributed string with an NSLink cite URL
    NSMutableAttributedString *input = [[NSMutableAttributedString alloc]
                                        initWithString:@"Reference click here."];
    [input addAttribute:NSLinkAttributeName
                  value:[NSURL URLWithString:@"cite:0"]
                  range:NSMakeRange(10, 10)];

    // When: Building citations from NSLink attributes
    NSAttributedString *result = [self.builder buildCitationsFromNSLinkAttributesInAttributedString:input
                                                                                         references:self.references
                                                                                          presenter:self.mockPresenter
                                                                                              theme:ACRThemeLight];

    // Then: Result should be non-nil with content
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertTrue(result.length > 0, @"Result should have content");
}

/// buildCitationAttachmentWithCitation returns an attributed string for a valid citation.
- (void)testBuildCitationAttachment_returnsNonNilForValidCitation {
    // Given: A citation whose referenceIndex resolves to a known reference
    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"1"
                                                      referenceIndex:@0
                                                               theme:ACRThemeLight];

    // When: Building the citation attachment
    NSAttributedString *result = [self.builder buildCitationAttachmentWithCitation:citation
                                                                         references:self.references
                                                                          presenter:self.mockPresenter];

    // Then: A non-nil attributed string should be returned
    XCTAssertNotNil(result, @"Result should not be nil for a valid citation");
}

/// buildCitationAttachmentWithCitation falls back to displayText when no reference is found.
- (void)testBuildCitationAttachment_returnsFallbackTextForNoReference {
    // Given: A citation whose referenceIndex does not match any reference
    ACOCitation *citation = [[ACOCitation alloc] initWithDisplayText:@"[unknown]"
                                                      referenceIndex:@999
                                                               theme:ACRThemeLight];

    // When: Building with an empty references array
    NSAttributedString *result = [self.builder buildCitationAttachmentWithCitation:citation
                                                                         references:@[]
                                                                          presenter:self.mockPresenter];

    // Then: Should fall back to the citation's displayText
    XCTAssertNotNil(result, @"Result should not be nil even when reference is missing");
    XCTAssertEqualObjects(result.string, @"[unknown]",
                          @"Should use displayText as the fallback when no reference is found");
}

@end
