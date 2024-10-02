//
//  AdaptiveCardCarouselTests.cpp
//  AdaptiveCardsTests
//
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "Enums.h"
#import "ACOAdaptiveCardParseResult.h"
#import "ACOAdaptiveCard.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CompoundButton.h"

@interface AdaptiveCardsCarouselTests : XCTestCase

@end

@implementation AdaptiveCardsCarouselTests{
    NSBundle *_classBundle;
}

- (void)setUp
{
    _classBundle = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCarouselValidParsedResult
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"Carousel.valid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertTrue(cardParseResult.isValid);
}

- (void)testCarouselInvalidParsedResult
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"Carousel.invalid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertFalse(cardParseResult.isValid);
}

@end

