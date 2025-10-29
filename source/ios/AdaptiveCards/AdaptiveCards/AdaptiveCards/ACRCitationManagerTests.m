//
//  ACRCitationManagerTests.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ACRCitationManager.h"
#import "ACRCitationManagerDelegate.h"
#import "ACRTextBlockCitationParser.h"
#import "ACRRichTextBlockCitationParser.h"

@interface ACRCitationManagerTests : XCTestCase <ACRCitationManagerDelegate>

@property (nonatomic, strong) ACRCitationManager *citationManager;
@property (nonatomic, strong) NSArray<NSDictionary *> *testReferences;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *citationTapEvents;

@end

@implementation ACRCitationManagerTests

- (void)setUp {
    [super setUp];
    
    // Given: A citation manager with test delegate
    self.citationManager = [[ACRCitationManager alloc] initWithDelegate:self];
    
    // Given: Test references data
    self.testReferences = @[
        @{
            @"id": @"0",
            @"title": @"The Impact of Machine Learning on Modern Computing",
            @"abstract": @"This paper explores how machine learning has revolutionized computing paradigms and discusses future implications for the field.",
            @"url": @"https://example.com/ml-computing"
        },
        @{
            @"id": @"1", 
            @"title": @"Sustainable Software Development Practices",
            @"abstract": @"An analysis of environmentally conscious programming methodologies and their adoption in enterprise environments.",
            @"url": @"https://example.com/sustainable-dev"
        }
    ];
    
    // Given: Array to track citation tap events
    self.citationTapEvents = [NSMutableArray array];
}

- (void)tearDown {
    self.citationManager = nil;
    self.testReferences = nil;
    self.citationTapEvents = nil;
    [super tearDown];
}

// TEST CASES BELOW THIS POINT

/// Tests that CitationManager initializes correctly with a delegate
- (void)testCitationManagerInitialization {
    // Given: A citation manager delegate
    id<ACRCitationManagerDelegate> delegate = self;
    
    // When: Creating a citation manager with delegate
    ACRCitationManager *manager = [[ACRCitationManager alloc] initWithDelegate:delegate];
    
    // Then: Manager should be properly initialized
    XCTAssertNotNil(manager, @"Citation manager should be initialized");
    XCTAssertEqual(manager.delegate, delegate, @"Delegate should be set correctly");
}

/// Tests TextBlock citation parsing with references and delegation
- (void)testTextBlockCitationParsingWithReferences {
    // Given: Input text with citation format
    NSString *inputText = @"Machine learning has changed computing [1](cite:0) and sustainable practices are important [2](cite:1).";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When: Parsing attributed string with references
    NSMutableAttributedString *result = [self.citationManager parseAttributedString:inputAttributedString 
                                                                    withReferences:self.testReferences];
    
    // Then: Result should contain text attachments for citations
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertTrue(result.length > 0, @"Result should have content");
    
    // Then: Original citation patterns should be replaced
    NSString *resultString = result.string;
    XCTAssertFalse([resultString containsString:@"[1](cite:0)"], @"Citation pattern should be replaced");
    XCTAssertFalse([resultString containsString:@"[2](cite:1)"], @"Citation pattern should be replaced");
}

/// Tests RichTextBlock citation parsing with references and delegation
- (void)testRichTextBlockCitationParsingWithReferences {
    // Given: Input text for RichTextBlock citations
    NSString *inputText = @"Research shows significant improvements.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When: Parsing attributed string for RichTextBlock citations
    NSMutableAttributedString *result = [self.citationManager parseAttributedStringWithCitations:inputAttributedString 
                                                                                   withReferences:self.testReferences];
    
    // Then: Result should be processed without errors
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertEqual(result.length, inputAttributedString.length, @"Length should be preserved for RichTextBlock");
}

/// Tests citation manager delegation when citation is tapped through parser
- (void)testCitationTappedDelegation {
    // Given: Citation and reference data
    NSDictionary *citationData = @{
        @"displayText": @"1",
        @"referenceId": @"0"
    };
    NSDictionary *referenceData = self.testReferences[0];
    
    // When: Simulating a citation tap from parser
    [self.citationManager citationParser:self.citationManager.textBlockParser 
                    didTapCitationWithData:citationData 
                             referenceData:referenceData];
    
    // Then: Delegate method should be called
    XCTAssertEqual(self.citationTapEvents.count, 1, @"One citation tap event should be recorded");
    
    NSDictionary *tapEvent = self.citationTapEvents.firstObject;
    XCTAssertEqualObjects(tapEvent[@"citationData"], citationData, @"Citation data should match");
    XCTAssertEqualObjects(tapEvent[@"referenceData"], referenceData, @"Reference data should match");
}

/// Tests citation manager with empty references array
- (void)testCitationParsingWithEmptyReferences {
    // Given: Input text with citations but empty references
    NSString *inputText = @"This has a citation [1](cite:missing).";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    NSArray<NSDictionary *> *emptyReferences = @[];
    
    // When: Parsing with empty references
    NSMutableAttributedString *result = [self.citationManager parseAttributedString:inputAttributedString 
                                                                    withReferences:emptyReferences];
    
    // Then: Should handle gracefully without crashes
    XCTAssertNotNil(result, @"Result should not be nil even with empty references");
}

/// Tests citation manager with nil references array
- (void)testCitationParsingWithNilReferences {
    // Given: Input text with citations but nil references
    NSString *inputText = @"This has a citation [1](cite:test).";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When: Parsing with nil references
    NSMutableAttributedString *result = [self.citationManager parseAttributedString:inputAttributedString 
                                                                    withReferences:nil];
    
    // Then: Should handle gracefully without crashes
    XCTAssertNotNil(result, @"Result should not be nil even with nil references");
}

/// Tests that TextBlock parser is lazily instantiated
- (void)testTextBlockParserLazyInstantiation {
    // Given: A new citation manager
    ACRCitationManager *manager = [[ACRCitationManager alloc] initWithDelegate:self];
    
    // When: Accessing textBlockParser property
    ACRTextBlockCitationParser *parser = manager.textBlockParser;
    
    // Then: Parser should be created and cached
    XCTAssertNotNil(parser, @"TextBlock parser should be created");
    XCTAssertTrue([parser isKindOfClass:[ACRTextBlockCitationParser class]], @"Should be correct parser type");
    
    // Then: Second access should return same instance
    ACRTextBlockCitationParser *parser2 = manager.textBlockParser;
    XCTAssertEqual(parser, parser2, @"Should return cached instance");
}

/// Tests that RichTextBlock parser is lazily instantiated
- (void)testRichTextBlockParserLazyInstantiation {
    // Given: A new citation manager
    ACRCitationManager *manager = [[ACRCitationManager alloc] initWithDelegate:self];
    
    // When: Accessing richTextBlockParser property
    ACRRichTextBlockCitationParser *parser = manager.richTextBlockParser;
    
    // Then: Parser should be created and cached
    XCTAssertNotNil(parser, @"RichTextBlock parser should be created");
    XCTAssertTrue([parser isKindOfClass:[ACRRichTextBlockCitationParser class]], @"Should be correct parser type");
    
    // Then: Second access should return same instance
    ACRRichTextBlockCitationParser *parser2 = manager.richTextBlockParser;
    XCTAssertEqual(parser, parser2, @"Should return cached instance");
}

/// Tests that parser delegate is properly configured
- (void)testParserDelegateConfiguration {
    // Given: A citation manager
    ACRCitationManager *manager = [[ACRCitationManager alloc] initWithDelegate:self];
    
    // When: Accessing parsers
    ACRTextBlockCitationParser *textBlockParser = manager.textBlockParser;
    ACRRichTextBlockCitationParser *richTextParser = manager.richTextBlockParser;
    
    // Then: Delegates should be set to the manager
    XCTAssertEqual(textBlockParser.delegate, manager, @"TextBlock parser delegate should be set to manager");
    XCTAssertEqual(richTextParser.delegate, manager, @"RichTextBlock parser delegate should be set to manager");
}

#pragma mark - ACRCitationManagerDelegate

- (UIViewController * _Nullable)parentViewControllerForCitationPresentation {
    // Return a mock view controller for testing
    return [[UIViewController alloc] init];
}

- (NSArray<NSDictionary *> * _Nullable)referencesForCitations {
    return self.testReferences;
}

- (void)citationManager:(ACRCitationManager *)citationManager 
    didTapCitationWithData:(NSDictionary *)citationData 
             referenceData:(NSDictionary * _Nullable)referenceData {
    
    // Record the tap event for verification
    NSDictionary *tapEvent = @{
        @"citationData": citationData ?: @{},
        @"referenceData": referenceData ?: @{}
    };
    [self.citationTapEvents addObject:tapEvent];
}

@end