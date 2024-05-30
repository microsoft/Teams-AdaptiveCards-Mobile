//
//  RatingElementTests.m
//  AdaptiveCardsTests
//
//  Created by Abhishek on 28/05/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "Enums.h"
#import "RatingInput.h"
#import "RatingLabel.h"
#import "ACOAdaptiveCardParseResult.h"
#import "ACOAdaptiveCard.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface AdaptiveCardsRatingElementTests : XCTestCase

@end

@implementation AdaptiveCardsRatingElementTests{
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

- (void)testRatingInputPropertieSerialization
{
    std::shared_ptr<AdaptiveCards::RatingInput> ratingInput = std::make_shared<AdaptiveCards::RatingInput>();
    
    ratingInput->SetValue(5);
    ratingInput->SetMax(10);
    ratingInput->SetHorizontalAlignment(AdaptiveCards::HorizontalAlignment::Left);
    ratingInput->SetRatingSize(AdaptiveCards::RatingSize::Large);
    ratingInput->SetRatingColor(AdaptiveCards::RatingColor::Marigold);

    XCTAssert(ratingInput->Serialize() == "{\"color\":\"marigold\",\"horizontalAlignment\":\"left\",\"max\":10.0,\"size\":\"large\",\"type\":\"Input.Rating\",\"value\":5.0}\n");
}

- (void)testRatingLabelPropertieSerialization
{
    std::shared_ptr<AdaptiveCards::RatingLabel> ratingLabel = std::make_shared<AdaptiveCards::RatingLabel>();
    
    ratingLabel->SetValue(5);
    ratingLabel->SetMax(10);
    ratingLabel->SetHorizontalAlignment(AdaptiveCards::HorizontalAlignment::Left);
    ratingLabel->SetRatingSize(AdaptiveCards::RatingSize::Medium);
    ratingLabel->SetRatingColor(AdaptiveCards::RatingColor::Neutral);

    XCTAssert(ratingLabel->Serialize() == "{\"horizontalAlignment\":\"left\",\"max\":10.0,\"type\":\"Rating\",\"value\":5.0}\n");
}

- (void)testRatingInputParsedResult
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"RatingInputValid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertTrue(cardParseResult.isValid);
}

- (void)testRatingLabelParsedResult
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"RatingLabelValid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertTrue(cardParseResult.isValid);
}

- (void)testRatingInputMaxValue
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"RatingInputInvalid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertFalse(cardParseResult.isValid);
}

@end
