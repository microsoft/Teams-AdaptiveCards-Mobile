//
//  Test.m
//
//
//  Created by Inyoung Woo on 5/7/21.
//

#import <AdaptiveCards/AdaptiveCards.h>
#import <AdaptiveCards/ACOAdaptiveCard.h>
#import <XCTest/XCTest.h>

@interface AdaptiveCardsTest : XCTestCase

@end

@implementation AdaptiveCardsTest

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample
{
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testSwiftToggleFunctionality
{
    // Ensure the toggle starts in a known state
    [ACOAdaptiveCard setUseSwiftImplementation:NO];
    XCTAssertFalse([ACOAdaptiveCard isSwiftImplementationEnabled], @"Swift implementation should be disabled initially");
    
    // Test enabling Swift implementation
    [ACOAdaptiveCard setUseSwiftImplementation:YES];
    XCTAssertTrue([ACOAdaptiveCard isSwiftImplementationEnabled], @"Swift implementation should be enabled after setting to YES");
    
    // Test disabling Swift implementation
    [ACOAdaptiveCard setUseSwiftImplementation:NO];
    XCTAssertFalse([ACOAdaptiveCard isSwiftImplementationEnabled], @"Swift implementation should be disabled after setting to NO");
}

- (void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
