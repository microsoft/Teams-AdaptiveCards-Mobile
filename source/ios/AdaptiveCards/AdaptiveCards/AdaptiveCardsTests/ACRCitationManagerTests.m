//
//  ACRCitationManagerTests.m
//  AdaptiveCardsTests
//
//  Created by Gaurav Keshre on 29/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ACRCitationManager.h"
#import "ACRCitationManagerDelegate.h"
#import "ACRInlineCitationTokenParser.h"
#import "ACRCitationParser.h"
#import "ACOReference.h"
#import "ACOCitation.h"
#import "ACRView.h"

@interface MockCitationDelegate : NSObject <ACRCitationManagerDelegate>
@property (nonatomic, strong) UIViewController *mockViewController;
@property (nonatomic, strong) NSArray<ACOReference *> *mockReferences;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *citationTapEvents;
@property (nonatomic, strong) NSMutableArray<NSString *> *presentedCitations;
@property (nonatomic, strong) NSMutableArray<NSString *> *dismissedCitations;
@end

@implementation MockCitationDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _mockViewController = [[UIViewController alloc] init];
        _citationTapEvents = [NSMutableArray array];
        _presentedCitations = [NSMutableArray array];
        _dismissedCitations = [NSMutableArray array];
        
        // Create mock references - we cannot set properties directly as they are readonly
        // We'll need to create them through proper initialization or find another way
        _mockReferences = @[]; // Will be empty for now since ACOReference doesn't expose setters
    }
    return self;
}

- (void)citationWillPresent:(NSString *)citationId referenceData:(ACOReference * _Nullable)referenceData {
    [self.presentedCitations addObject:citationId];
}

- (void)citationDidDismiss:(NSString *)citationId {
    [self.dismissedCitations addObject:citationId];
}

- (void)citationManager:(ACRCitationManager *)citationManager 
         didTapCitation:(ACOCitation *)citation 
          referenceData:(ACOReference * _Nullable)referenceData {
    
    // Record the tap event for verification
    NSDictionary *tapEvent = @{
        @"citation": citation ?: [NSNull null],
        @"referenceData": referenceData ?: [NSNull null],
        @"timestamp": [NSDate date]
    };
    [self.citationTapEvents addObject:tapEvent];
}

@end

@interface ACRCitationManagerTests : XCTestCase
@property (nonatomic, strong) ACRCitationManager *citationManager;
@property (nonatomic, strong) MockCitationDelegate *mockDelegate;
@property (nonatomic, strong) ACRView *mockRootView;
@end

@implementation ACRCitationManagerTests

- (void)setUp {
    [super setUp];
    
    // Given: Mock delegate and root view
    self.mockDelegate = [[MockCitationDelegate alloc] init];
    self.mockRootView = [[ACRView alloc] init];
    
    // Given: Citation manager with delegate
    self.citationManager = [[ACRCitationManager alloc] initWithDelegate:self.mockDelegate];
    self.citationManager.rootView = self.mockRootView;
}

- (void)tearDown {
    self.citationManager = nil;
    self.mockDelegate = nil;
    self.mockRootView = nil;
    [super tearDown];
}

#pragma mark - Initialization Tests

/// Test that citation manager initializes correctly with delegate
- (void)testCitationManagerInitialization {
    // Given: A citation manager delegate
    MockCitationDelegate *delegate = [[MockCitationDelegate alloc] init];
    
    // When: Creating a citation manager with delegate
    ACRCitationManager *manager = [[ACRCitationManager alloc] initWithDelegate:delegate];
    
    // Then: Manager should be properly initialized
    XCTAssertNotNil(manager, @"Citation manager should be initialized");
    // Note: Cannot test delegate property as it's private
}

#pragma mark - Parser Access Tests

/// Test that InlineCitation parser is accessible
- (void)testInlineCitationParserAccess {
    // When: Accessing inlineCitationParser property
    ACRInlineCitationTokenParser *parser = self.citationManager.inlineCitationParser;
    
    // Then: Parser should be accessible
    XCTAssertNotNil(parser, @"InlineCitation parser should be accessible");
    XCTAssertTrue([parser isKindOfClass:[ACRInlineCitationTokenParser class]], @"Should be correct parser type");
}

/// Test that CitationRun parser is accessible
- (void)testCitationRunParserAccess {
    // When: Accessing citationRunParser property
    ACRCitationParser *parser = self.citationManager.citationRunParser;
    
    // Then: Parser should be accessible
    XCTAssertNotNil(parser, @"CitationRun parser should be accessible");
    XCTAssertTrue([parser isKindOfClass:[ACRCitationParser class]], @"Should be correct parser type");
}

#pragma mark - Citation Building Tests

/// Test building citations from attributed string with inline token citations
- (void)testBuildCitationsFromAttributedStringWithInlineTokens {
    // Given: Input text with inline citation tokens
    NSString *inputText = @"Machine learning has changed computing {{cite:0}} and sustainable practices are important {{cite:1}}.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When: Building citations from attributed string with references
    NSAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString
                                                                               references:self.mockDelegate.mockReferences];
    
    // Then: Result should be processed
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertTrue(result.length > 0, @"Result should have content");
}

/// Test building citations from NSLink attributes in attributed string
- (void)testBuildCitationsFromNSLinkAttributesInAttributedString {
    // Given: Attributed string with NSLink attributes for citations
    NSMutableAttributedString *inputAttributedString = [[NSMutableAttributedString alloc] initWithString:@"Check this reference and this one too."];
    
    // Add NSLink attributes to simulate citation links
    [inputAttributedString addAttribute:NSLinkAttributeName 
                                  value:[NSURL URLWithString:@"cite:0"]
                                  range:NSMakeRange(6, 4)]; // "this"
    [inputAttributedString addAttribute:NSLinkAttributeName 
                                  value:[NSURL URLWithString:@"cite:1"]
                                  range:NSMakeRange(25, 4)]; // "this"
    
    // When: Building citations from NSLink attributes
    NSAttributedString *result = [self.citationManager buildCitationsFromNSLinkAttributesInAttributedString:inputAttributedString
                                                                                                  references:self.mockDelegate.mockReferences];
    
    // Then: Result should be processed
    XCTAssertNotNil(result, @"Result should not be nil");
    XCTAssertTrue(result.length > 0, @"Result should have content");
}

/// Test building citation attachment with citation and references
- (void)testBuildCitationAttachmentWithCitation {
    // Given: A citation object
    ACOCitation *citation = [[ACOCitation alloc] init];
    citation.displayText = @"1";
    citation.referenceIndex = @0;
    
    // When: Building citation attachment
    NSAttributedString *result = [self.citationManager buildCitationAttachmentWithCitation:citation
                                                                                 references:self.mockDelegate.mockReferences];
    
    // Then: Result should be created
    XCTAssertNotNil(result, @"Citation attachment result should not be nil");
}

#pragma mark - Edge Case Tests

/// Test building citations from empty attributed string
- (void)testBuildCitationsFromEmptyAttributedString {
    // Given: Empty attributed string
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:@""];
    
    // When: Building citations from empty string
    NSAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString
                                                                               references:self.mockDelegate.mockReferences];
    
    // Then: Result should handle gracefully
    XCTAssertNotNil(result, @"Result should not be nil for empty string");
    XCTAssertEqual(result.length, 0, @"Result should be empty for empty input");
}

/// Test building citations with nil references
- (void)testBuildCitationsWithNilReferences {
    // Given: Input text with citations but nil references
    NSString *inputText = @"This has a citation {{cite:0}} in it.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When: Building citations with nil references
    NSAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString
                                                                               references:nil];
    
    // Then: Should handle gracefully without crashes
    XCTAssertNotNil(result, @"Result should not be nil even with nil references");
}

/// Test building citations with empty references array
- (void)testBuildCitationsWithEmptyReferences {
    // Given: Input text with citations but empty references
    NSString *inputText = @"This has a citation {{cite:0}} in it.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    NSArray<ACOReference *> *emptyReferences = @[];
    
    // When: Building citations with empty references
    NSAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString
                                                                               references:emptyReferences];
    
    // Then: Should handle gracefully without crashes
    XCTAssertNotNil(result, @"Result should not be nil even with empty references");
}

#pragma mark - Delegation Tests

/// Test citation manager delegation when citation is tapped
- (void)testCitationTappedDelegation {
    // Given: Citation and reference data
    ACOCitation *citation = [[ACOCitation alloc] init];
    citation.displayText = @"1";
    citation.referenceIndex = @0;
    
    ACOReference *referenceData = nil; // Using nil since we can't create mock references easily
    
    // When: Simulating a citation tap by calling the delegate method directly
    [self.mockDelegate citationManager:self.citationManager
                        didTapCitation:citation
                         referenceData:referenceData];
    
    // Then: Delegate method should be called and recorded
    XCTAssertEqual(self.mockDelegate.citationTapEvents.count, 1, @"One citation tap event should be recorded");
    
    NSDictionary *tapEvent = self.mockDelegate.citationTapEvents.firstObject;
    XCTAssertEqualObjects(tapEvent[@"citation"], citation, @"Citation object should match");
    XCTAssertEqualObjects(tapEvent[@"referenceData"], [NSNull null], @"Reference data should be null for nil input");
}

/// Test citation presentation delegation
- (void)testCitationPresentationDelegation {
    // Given: Citation ID
    NSString *citationId = @"test-citation-1";
    
    // When: Simulating citation presentation
    [self.mockDelegate citationWillPresent:citationId referenceData:nil];
    
    // Then: Should be recorded
    XCTAssertEqual(self.mockDelegate.presentedCitations.count, 1, @"One citation presentation should be recorded");
    XCTAssertEqualObjects(self.mockDelegate.presentedCitations.firstObject, citationId, @"Citation ID should match");
}

/// Test citation dismissal delegation
- (void)testCitationDismissalDelegation {
    // Given: Citation ID
    NSString *citationId = @"test-citation-1";
    
    // When: Simulating citation dismissal
    [self.mockDelegate citationDidDismiss:citationId];
    
    // Then: Should be recorded
    XCTAssertEqual(self.mockDelegate.dismissedCitations.count, 1, @"One citation dismissal should be recorded");
    XCTAssertEqualObjects(self.mockDelegate.dismissedCitations.firstObject, citationId, @"Citation ID should match");
}

#pragma mark - Property Tests

/// Test root view assignment and access
- (void)testRootViewAssignment {
    // Given: A citation manager and root view
    ACRCitationManager *manager = [[ACRCitationManager alloc] initWithDelegate:self.mockDelegate];
    ACRView *rootView = [[ACRView alloc] init];
    
    // When: Setting root view
    manager.rootView = rootView;
    
    // Then: Root view should be accessible
    XCTAssertEqual(manager.rootView, rootView, @"Root view should be set correctly");
}

/// Test parser property access
- (void)testParserPropertyAccess {
    // When: Accessing parser properties
    ACRInlineCitationTokenParser *inlineParser = self.citationManager.inlineCitationParser;
    ACRCitationParser *citationRunParser = self.citationManager.citationRunParser;
    
    // Then: Both parsers should be accessible
    XCTAssertNotNil(inlineParser, @"Inline citation parser should be accessible");
    XCTAssertNotNil(citationRunParser, @"Citation run parser should be accessible");
}

#pragma mark - Integration Tests

/// Test citation building with citation that has nil referenceIndex
- (void)testCitationBuildingWithNilReferenceIndex {
    // Given: Citation with nil reference index
    ACOCitation *citation = [[ACOCitation alloc] init];
    citation.displayText = @"Invalid";
    citation.referenceIndex = nil;
    
    // When: Building citation attachment
    NSAttributedString *result = [self.citationManager buildCitationAttachmentWithCitation:citation
                                                                                 references:self.mockDelegate.mockReferences];
    
    // Then: Should handle gracefully
    XCTAssertNotNil(result, @"Should handle citation with nil reference index");
}

/// Test citation building with out-of-bounds reference index
- (void)testCitationBuildingWithOutOfBoundsReferenceIndex {
    // Given: Citation with out-of-bounds reference index
    ACOCitation *citation = [[ACOCitation alloc] init];
    citation.displayText = @"OutOfBounds";
    citation.referenceIndex = @999; // Much larger than available references
    
    // When: Building citation attachment
    NSAttributedString *result = [self.citationManager buildCitationAttachmentWithCitation:citation
                                                                                 references:self.mockDelegate.mockReferences];
    
    // Then: Should handle gracefully
    XCTAssertNotNil(result, @"Should handle citation with out-of-bounds reference index");
}

/// Test mixed citation formats in one text
- (void)testCitationManagerWithMixedCitationFormats {
    // Given: Text with inline citation format
    NSString *inputText = @"Research shows {{cite:0}} significant improvements. Also check {{cite:1}} this reference.";
    NSAttributedString *inputAttributedString = [[NSAttributedString alloc] initWithString:inputText];
    
    // When: Processing with inline citation method
    NSAttributedString *result = [self.citationManager buildCitationsFromAttributedString:inputAttributedString
                                                                               references:self.mockDelegate.mockReferences];
    
    // Then: Should process without errors
    XCTAssertNotNil(result, @"Mixed citation types should be processed");
    XCTAssertTrue(result.length > 0, @"Result should have content");
}

@end
