//
//  AdaptiveCardsTests.mm
//  AdaptiveCardsTests
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "ACOBaseCardElementPrivate.h"
#import "ACRBaseCardElementRenderer.h"
#import "ACRContentHoldingUIView.h"
#import "ACRFactSetRenderer.h"
#import "ACRInputLabelView.h"
#import "ACRRegistration.h"
#import "ACRTextField.h"
#import "ACRTextView.h"
#import "ACRViewPrivate.h"
#import "Fact.h"
#import "FactSet.h"
#import "TextBlock.h"
#import "TextInput.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

using namespace AdaptiveCards;

@interface ACRTextField (Testing)
- (void)acr_clearTextField:(UIButton *)sender;
@end

@interface ACRTrackingTextMapView : ACRView

@property NSUInteger liveTextMapAccessCount;
@property NSUInteger enqueueCount;

@end

@implementation ACRTrackingTextMapView

- (NSMutableDictionary *)getTextMap
{
    self.liveTextMapAccessCount++;
    return [super getTextMap];
}

- (void)enqueueIntermediateTextProcessingResult:(NSDictionary *)data
                                      elementId:(NSString *)elementId
{
    self.enqueueCount++;
    [super enqueueIntermediateTextProcessingResult:data elementId:elementId];
}

@end

@interface AdaptiveCardsTests : XCTestCase

@end

@implementation AdaptiveCardsTests

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testTextBlockTextProperty2
{
    std::shared_ptr<AdaptiveCards::TextBlock> textblock = std::make_shared<AdaptiveCards::TextBlock>();
    textblock->SetText("Text test");

    XCTAssert(textblock->GetText() == "Text test");

    std::string serializedTextBlock = textblock->Serialize();
    XCTAssert(serializedTextBlock == "{\"text\":\"Text test\",\"type\":\"TextBlock\"}\n");
}

- (void)testDefaultBadgeStylesUseAccessibleTextColors
{
    HostConfig hostConfig;
    BadgeStylesDefinition badgeStyles = hostConfig.GetBadgeStyles();

    XCTAssertEqual(badgeStyles.accentPalette.tintStyle.textColor, std::string("#444791"));
    XCTAssertEqual(badgeStyles.attentionPalette.tintStyle.textColor, std::string("#a4262c"));
    XCTAssertEqual(badgeStyles.goodPalette.tintStyle.textColor, std::string("#0b6a0b"));
    XCTAssertEqual(badgeStyles.subtlePalette.filledStyle.textColor, std::string("#5f5f5f"));
    XCTAssertEqual(badgeStyles.subtlePalette.tintStyle.textColor, std::string("#5f5f5f"));
}

- (void)testTextFieldClearButtonUsesAccessibleColorAndNativeLayout
{
    CGRect bounds = CGRectMake(0, 0, 220, 34);
    ACRTextField *textField = [[ACRTextField alloc] initWithFrame:bounds];
    textField.text = @"Ashley";

    UITextField *nativeTextField = [[UITextField alloc] initWithFrame:bounds];
    nativeTextField.borderStyle = UITextBorderStyleRoundedRect;
    nativeTextField.clearButtonMode = UITextFieldViewModeAlways;

    XCTAssertEqual(textField.rightViewMode, UITextFieldViewModeAlways);
    XCTAssertTrue([textField.rightView isKindOfClass:UIButton.class]);
    XCTAssertTrue(CGRectEqualToRect([textField rightViewRectForBounds:bounds],
                                    [nativeTextField clearButtonRectForBounds:bounds]));

    UIButton *clearButton = (UIButton *)textField.rightView;
    XCTAssertEqualObjects(clearButton.tintColor, UIColor.secondaryLabelColor);
    XCTAssertEqualObjects(clearButton.accessibilityLabel, @"Clear text");

    [textField acr_clearTextField:clearButton];

    XCTAssertEqualObjects(textField.text, @"");
    XCTAssertEqual(textField.rightViewMode, UITextFieldViewModeNever);
}

- (void)testContentHoldingUIViewWithImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    ACRContentStackView *viewGroup = [[ACRContentStackView alloc] init];
    ACRContentHoldingUIView *wrapperView = [[ACRContentHoldingUIView alloc] initWithImageProperties:[[ACRImageProperties alloc] init] imageView:imageView viewGroup:viewGroup];
    XCTAssertNotNil(wrapperView);
    XCTAssertEqualObjects(wrapperView.contentView, imageView);
}

- (void)testPasswordStyleIsCorrectSet
{
    std::shared_ptr<AdaptiveCards::TextInput> textInput = std::make_shared<AdaptiveCards::TextInput>();
    textInput->SetTextInputStyle(TextInputStyle::Password);
    ACOBaseCardElement *baseCardElement = [[ACOBaseCardElement alloc] initWithBaseCardElement:textInput];
    ACRRegistration *registration = [ACRRegistration getInstance];
    ACRBaseCardElementRenderer *renderer = [registration getRenderer:[NSNumber numberWithInt:ACRTextInput]];
    ACRColumnView *viewGroup = [[ACRColumnView alloc] init];
    ACRView *rootView = [[ACRView alloc] init];
    NSMutableArray *inputs = [[NSMutableArray alloc] init];
    ACOHostConfig *config = [[ACOHostConfig alloc] init];
    UIView *inputView = [renderer render:viewGroup
                                rootView:rootView
                                  inputs:inputs
                         baseCardElement:baseCardElement
                              hostConfig:config];
    XCTAssertNotNil(inputView);
    XCTAssertTrue([inputView isKindOfClass:[ACRInputLabelView class]]);
    ACRInputLabelView *labelview = (ACRInputLabelView *)inputView;
    XCTAssertNotNil(labelview.inputView);
    XCTAssertTrue([labelview.inputView isKindOfClass:[UITextField class]]);
    UITextField *textField = (UITextField *)labelview.inputView;
    XCTAssertTrue(textField.isSecureTextEntry);
}

- (void)testInputIsSetToACRTextViewWhenMultiline
{
    std::shared_ptr<AdaptiveCards::TextInput> textInput = std::make_shared<AdaptiveCards::TextInput>();
    textInput->SetIsMultiline(true);
    ACOBaseCardElement *baseCardElement = [[ACOBaseCardElement alloc] initWithBaseCardElement:textInput];
    ACRRegistration *registration = [ACRRegistration getInstance];
    ACRBaseCardElementRenderer *renderer = [registration getRenderer:[NSNumber numberWithInt:ACRTextInput]];
    ACRColumnView *viewGroup = [[ACRColumnView alloc] init];
    ACRView *rootView = [[ACRView alloc] init];
    NSMutableArray *inputs = [[NSMutableArray alloc] init];
    ACOHostConfig *config = [[ACOHostConfig alloc] init];
    UIView *inputView = [renderer render:viewGroup
                                rootView:rootView
                                  inputs:inputs
                         baseCardElement:baseCardElement
                              hostConfig:config];
    XCTAssertNotNil(inputView);
    XCTAssertTrue([inputView isKindOfClass:[ACRInputLabelView class]]);
    ACRInputLabelView *labelview = (ACRInputLabelView *)inputView;
    XCTAssertNotNil(labelview.inputView);
    XCTAssertTrue([labelview.inputView isKindOfClass:[ACRTextView class]]);
}

- (void)testInputIsSetToACRTextFieldWhenMultilineAndPasswordStyleAreSet
{
    std::shared_ptr<AdaptiveCards::TextInput> textInput = std::make_shared<AdaptiveCards::TextInput>();
    textInput->SetIsMultiline(true);
    textInput->SetTextInputStyle(TextInputStyle::Password);
    ACOBaseCardElement *baseCardElement = [[ACOBaseCardElement alloc] initWithBaseCardElement:textInput];
    ACRRegistration *registration = [ACRRegistration getInstance];
    ACRBaseCardElementRenderer *renderer = [registration getRenderer:[NSNumber numberWithInt:ACRTextInput]];
    ACRColumnView *viewGroup = [[ACRColumnView alloc] init];
    ACRView *rootView = [[ACRView alloc] init];
    NSMutableArray *inputs = [[NSMutableArray alloc] init];
    ACOHostConfig *config = [[ACOHostConfig alloc] init];
    UIView *inputView = [renderer render:viewGroup
                                rootView:rootView
                                  inputs:inputs
                         baseCardElement:baseCardElement
                              hostConfig:config];
    XCTAssertNotNil(inputView);
    XCTAssertTrue([inputView isKindOfClass:[ACRInputLabelView class]]);
    ACRInputLabelView *labelview = (ACRInputLabelView *)inputView;
    XCTAssertNotNil(labelview.inputView);
    XCTAssertTrue([labelview.inputView isKindOfClass:[UITextField class]]);
    UITextField *textField = (UITextField *)labelview.inputView;
    XCTAssertTrue(textField.isSecureTextEntry);
}

- (std::shared_ptr<FactSet>)factSetWithTitle:(std::string const &)title
                                      value:(std::string const &)value
{
    std::shared_ptr<FactSet> factSet = std::make_shared<FactSet>();
    factSet->GetFacts().push_back(std::make_shared<Fact>(title, value));
    return factSet;
}

- (UIView *)renderFactSet:(std::shared_ptr<FactSet> const &)factSet
                 rootView:(ACRView *)rootView
{
    ACOBaseCardElement *baseCardElement = [[ACOBaseCardElement alloc] initWithBaseCardElement:factSet];
    ACRColumnView *viewGroup = [[ACRColumnView alloc] init];
    ACOHostConfig *config = [[ACOHostConfig alloc] init];

    return [[ACRFactSetRenderer getInstance] render:viewGroup
                                           rootView:rootView
                                             inputs:[[NSMutableArray alloc] init]
                                    baseCardElement:baseCardElement
                                         hostConfig:config];
}

- (void)testFactSetRendererUsesSynchronizedTextDataAccessor
{
    ACRTrackingTextMapView *rootView = [[ACRTrackingTextMapView alloc] init];
    std::shared_ptr<FactSet> factSet = [self factSetWithTitle:"Title" value:"Value"];

    UIView *renderedView = [self renderFactSet:factSet rootView:rootView];

    XCTAssertNotNil(renderedView);
    XCTAssertEqual(rootView.liveTextMapAccessCount, 0);
    XCTAssertEqual(rootView.enqueueCount, 2);
    XCTAssertEqualObjects([rootView textDataForElementId:@"*0"][@"nonhtml"], @"Title");
    XCTAssertEqualObjects([rootView textDataForElementId:@"*1"][@"nonhtml"], @"Value");
}

- (void)testFactSetRendererUsesExistingPreprocessedTextData
{
    ACRTrackingTextMapView *rootView = [[ACRTrackingTextMapView alloc] init];
    NSDictionary *titleData = @{@"nonhtml" : @"Preprocessed title",
                                @"descriptor" : @{NSFontAttributeName : [UIFont systemFontOfSize:12]}};
    NSDictionary *valueData = @{@"nonhtml" : @"Preprocessed value",
                                @"descriptor" : @{NSFontAttributeName : [UIFont systemFontOfSize:12]}};
    [rootView enqueueIntermediateTextProcessingResult:titleData elementId:@"*0"];
    [rootView enqueueIntermediateTextProcessingResult:valueData elementId:@"*1"];
    rootView.enqueueCount = 0;

    UIView *renderedView = [self renderFactSet:[self factSetWithTitle:"Title" value:"Value"]
                                     rootView:rootView];

    XCTAssertNotNil(renderedView);
    XCTAssertEqual(rootView.liveTextMapAccessCount, 0);
    XCTAssertEqual(rootView.enqueueCount, 0);
    XCTAssertEqualObjects([rootView textDataForElementId:@"*0"], titleData);
    XCTAssertEqualObjects([rootView textDataForElementId:@"*1"], valueData);
}

- (void)testFactSetRendererSupportsConcurrentTextMapWrites
{
    ACRTrackingTextMapView *rootView = [[ACRTrackingTextMapView alloc] init];
    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    dispatch_group_t group = dispatch_group_create();

    for (NSInteger worker = 0; worker < 4; worker++) {
        dispatch_group_async(group, queue, ^{
            for (NSInteger iteration = 0; iteration < 50; iteration++) {
                NSString *key = [NSString stringWithFormat:@"background-%ld-%ld", (long)worker, (long)iteration];
                [rootView enqueueIntermediateTextProcessingResult:@{@"nonhtml" : key} elementId:key];
            }
        });
    }

    for (NSInteger index = 0; index < 25; index++) {
        UIView *renderedView = [self renderFactSet:[self factSetWithTitle:"**Title**" value:"**Value**"]
                                         rootView:rootView];
        XCTAssertNotNil(renderedView);
    }

    XCTAssertEqual(dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC)), 0);
    XCTAssertEqual(rootView.liveTextMapAccessCount, 0);
    XCTAssertEqualObjects([rootView textDataForElementId:@"background-3-49"][@"nonhtml"], @"background-3-49");
}

@end
