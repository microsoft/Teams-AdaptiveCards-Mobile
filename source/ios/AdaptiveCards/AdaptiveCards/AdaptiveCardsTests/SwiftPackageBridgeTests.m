//
//  SwiftPackageBridgeTests.m
//  AdaptiveCardsTests
//
//  Tests verifying Swift Package Manager integration works correctly.
//

#import <XCTest/XCTest.h>
@import AdaptiveCards;

@interface SwiftPackageBridgeTests : XCTestCase
@end

@implementation SwiftPackageBridgeTests

- (void)testSwiftPackageIsAccessible {
    // Test that the Swift Adaptive Card module is accessible from ObjC
    XCTAssertTrue([SwiftAdaptiveCardParser class] != nil, @"SwiftAdaptiveCardParser should be accessible");
}

- (void)testSwiftElementPropertyAccessorIsAccessible {
    // Test that the property accessor class is accessible
    XCTAssertTrue([SwiftElementPropertyAccessor class] != nil, @"SwiftElementPropertyAccessor should be accessible");
}

- (void)testBasicSwiftParsing {
    // Test basic parsing through Swift module
    NSString *json = @"{"
        @"\"type\": \"AdaptiveCard\","
        @"\"version\": \"1.5\","
        @"\"body\": ["
            @"{ \"type\": \"TextBlock\", \"text\": \"Hello from ObjC\" }"
        @"]"
    @"}";
    
    SwiftAdaptiveCardParseResult *result = [SwiftAdaptiveCardParser parseWithPayload:json];
    XCTAssertNotNil(result, @"Parse result should not be nil");
}

@end
