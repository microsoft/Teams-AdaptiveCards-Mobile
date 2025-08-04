//
//  ADCIOSVisualizerUITests.m
//  ADCIOSVisualizerUITests
//
//  Created by jwoo on 6/2/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "AdaptiveCards/ACOHostConfigPrivate.h"
#import <AdaptiveCards/AdaptiveCards.h>
#import <XCTest/XCTest.h>
#include <string>

@interface ADCIOSVisualizerUITests : XCTestCase

@end

@implementation ADCIOSVisualizerUITests {
    XCUIApplication *testApp;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.

    if (testApp == nil) {
        testApp = [[XCUIApplication alloc] init];
        testApp.launchArguments = [NSArray arrayWithObject:@"ui-testing"];
        [testApp launch];
    }

    [self resetTestEnvironment];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)resetTestEnvironment
{
    XCUIElementQuery *buttons = testApp.buttons;
    const int cardDepthLimit = 3;

    // try to find Back button and tap it while it appears
    XCUIElement *backButton = buttons[@"Back"];

    int backButtonPressedCount = 0;
    while ([backButton exists] && backButtonPressedCount < cardDepthLimit) {
        [backButton tap];
        backButton = buttons[@"Back"];
        ++backButtonPressedCount;
    }

    // tap on delete all cards button
    [buttons[@"Delete All Cards"] tap];
}

- (void)openCardForVersion:(NSString *)version forCardType:(NSString *)type withCardName:(NSString *)scenarioName
{
    XCUIElementQuery *buttons = testApp.buttons;
    [buttons[version] tap];
    [buttons[type] tap];

    XCUIElementQuery *tables = testApp.tables;
    XCUIElement *table = [tables elementBoundByIndex:1];
    XCUIElementQuery *cell = [[table staticTexts] matchingIdentifier:scenarioName];

    // Interact with it when visible
    [[cell elementBoundByIndex:0] tap];
}

- (NSDictionary *)parseJsonToDictionary:(NSString *)json
{
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError;
    NSDictionary *parsedJsonData = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&jsonError];
    return parsedJsonData;
}

- (NSDictionary *)getInputsFromResultsDictionary:(NSDictionary *)results
{
    return [results objectForKey:@"inputs"];
}

- (NSString *)getInputsString
{
    XCUIElement *resultsTextView = [testApp.staticTexts elementMatchingType:XCUIElementTypeAny identifier:@"SubmitActionRetrievedResults"];
    return resultsTextView.label;
}

- (bool)verifyInputsAreEmpty
{
    return [@" " isEqualToString:[self getInputsString]];
}

- (void)tapOnButtonWithText:(NSString *)buttonText
{
    XCUIElementQuery *buttons = testApp.buttons;
    XCUIElement *button = buttons[buttonText];
    XCTAssertTrue([button exists]);
    [button tap];
}

- (void)verifyInput:(NSString *)inputId matchesExpectedValue:(NSString *)expectedValue inInputSet:(NSDictionary *)inputDictionary
{
    id inputValue = [inputDictionary objectForKey:inputId];

    XCTAssertTrue([expectedValue isEqualToString:inputValue], @"Input Id: %@ has value: %@ for expected value: %@", inputId, inputValue, expectedValue);
}

- (void)verifyNumberInput:(NSString *)inputId matchesExpectedValue:(NSString *)expectedValue inInputSet:(NSDictionary *)inputDictionary
{
    id inputValue = [[inputDictionary objectForKey:inputId] stringValue];

    XCTAssertTrue([expectedValue isEqualToString:inputValue], @"Input Id: %@ has value: %@ for expected value: %@", inputId, inputValue, expectedValue);
}

- (void)setDateOnInputDateWithId:(NSString *)Id andLabel:(NSString *)label forYear:(NSString *)year month:(NSString *)month day:(NSString *)day
{
    [self tapOnButtonWithText:Id];

    XCUIElement *enterTheDueDateDatePicker = testApp.datePickers[label];

    [[enterTheDueDateDatePicker.pickerWheels elementBoundByIndex:0] adjustToPickerWheelValue:month];

    [[enterTheDueDateDatePicker.pickerWheels elementBoundByIndex:1] adjustToPickerWheelValue:day];

    [[enterTheDueDateDatePicker.pickerWheels elementBoundByIndex:2] adjustToPickerWheelValue:year];

    // Dismiss the date picker
    [testApp.toolbars[@"Toolbar"].buttons[@"Done"] tap];
}

- (void)testSmokeTestActivityUpdateDate
{
    [self openCardForVersion:@"v1.5" forCardType:@"Scenarios" withCardName:@"ActivityUpdate.json"];

    [self tapOnButtonWithText:@"Set due date"];

    [self setDateOnInputDateWithId:@"dueDate"
                          andLabel:@"Enter the due date"
                           forYear:@"2021"
                             month:@"July"
                               day:@"15"];

    [self tapOnButtonWithText:@"Send"];

    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];

    [self verifyInput:@"dueDate" matchesExpectedValue:@"2021-07-15" inInputSet:inputs];
}

- (void)testSmokeTestActivityUpdateComment
{
    [self openCardForVersion:@"v1.5" forCardType:@"Scenarios" withCardName:@"ActivityUpdate.json"];

    XCUIElementQuery *buttons = testApp.buttons;
    [buttons[@"Comment"] tap];

    XCUIElementQuery *tables = testApp.tables;
    XCUIElement *chatWindow = tables[@"ChatWindow"];

    XCUIElement *commentTextInput = [chatWindow.textViews elementMatchingType:XCUIElementTypeAny identifier:@"comment"];
    [commentTextInput tap];
    [commentTextInput typeText:@"A comment"];

    [buttons[@"Done"] tap];
    [buttons[@"OK"] tap];

    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];

    [self verifyInput:@"comment" matchesExpectedValue:@"A comment" inInputSet:inputs];
}

- (void)testFocusOnValidationFailure
{
    [self openCardForVersion:@"v1.3" forCardType:@"Elements" withCardName:@"Input.Text.ErrorMessage.json"];

    [self tapOnButtonWithText:@"Submit"];

    XCUIElement *chatWindow = testApp.tables[@"ChatWindow"];
    XCUIElement *firstInput = [chatWindow.textFields elementMatchingType:XCUIElementTypeAny identifier:@"Required Input.Text *, This is a required input,"];

    XCTAssertTrue([firstInput valueForKey:@"hasKeyboardFocus"], "First input is not selected");
}

- (void)testLongPressAndDragRaiseNoEventInContainers
{
    [self openCardForVersion:@"v1.5" forCardType:@"Tests" withCardName:@"Container.ScrollableSelectableList.json"];

    XCUIElement *chatWindow = testApp.tables[@"ChatWindow"];

    XCUIElementQuery *container1Query = [chatWindow.buttons matchingIdentifier:@"OneNote,Dolor Sit Amet,Projects > LoremIpsum"];

    XCUIElementQuery *container2Query = [chatWindow.buttons matchingIdentifier:@"OneNote,OneNote File 2,Documents > Test"];

    // For some unknown reason this test succeeds on a mackbook but not in
    // a mac mini (xcode and emulator versions match), so we have to add a
    // small wait time to avoid the long press behaving as a tap
    [NSThread sleepForTimeInterval:1];

    // Execute a drag from the 4th element to the 2nd element
    [container1Query.element pressForDuration:1 thenDragToElement:container2Query.element];
    // assert the submit textview has a blank space, thus the submit event was not raised
    XCTAssert([self verifyInputsAreEmpty]);
}

- (void)verifyChoiceSetInput:(NSDictionary<NSString *, NSString *> *)expectedValue application:(XCUIApplication *)app
{
    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:expectedValue options:NSJSONWritingPrettyPrinted error:nil];
    XCUIElement *queryResult = app.scrollViews.staticTexts[@"ACRUserResponse"];
    NSArray<NSString *> *components = [queryResult.label componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *stringWithNoWhiteSpaces = [components componentsJoinedByString:@""];
    NSString *expectedString = [[NSString alloc] initWithData:expectedData encoding:NSUTF8StringEncoding];
    NSArray<NSString *> *expectedComponents = [expectedString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *expectedStringWithNoWhiteSpaces = [expectedComponents componentsJoinedByString:@""];
    XCTAssertTrue([stringWithNoWhiteSpaces isEqualToString:expectedStringWithNoWhiteSpaces]);
}

- (void)testCanGatherDefaultValuesFromChoiceInputSet
{
    [self openCardForVersion:@"v1.3" forCardType:@"Elements" withCardName:@"Input.ChoiceSet.json"];

    XCUIElement *chatWindow = testApp.tables[@"ChatWindow"];
    [chatWindow swipeUp];

    XCUIElementQuery *buttons = testApp.buttons;
    [buttons[@"OK"] tap];

    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];

    [self verifyInput:@"myColor" matchesExpectedValue:@"1" inInputSet:inputs];
    [self verifyInput:@"myColor2" matchesExpectedValue:@"1" inInputSet:inputs];
    [self verifyInput:@"myColor3" matchesExpectedValue:@"1,3" inInputSet:inputs];
    [self verifyInput:@"myColor4" matchesExpectedValue:@"1" inInputSet:inputs];
}

- (void)testCanGatherCorrectValuesFromCompactChoiceSet
{
    [self openCardForVersion:@"v1.3" forCardType:@"Elements" withCardName:@"Input.ChoiceSet.json"];

    XCUIElement *chatWindow = testApp.tables[@"ChatWindow"];
    [chatWindow /*@START_MENU_TOKEN@*/.buttons[@"myColor"] /*[[".cells.buttons[@\"myColor\"]",".buttons[@\"myColor\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];

    XCUIElementQuery *tablesQuery = testApp.tables;
    [tablesQuery.cells[@"myColor, Blue"].staticTexts[@"Blue"] tap];

    [chatWindow swipeUp];

    XCUIElementQuery *buttons = testApp.buttons;
    [buttons[@"OK"] tap];

    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];

    [self verifyInput:@"myColor" matchesExpectedValue:@"3" inInputSet:inputs];
    [self verifyInput:@"myColor2" matchesExpectedValue:@"1" inInputSet:inputs];
    [self verifyInput:@"myColor3" matchesExpectedValue:@"1,3" inInputSet:inputs];
    [self verifyInput:@"myColor4" matchesExpectedValue:@"1" inInputSet:inputs];
}

- (void)testCanGatherCorrectValuesFromExpandedRadioButton
{
    [self openCardForVersion:@"v1.3" forCardType:@"Elements" withCardName:@"Input.ChoiceSet.json"];

    XCUIElement *chatWindow = testApp.tables[@"ChatWindow"];
    [chatWindow.tables[@"myColor2"].staticTexts[@"myColor2, Blue"] tap];
    [chatWindow.tables[@"myColor2"].staticTexts[@"myColor2, Green"] tap];
    [chatWindow /*@START_MENU_TOKEN@*/.tables[@"myColor3"].staticTexts[@"myColor3, Red"] /*[[".cells.tables[@\"myColor3\"]",".cells[@\"Empty list, Red\"]",".staticTexts[@\"Red\"]",".staticTexts[@\"myColor3, Red\"]",".tables[@\"myColor3\"]"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/ tap];

    [chatWindow swipeUp];

    // Execute a drag from the 4th element to the 2nd element
    XCUIElementQuery *buttons = testApp.buttons;
    [buttons[@"OK"] tap];

    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];

    [self verifyInput:@"myColor" matchesExpectedValue:@"1" inInputSet:inputs];
    [self verifyInput:@"myColor2" matchesExpectedValue:@"2" inInputSet:inputs];
    [self verifyInput:@"myColor3" matchesExpectedValue:@"3" inInputSet:inputs];
    [self verifyInput:@"myColor4" matchesExpectedValue:@"1" inInputSet:inputs];
}

- (void)testCanGatherCorrectValuesFromChoiceset
{
    [self openCardForVersion:@"v1.3" forCardType:@"Elements" withCardName:@"Input.ChoiceSet.json"];

    XCUIElement *chatWindow = testApp.tables[@"ChatWindow"];
    [chatWindow.tables[@"myColor3"].staticTexts[@"myColor3, Blue"] tap];
    [chatWindow /*@START_MENU_TOKEN@*/.tables[@"myColor3"].staticTexts[@"myColor3, Red"] /*[[".cells.tables[@\"myColor3\"]",".cells[@\"Empty list, Red\"]",".staticTexts[@\"Red\"]",".staticTexts[@\"myColor3, Red\"]",".tables[@\"myColor3\"]"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/ tap];

    [chatWindow swipeUp];

    XCUIElementQuery *buttons = testApp.buttons;
    [buttons[@"OK"] tap];

    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];

    [self verifyInput:@"myColor" matchesExpectedValue:@"1" inInputSet:inputs];
    [self verifyInput:@"myColor2" matchesExpectedValue:@"1" inInputSet:inputs];
    [self verifyInput:@"myColor3" matchesExpectedValue:@"" inInputSet:inputs];
    [self verifyInput:@"myColor4" matchesExpectedValue:@"1" inInputSet:inputs];
}

- (void)testHexColorCodeConversion
{
    const std::string testHexColorCode1 = "#FFa", testHexColorCode2 = "#FF123456",
                      testHexColorCode3 = "#FF1234G6", testHexColorCode4 = "#FF12345G",
                      testHexColorCode5 = "#FF1234  ", testHexColorCode6 = "#FF    56",
                      testHexColorCode7 = "   #FF123", testHexColorCode8 = "# FF12345",
                      testHexColorCode9 = "#  FF1234";
    UIColor *color1 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode1];
    XCTAssertTrue(CGColorEqualToColor(color1.CGColor, UIColor.clearColor.CGColor));

    UIColor *color2 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode2];
    XCTAssertTrue(!CGColorEqualToColor(color2.CGColor, UIColor.clearColor.CGColor));

    UIColor *color3 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode3];
    XCTAssertTrue(CGColorEqualToColor(color3.CGColor, UIColor.clearColor.CGColor));

    UIColor *color4 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode4];
    XCTAssertTrue(CGColorEqualToColor(color4.CGColor, UIColor.clearColor.CGColor));

    UIColor *color5 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode5];
    XCTAssertTrue(CGColorEqualToColor(color5.CGColor, UIColor.clearColor.CGColor));

    UIColor *color6 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode6];
    XCTAssertTrue(CGColorEqualToColor(color6.CGColor, UIColor.clearColor.CGColor));

    UIColor *color7 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode7];
    XCTAssertTrue(CGColorEqualToColor(color7.CGColor, UIColor.clearColor.CGColor));

    UIColor *color8 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode8];
    XCTAssertTrue(CGColorEqualToColor(color8.CGColor, UIColor.clearColor.CGColor));

    UIColor *color9 = [ACOHostConfig convertHexColorCodeToUIColor:testHexColorCode9];
    XCTAssertTrue(CGColorEqualToColor(color9.CGColor, UIColor.clearColor.CGColor));
}

- (void)testDynamicTypeaheadSearchFromChoiceset
{
    NSString *payload = [NSString stringWithContentsOfFile:@"../samples/v1.6/Tests/Input.ChoiceSet.Static&DynamicTypeahead.json" encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    if (!cardParseResult.isValid) {
        return;
    }

    XCUICoordinate *startPoint = [testApp.buttons[@"v1.3"] coordinateWithNormalizedOffset:CGVectorMake(0, 0)]; // center of the element
    XCUICoordinate *finishPoint = [startPoint coordinateWithOffset:CGVectorMake(-1000, 0)];                    // adjust the x-offset to move left
    [startPoint pressForDuration:0 thenDragToCoordinate:finishPoint];
    [self openCardForVersion:@"v1.6" forCardType:@"Tests" withCardName:@"Input.ChoiceSet.DynamicTypeahead.json"];
    XCUIElement *chosenpackageButton = testApp.tables[@"ChatWindow"].buttons[@"chosenPackage"];
    [chosenpackageButton tap];

    // back button test
    XCUIElement *backButton = testApp.buttons[@"Back"];
    [backButton tap];

    [chosenpackageButton tap];

    XCUIElement *searchBarChosenpackageTable = testApp.otherElements[@"searchBar, chosenPackage"];

    [searchBarChosenpackageTable typeText:@"microsoft"];
    [NSThread sleepForTimeInterval:0.2];
    XCUIElement *listviewChosenpackageTable = testApp.tables[@"listView, chosenPackage"];
    [listviewChosenpackageTable.staticTexts[@"Microsoft.Extensions.Hosting.Abstractions"] tap];
    // Execute a drag from the 4th element to the 2nd element

    XCUIElementQuery *buttons = testApp.buttons;
    [buttons[@"OK"] tap];

    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    [self verifyInput:@"chosenPackage" matchesExpectedValue:@"Hosting and startup abstractions for applications." inInputSet:inputs];
}

- (void)testStaticDynamicTypeaheadSearchFromChoiceset
{
    NSString *payload = [NSString stringWithContentsOfFile:@"../samples/v1.6/Tests/Input.ChoiceSet.Static&DynamicTypeahead.json" encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];

    if (!cardParseResult.isValid) {
        return;
    }

    XCUICoordinate *startPoint = [testApp.buttons[@"v1.3"] coordinateWithNormalizedOffset:CGVectorMake(0, 0)]; // center of the element
    XCUICoordinate *finishPoint = [startPoint coordinateWithOffset:CGVectorMake(-1000, 0)];                    // adjust the x-offset to move left
    [startPoint pressForDuration:0 thenDragToCoordinate:finishPoint];
    [self openCardForVersion:@"v1.6" forCardType:@"Tests" withCardName:@"Input.ChoiceSet.Static&DynamicTypeahead.json"];
    XCUIElement *choicesetPackageButton = testApp.tables[@"ChatWindow"].buttons[@"choiceset1"];
    [choicesetPackageButton tap];

    // back button test
    XCUIElement *backButton = testApp.buttons[@"Back"];
    [backButton tap];

    [choicesetPackageButton tap];

    // select static choice
    XCUIElement *listviewChoicesetPackageTable = testApp.tables[@"listView, choiceset1"];
    [listviewChoicesetPackageTable.staticTexts[@"Ms.IdentityModel.static"] tap];

    // press OK button
    XCUIElementQuery *buttons = testApp.buttons;
    [buttons[@"Submit"] tap];

    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    [self verifyInput:@"choiceset1" matchesExpectedValue:@"4" inInputSet:inputs];

    // select dynamic choice
    choicesetPackageButton = testApp.tables[@"ChatWindow"].buttons[@"choiceset1"];
    [choicesetPackageButton tap];
    XCUIElement *searchBarChoicesetPackageTable = testApp.otherElements[@"searchBar, choiceset1"];
    [searchBarChoicesetPackageTable typeText:@"Microsoft.Extensions.Hosting.Abstractions"];
    [NSThread sleepForTimeInterval:0.2];
    listviewChoicesetPackageTable = testApp.tables[@"listView, choiceset1"];
    [listviewChoicesetPackageTable.staticTexts[@"Microsoft.Extensions.Hosting.Abstractions"] tap];

    buttons = testApp.buttons;
    [buttons[@"Submit"] tap];

    resultsString = [self getInputsString];
    resultsDictionary = [self parseJsonToDictionary:resultsString];
    inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    [self verifyInput:@"choiceset1" matchesExpectedValue:@"Hosting and startup abstractions for applications." inInputSet:inputs];
}

- (void) testPopoverInput1SuccessfulSubmission
{
    [self openCardForVersion:@"v1.5" forCardType:@"Elements" withCardName:@"Action.Popover.json"];
    
    // Type in "Outside Popover Input Required *"
    XCUIElement *outsideRequired = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"outsidePopover1"]];
    XCTAssertTrue(outsideRequired.exists);
    [outsideRequired tap];
    [outsideRequired typeText:@"text outside popover required"];
    
    // Type in "Outside Popover Input"
    XCUIElement *outsideInput = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"outsidePopover2"]];
    XCTAssertTrue(outsideInput.exists);
    [outsideInput tap];
    [outsideInput typeText:@"text outside popover Input"];
    
    // Dismiss the keyboard
    XCUIElement *returnKey = testApp.keyboards.buttons[@"return"];
    if (returnKey.exists && returnKey.isHittable) {
        [returnKey tap];
    }
    
    // Scroll to and tap the "Add Name Popover" button
    XCUIElement *popoverButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Add Name Popover"]];
    XCTAssertTrue(popoverButton.exists);
    
    int maxScrolls = 5;
    int scrolls = 0;
    while (!popoverButton.hittable && scrolls < maxScrolls) {
        [testApp swipeUp];
        sleep(1);
        scrolls++;
    }
    XCTAssertTrue(popoverButton.hittable, @"Popover button should be hittable after scrolling");
    [popoverButton tap];
    
    // Type in the popover input
    XCUIElement *textField = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"inputInPopover1"]];
    XCTAssertTrue(textField.exists, @"Popover text field should exist after tapping and swiping if needed");
    [self checkAndTap:textField];
    [textField typeText:@"Input inside popover\n"];
    
    // Click on overflow button
    XCUIElement *overflowButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"..."]];
    XCTAssertTrue(overflowButton.exists);
    [overflowButton tap];
    
    // Click on submit in the alert (popover/bottom sheet)
    XCUIElement *alert = testApp.alerts.element;
    XCUIElement *submitButton = [alert.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Submit"]];
    XCTAssertTrue(submitButton.exists && submitButton.isHittable, @"Submit button in alert should exist and be hittable");
    [submitButton tap];
    
    // Verify all inputs
    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    [self verifyInput:@"outsidePopover1" matchesExpectedValue:@"text outside popover required" inInputSet:inputs];
    [self verifyInput:@"outsidePopover2" matchesExpectedValue:@"text outside popover Input" inInputSet:inputs];
    [self verifyInput:@"inputInPopover1" matchesExpectedValue:@"Input inside popover" inInputSet:inputs];
    
    // After clicking submit and before/after parsing the results:
    XCUIElement *resultsText = [testApp.staticTexts elementMatchingType:XCUIElementTypeAny identifier:@"SubmitActionRetrievedResults"];
    XCTAssertTrue(resultsText.exists, @"SubmitActionRetrievedResults static text should exist");
    
    // Build the expected label string (make sure to match the actual output format)
    // The actual label ends with an extra newline, so match that
    NSString *expectedLabel = @"{ \t\"inputs\":{   \"outsidePopover2\" : \"text outside popover Input\",   \"inputInPopover1\" : \"Input inside popover\",   \"outsidePopover1\" : \"text outside popover required\" }, \"data\" : null\n}\n";
    
    NSCharacterSet *whitespaceAndNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString *cleanExpected = [[expectedLabel componentsSeparatedByCharactersInSet:whitespaceAndNewline] componentsJoinedByString:@""];
    NSString *cleanActual = [[resultsText.label componentsSeparatedByCharactersInSet:whitespaceAndNewline] componentsJoinedByString:@""];
    
    XCTAssertEqualObjects(cleanActual, cleanExpected, @"SubmitActionRetrievedResults label should match expected JSON ignoring whitespace");
}

- (void) testPopoverInput1Submission
{
    [self openCardForVersion:@"v1.5" forCardType:@"Elements" withCardName:@"Action.Popover.json"];
    
    // Scroll to and tap the "Add Name Popover" button
    XCUIElement *popoverButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Add Name Popover"]];
    XCTAssertTrue(popoverButton.exists);
    
    int maxScrolls = 5;
    int scrolls = 0;
    while (!popoverButton.hittable && scrolls < maxScrolls) {
        [testApp swipeUp];
        sleep(1);
        scrolls++;
    }
    XCTAssertTrue(popoverButton.hittable, @"Popover button should be hittable after scrolling");
    [popoverButton tap];
    
    // Type in the popover input
    XCUIElement *textField = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"inputInPopover1"]];
    XCTAssertTrue(textField.exists, @"Popover text field should exist after tapping and swiping if needed");
    [self checkAndTap:textField];
    [textField typeText:@"Input inside popover\n"];
    
    // Click on overflow button
    XCUIElement *overflowButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"..."]];
    XCTAssertTrue(overflowButton.exists);
    [overflowButton tap];
    
    // Click on submit in the alert (popover/bottom sheet)
    XCUIElement *alert = testApp.alerts.element;
    XCUIElement *submitButton = [alert.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Submit"]];
    XCTAssertTrue(submitButton.exists && submitButton.isHittable, @"Submit button in alert should exist and be hittable");
    [submitButton tap];
    
    // Verify all inputs
    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    XCTAssertNil(inputs);
}

- (void) testPopoverRatingSuccessfulSubmission
{
    [self openCardForVersion:@"v1.5" forCardType:@"Elements" withCardName:@"Action.Popover.json"];
    // Type in "Outside Popover Input Required *"
    XCUIElement *outsideRequired = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"outsidePopover1"]];
    XCTAssertTrue(outsideRequired.exists);
    [outsideRequired tap];
    [outsideRequired typeText:@"text outside popover required"];
    
    // Type in "Outside Popover Input"
    XCUIElement *outsideInput = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"outsidePopover2"]];
    XCTAssertTrue(outsideInput.exists);
    [outsideInput tap];
    [outsideInput typeText:@"text outside popover Input"];
    
    // Dismiss the keyboard
    XCUIElement *returnKey = testApp.keyboards.buttons[@"return"];
    if (returnKey.exists && returnKey.isHittable) {
        [returnKey tap];
    }
    XCUIElement *popoverButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Select rating Popover"]];
    XCTAssertTrue(popoverButton.exists, @"Popover Button - Select rating popover should exist after tapping and swiping if needed");
    [self checkAndTap:popoverButton];

    // Adjust this to select a rating (e.g., tap the 4th star for rating=4)
    // Tap the 4th star for rating=4
    XCUIElement *fourthStar = [testApp.images elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Rate 4 Star"]];
    XCTAssertTrue(fourthStar.exists && fourthStar.isHittable, @"The 4th star should exist and be hittable");
    [fourthStar tap];

    // Click on submit in the alert (popover/bottom sheet)
    XCUIElement *alert = testApp.alerts.element;
    XCUIElement *submitButton = [alert.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Submit"]];
    
    if (!submitButton.exists)
    {
        XCUIElementQuery *submitButtons = [testApp.buttons matchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Submit"]];
        submitButton = nil;
        for (NSUInteger i = 0; i < submitButtons.count; i++) {
            XCUIElement *button = [submitButtons elementBoundByIndex:i];
            if (button.exists && button.isHittable) {
                submitButton = button;
                break;
            }
        }
    }
    XCTAssertTrue(submitButton.exists && submitButton.isHittable, @"Submit button in alert should exist and be hittable");
    [submitButton tap];

    // Verify all inputs
    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    [self verifyNumberInput:@"rating1" matchesExpectedValue:@"4" inInputSet:inputs];

    // After clicking submit and before/after parsing the results:
    XCUIElement *resultsText = [testApp.staticTexts elementMatchingType:XCUIElementTypeAny identifier:@"SubmitActionRetrievedResults"];
    XCTAssertTrue(resultsText.exists, @"SubmitActionRetrievedResults static text should exist");

    NSString *expectedLabel = @"{ \
    \"inputs\":{ \
    \"outsidePopover2\":\"textoutsidepopoverInput\", \
    \"rating1\":4, \
    \"outsidePopover1\":\"textoutsidepopoverrequired\" \
    }, \
    \"data\":null \
    }";
    
    NSCharacterSet *whitespaceAndNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *cleanExpected = [[expectedLabel componentsSeparatedByCharactersInSet:whitespaceAndNewline] componentsJoinedByString:@""];
    NSString *cleanActual = [[resultsText.label componentsSeparatedByCharactersInSet:whitespaceAndNewline] componentsJoinedByString:@""];
    XCTAssertEqualObjects(cleanActual, cleanExpected, @"SubmitActionRetrievedResults label should match expected JSON ignoring whitespace");
}

- (void) testPopoverRatingSubmission
{
    [self openCardForVersion:@"v1.5" forCardType:@"Elements" withCardName:@"Action.Popover.json"];
    XCUIElement *popoverButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Select rating Popover"]];
    XCTAssertTrue(popoverButton.exists, @"Popover button - Select rating popover should exist after tapping and swiping if needed");
    [self checkAndTap:popoverButton];

    // Adjust this to select a rating (e.g., tap the 4th star for rating=4)
    // Tap the 4th star for rating=4
    XCUIElement *fourthStar = [testApp.images elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Rate 4 Star"]];
    XCTAssertTrue(fourthStar.exists && fourthStar.isHittable, @"The 4th star should exist and be hittable");
    [fourthStar tap];

    // Click on submit in the alert (popover/bottom sheet)
    XCUIElement *alert = testApp.alerts.element;
    XCUIElement *submitButton = [alert.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Submit"]];
    
    if (!submitButton.exists)
    {
        XCUIElementQuery *submitButtons = [testApp.buttons matchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Submit"]];
        submitButton = nil;
        for (NSUInteger i = 0; i < submitButtons.count; i++) {
            XCUIElement *button = [submitButtons elementBoundByIndex:i];
            if (button.exists && button.isHittable) {
                submitButton = button;
                break;
            }
        }
    }
    XCTAssertTrue(submitButton.exists && submitButton.isHittable, @"Submit button in alert should exist and be hittable");
    [submitButton tap];

    // Verify all inputs
    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    XCTAssertNil(inputs);
}

- (void) testPopoverInput2SuccessfulSubmission
{
    [self openCardForVersion:@"v1.5" forCardType:@"Elements" withCardName:@"Action.Popover.json"];
    
    // Type in "Outside Popover Input Required *"
    XCUIElement *outsideRequired = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"outsidePopover1"]];
    XCTAssertTrue(outsideRequired.exists);
    [outsideRequired tap];
    [outsideRequired typeText:@"text outside popover required"];
    
    // Type in "Outside Popover Input"
    XCUIElement *outsideInput = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"outsidePopover2"]];
    XCTAssertTrue(outsideInput.exists);
    [outsideInput tap];
    [outsideInput typeText:@"text outside popover Input"];
    
    // Dismiss the keyboard
    XCUIElement *returnKey = testApp.keyboards.buttons[@"return"];
    if (returnKey.exists && returnKey.isHittable) {
        [returnKey tap];
    }
    
    // Scroll to and tap the "Add Name Popover" button
    XCUIElement *popoverButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Add Number Popover"]];
    XCTAssertTrue(popoverButton.exists);
    
    int maxScrolls = 5;
    int scrolls = 0;
    while (!popoverButton.hittable && scrolls < maxScrolls) {
        [testApp swipeUp];
        sleep(1);
        scrolls++;
    }
    XCTAssertTrue(popoverButton.hittable, @"Popover button should be hittable after scrolling");
    [popoverButton tap];
    
    // Type in the popover input
    XCUIElement *textField = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"inputInPopover2"]];
    XCTAssertTrue(textField.exists, @"Popover text field should exist after tapping and swiping if needed");
    [self checkAndTap:textField];
    [textField typeText:@"1234\n"];
    
    // Click on overflow button
    XCUIElement *overflowButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"..."]];
    XCTAssertTrue(overflowButton.exists);
    [overflowButton tap];
    
    // Click on submit in the alert (popover/bottom sheet)
    XCUIElement *alert = testApp.alerts.element;
    XCUIElement *submitButton = [alert.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Submit"]];
    XCTAssertTrue(submitButton.exists && submitButton.isHittable, @"Submit button in alert should exist and be hittable");
    [submitButton tap];
    
    // Verify all inputs
    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    [self verifyInput:@"outsidePopover1" matchesExpectedValue:@"text outside popover required" inInputSet:inputs];
    [self verifyInput:@"outsidePopover2" matchesExpectedValue:@"text outside popover Input" inInputSet:inputs];
    [self verifyNumberInput:@"inputInPopover2" matchesExpectedValue:@"1234" inInputSet:inputs];
    
    // After clicking submit and before/after parsing the results:
    XCUIElement *resultsText = [testApp.staticTexts elementMatchingType:XCUIElementTypeAny identifier:@"SubmitActionRetrievedResults"];
    XCTAssertTrue(resultsText.exists, @"SubmitActionRetrievedResults static text should exist");
    
    // Build the expected label string (make sure to match the actual output format)
    // The actual label ends with an extra newline, so match that
    NSString *expectedLabel = @"{ \
    \"inputs\":{ \
    \"outsidePopover2\":\"textoutsidepopoverInput\", \
    \"inputInPopover2\":\"1234\", \
    \"outsidePopover1\":\"textoutsidepopoverrequired\" \
    }, \
    \"data\":null \
    }";
    
    NSCharacterSet *whitespaceAndNewline = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString *cleanExpected = [[expectedLabel componentsSeparatedByCharactersInSet:whitespaceAndNewline] componentsJoinedByString:@""];
    NSString *cleanActual = [[resultsText.label componentsSeparatedByCharactersInSet:whitespaceAndNewline] componentsJoinedByString:@""];
    
    XCTAssertEqualObjects(cleanActual, cleanExpected, @"SubmitActionRetrievedResults label should match expected JSON ignoring whitespace");
}

- (void) testPopoverInput2Submission
{
    [self openCardForVersion:@"v1.5" forCardType:@"Elements" withCardName:@"Action.Popover.json"];
    
    // Scroll to and tap the "Add Name Popover" button
    XCUIElement *popoverButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Add Number Popover"]];
    XCTAssertTrue(popoverButton.exists);
    
    int maxScrolls = 5;
    int scrolls = 0;
    while (!popoverButton.hittable && scrolls < maxScrolls) {
        [testApp swipeUp];
        sleep(1);
        scrolls++;
    }
    XCTAssertTrue(popoverButton.hittable, @"Popover button should be hittable after scrolling");
    [popoverButton tap];
    
    // Type in the popover input
    XCUIElement *textField = [testApp.textFields elementMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", @"inputInPopover2"]];
    XCTAssertTrue(textField.exists, @"Popover text field should exist after tapping and swiping if needed");
    [self checkAndTap:textField];
    [textField typeText:@"1234\n"];
    
    // Click on overflow button
    XCUIElement *overflowButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"..."]];
    XCTAssertTrue(overflowButton.exists);
    [overflowButton tap];
    
    // Click on submit in the alert (popover/bottom sheet)
    XCUIElement *alert = testApp.alerts.element;
    XCUIElement *submitButton = [alert.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Submit"]];
    XCTAssertTrue(submitButton.exists && submitButton.isHittable, @"Submit button in alert should exist and be hittable");
    [submitButton tap];
    
    // Verify all inputs
    NSString *resultsString = [self getInputsString];
    NSDictionary *resultsDictionary = [self parseJsonToDictionary:resultsString];
    NSDictionary *inputs = [self getInputsFromResultsDictionary:resultsDictionary];
    XCTAssertNil(inputs);
}

- (void) testPopoverRendering
{
    [self openCardForVersion:@"v1.5" forCardType:@"Elements" withCardName:@"Action.Popover.json"];
    XCUIElement *popoverButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"Less Content Popover"]];
    XCTAssertTrue(popoverButton.exists);
    [popoverButton tap];

    XCUIElement *lessContentTextView = [testApp.textViews elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Less Content"]];
    XCTAssertTrue(lessContentTextView.exists, @"'Less Content' TextView should exist");
    [self dismissPopoverBottomSheet];
    XCUIElement *containerButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"This Container is clickable and will show a popover"]];
    XCTAssertTrue(containerButton.exists && containerButton.isHittable, @"'This Container is clickable and will show a popover' button should exist and be hittable");
    [containerButton tap];
    XCUIElement *popoverTextView = [testApp.textViews elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"This is a popover"]];
    XCTAssertTrue(popoverTextView.exists, @"'This is a popover' TextView should exist");
    [self dismissPopoverBottomSheet];
    XCUIElement *popoverIcon = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @", Click me to show a popover"]];
    XCTAssertTrue(popoverIcon.exists && popoverIcon.isHittable, @"Button ', Click me to show a popover' should exist and be hittable");
    [popoverIcon tap];
    popoverTextView = [testApp.textViews elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"This Popover is made with Adaptive Card elements, it supports actions and is fully accessible."]];
    XCTAssertTrue(popoverTextView.exists, @"The icon popover TextView with the expected label should exist");
    [self dismissPopoverBottomSheet];
    
    XCUIElement *progressBarButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Progress Bar"]];
    XCTAssertTrue(progressBarButton.exists, @"'Progress Bar' button should exist and be hittable");
    [self checkAndTap:progressBarButton];
    NSArray<NSString *> *labels = @[
        @"Progress in Accent",
        @"Progress in Attention",
        @"Progress in Good",
        @"Progress in Warning",
        @"No Progress"
    ];

    for (NSString *label in labels) {
        XCUIElement *textView = [testApp.textViews elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", label]];
        XCTAssertTrue(textView.exists, "%s", [[NSString stringWithFormat:@"TextView with label '%@' should exist", label] UTF8String]);
    }
    [self dismissPopoverBottomSheet];
}

- (void) dismissPopoverBottomSheet
{
    XCUIElement *dismissButton = [testApp.buttons elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label == %@", @"Dismiss"]];
    XCTAssertTrue(dismissButton.exists && dismissButton.isHittable, @"'Dismiss' button should exist and be hittable");
    [dismissButton tap];

}

- (void) checkAndTap:(XCUIElement *)element
{
    int maxSwipes = 5, swipes = 0;
    while (!element.isHittable && swipes < maxSwipes)
    {
        [testApp swipeUp];
        swipes++;
    }
    [element tap];
}

@end
