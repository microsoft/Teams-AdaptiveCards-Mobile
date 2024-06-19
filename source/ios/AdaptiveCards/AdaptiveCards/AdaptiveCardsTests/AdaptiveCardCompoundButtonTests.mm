//
//  CompoundButtonTests.m
//  AdaptiveCardsTests
//
//  Created by Abhishek on 16/06/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "Enums.h"
#import "ACOAdaptiveCardParseResult.h"
#import "ACOAdaptiveCard.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CompoundButton.h"

@interface AdaptiveCardsCompoundButtonTests : XCTestCase

@end

@implementation AdaptiveCardsCompoundButtonTests{
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

- (void)testCompoundButtonPropertieSerialization
{
    std::shared_ptr<AdaptiveCards::CompoundButton> compoundButton = std::make_shared<AdaptiveCards::CompoundButton>();
    
    compoundButton->setTitle("Title");
    compoundButton->setBadge("Badge");
    compoundButton->setDescription("Description");
    std::shared_ptr<AdaptiveCards::IconInfo> icon = std::make_shared<AdaptiveCards::IconInfo>();
    icon->SetName("Name");
    icon->setIconSize(AdaptiveCards::IconSize::Large);
    icon->setIconStyle(AdaptiveCards::IconStyle::Filled);
    icon->setForgroundColor(AdaptiveCards::ForegroundColor::Good);
    compoundButton->setIcon(icon);
    XCTAssert(compoundButton->Serialize() == "{\"badge\":\"Badge\",\"description\":\"Description\",\"icon\":{\"color\":\"Good\",\"name\":\"Name\",\"size\":\"Large\",\"style\":\"Filled\"},\"title\":\"Title\",\"type\":\"CompoundButton\"}\n");
}

- (void)testCompoundButtonValidParsedResult
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"CompoundButtonValid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertTrue(cardParseResult.isValid);
}

- (void)testCompoundButtonInvalidParsedResult
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"CompoundButtonInvalid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertFalse(cardParseResult.isValid);
}

@end
