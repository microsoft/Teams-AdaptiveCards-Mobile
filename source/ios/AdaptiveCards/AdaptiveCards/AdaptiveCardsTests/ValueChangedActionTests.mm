//
//  ValueChangedActionTests.mm
//  AdaptiveCardsTests
//
//  Created by reenulnu on 28/05/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "Enums.h"
#import "ChoiceSetInput.h"
#import "ACOAdaptiveCardParseResult.h"
#import "ACOAdaptiveCard.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ValueChangedActionTests : XCTestCase

@end

@implementation ValueChangedActionTests{
    NSBundle *_classBundle;
}

- (void)setUp
{
    _classBundle = [NSBundle bundleForClass:[self class]];
}

- (void)tearDown
{
    
}

- (void)testValueChangedActionValidParseResult
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"ValueChangedActionValid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertTrue(cardParseResult.isValid);
}

- (void)testValueChangedActionInValidParseResult
{
    NSString *payload = [NSString stringWithContentsOfFile:[_classBundle pathForResource:@"ValueChangedActionInvalid" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertFalse(cardParseResult.isValid);
}

@end
