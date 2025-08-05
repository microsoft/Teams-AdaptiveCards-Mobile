//
//  AdaptiveCardsTests.mm
//  AdaptiveCardsTests
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "ACOBaseCardElementPrivate.h"
#import "ACRBaseCardElementRenderer.h"
#import "ACRContentHoldingUIView.h"
#import "ACRInputLabelView.h"
#import "ACRRegistration.h"
#import "ACRTextView.h"
#import "ACRView.h"
#import "ACOAdaptiveCard.h"
#import "ACOHostConfig.h"
#import "ACOIResourceResolver.h"
#import "ACOResourceResolvers.h"
#import "ACOAdaptiveCardParseResult.h"
#import "TextBlock.h"
#import "TextInput.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

using namespace AdaptiveCards;

// Mock resource resolver for testing KVO observer control
@interface MockResourceResolverWithKVOControl : NSObject <ACOIResourceResolver>
@property (nonatomic, assign) BOOL shouldAddKVOObserver;
@property (nonatomic, strong) UIImageView *lastCreatedImageView;
@end

@implementation MockResourceResolverWithKVOControl

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldAddKVOObserver = NO; // Default to NO for testing
    }
    return self;
}

- (UIImageView *)resolveImageViewResource:(NSURL *)url {
    UIImageView *imageView = [[UIImageView alloc] init];
    self.lastCreatedImageView = imageView;
    return imageView;
}

- (BOOL)shouldAddKVOObserverForImageView:(UIImageView *)imageView {
    return self.shouldAddKVOObserver;
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

- (void)testKVOObserverControlWhenResolverReturnsNO
{
    // Test that KVO observers are not added when resource resolver returns NO
    
    // Create a mock resolver that returns NO for shouldAddKVOObserver
    MockResourceResolverWithKVOControl *mockResolver = [[MockResourceResolverWithKVOControl alloc] init];
    mockResolver.shouldAddKVOObserver = NO;
    
    // Create test adaptive card JSON with an image
    NSString *cardJSON = @"{"
                         @"\"type\": \"AdaptiveCard\","
                         @"\"version\": \"1.0\","
                         @"\"body\": ["
                         @"  {"
                         @"    \"type\": \"Image\","
                         @"    \"url\": \"https://example.com/test.jpg\""
                         @"  }"
                         @"]"
                         @"}";
    
    // Parse the adaptive card using the correct API
    ACOAdaptiveCardParseResult *parseResult = [ACOAdaptiveCard fromJson:cardJSON];
    XCTAssertNotNil(parseResult, @"Parse result should not be nil");
    XCTAssertNotNil(parseResult.card, @"Adaptive card should not be nil");
    
    // Create host config and set our mock resolver
    ACOHostConfig *hostConfig = [[ACOHostConfig alloc] init];
    ACOResourceResolvers *resolvers = [[ACOResourceResolvers alloc] init];
    [resolvers setResourceResolver:mockResolver scheme:@"https"];
    hostConfig.resolvers = resolvers;
    
    // Create ACRView with the card and mock resolver (use simpler constructor for testing)
    ACRView *acrView = [[ACRView alloc] init:parseResult.card hostconfig:hostConfig widthConstraint:320.0 theme:ACRThemeLight]; // 0 = Light theme
    XCTAssertNotNil(acrView, @"ACRView should not be nil");
    
    // Render the card to trigger image loading
    UIView *renderedView = [acrView render];
    XCTAssertNotNil(renderedView, @"Rendered view should not be nil");
    
    // Verify that our mock resolver was called and created an image view
    XCTAssertNotNil(mockResolver.lastCreatedImageView, @"Mock resolver should have created an image view");
    
    // The key test: Verify that no KVO observers were added to the image view
    // We can't directly test KVO observers, but we can verify our protocol method was respected
    // by checking that the early removal set contains our image view (when resolver returns NO)
    UIImageView *createdImageView = mockResolver.lastCreatedImageView;
    XCTAssertTrue([acrView isEarlyKVORemovalEnabledForImageView:createdImageView], 
                  @"Image view should be in early KVO removal set when resolver returns NO");
}

- (void)testKVOObserverControlWhenResolverReturnsYES
{
    // Test that KVO observers are added when resource resolver returns YES (normal behavior)
    
    // Create a mock resolver that returns YES for shouldAddKVOObserver
    MockResourceResolverWithKVOControl *mockResolver = [[MockResourceResolverWithKVOControl alloc] init];
    mockResolver.shouldAddKVOObserver = YES;
    
    // Create test adaptive card JSON with an image
    NSString *cardJSON = @"{"
                         @"\"type\": \"AdaptiveCard\","
                         @"\"version\": \"1.0\","
                         @"\"body\": ["
                         @"  {"
                         @"    \"type\": \"Image\","
                         @"    \"url\": \"https://example.com/test.jpg\""
                         @"  }"
                         @"]"
                         @"}";
    
    // Parse the adaptive card using the correct API
    ACOAdaptiveCardParseResult *parseResult = [ACOAdaptiveCard fromJson:cardJSON];
    XCTAssertNotNil(parseResult, @"Parse result should not be nil");
    XCTAssertNotNil(parseResult.card, @"Adaptive card should not be nil");
    
    // Create host config and set our mock resolver
    ACOHostConfig *hostConfig = [[ACOHostConfig alloc] init];
    ACOResourceResolvers *resolvers = [[ACOResourceResolvers alloc] init];
    [resolvers setResourceResolver:mockResolver scheme:@"https"];
    hostConfig.resolvers = resolvers;
    
    // Create ACRView with the card and mock resolver (use simpler constructor for testing)
    ACRView *acrView = [[ACRView alloc] init:parseResult.card hostconfig:hostConfig widthConstraint:320.0 theme:ACRThemeLight]; // 0 = Light theme
    XCTAssertNotNil(acrView, @"ACRView should not be nil");
    
    // Render the card to trigger image loading
    UIView *renderedView = [acrView render];
    XCTAssertNotNil(renderedView, @"Rendered view should not be nil");
    
    // Verify that our mock resolver was called and created an image view
    XCTAssertNotNil(mockResolver.lastCreatedImageView, @"Mock resolver should have created an image view");
    
    // The key test: Verify that KVO observers were added (normal behavior)
    // When resolver returns YES, the image view should NOT be in the early removal set
    UIImageView *createdImageView = mockResolver.lastCreatedImageView;
    XCTAssertFalse([acrView isEarlyKVORemovalEnabledForImageView:createdImageView], 
                   @"Image view should NOT be in early KVO removal set when resolver returns YES");
}

@end
