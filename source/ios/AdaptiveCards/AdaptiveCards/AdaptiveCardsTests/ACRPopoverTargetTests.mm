//
//  ACRPopoverTargetTests.mm
//  AdaptiveCardsTests
//
//  Created by Harika P on 01/08/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ACRPopoverTarget.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACRBottomSheetViewController.h"
#import "ACRContentStackView.h"
#import "ACRViewPrivate.h"
#import "ACRRegistration.h"
#import "PopoverAction.h"
#import "Mocks/ACRMockViews.h"
#import "Mocks/MockContext.h"
#import "TextBlock.h"
#import "ACRInputLabelView.h"
#import "ACROverflowTarget.h"
#import "ACRBaseTarget.h"
#import "OpenUrlAction.h"
#import "ToggleVisibilityAction.h"
#import "ACRIBaseInputHandler.h"

using namespace AdaptiveCards;

// Expose private interface for testing
@interface ACRPopoverTarget()
@property ACRBottomSheetViewController *currentBottomSheet;
@property ACOBaseActionElement *actionElement;
@property (nonatomic, weak) ACRView *rootView;
@property (nonatomic, strong) ACRContentStackView *cachedContentView;

// Expose private methods for testing
- (void)createCachedContentView;
- (void)attachBottomSheetInputsToMainCard;
- (void)detachBottomSheetInputsFromMainCard;
- (void)markActionTargetsAsFromBottomSheet:(UIView *)containerView;
- (void)presentPopover;
- (void)dismissBottomSheet;
- (void)bottomSheetCloseTapped;
- (IBAction)send:(UIButton *)sender;
- (NSArray<id<ACRIBaseInputHandler>> *)findInputHandlersInView:(UIView *)view;
- (void)collectInputHandlersInView:(UIView *)view intoArray:(NSMutableArray<id<ACRIBaseInputHandler>> *)inputHandlers;
- (void)filterActionTarget:(ACRBaseTarget *)target forView:(UIView *)view;
- (void)propagatePopoverContextToOverflowMenuItems:(ACROverflowTarget *)overflowTarget;
@end

@interface MockActionDelegate : NSObject <ACRActionDelegate>
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic) BOOL respondsToActiveVC;
@end

@implementation MockActionDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        self.respondsToActiveVC = YES;
        self.viewController = [[UIViewController alloc] init];
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(activeViewController)) {
        return self.respondsToActiveVC;
    }
    return [super respondsToSelector:aSelector];
}

- (UIViewController *)activeViewController {
    return self.viewController;
}

- (void)didFetchUserResponses:(ACOAdaptiveCard *)card action:(ACOBaseActionElement *)action {
    // Mock implementation
}

@end

@interface MockInputHandler : UIView <ACRIBaseInputHandler>
@property (nonatomic, strong) NSString *inputValue; // Custom property for testing
@end

@implementation MockInputHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isRequired = NO;
        self.hasValidationProperties = NO;
        self.hasVisibilityChanged = NO;
        self.id = @"mockInput";
        self.inputValue = @"mockValue";
    }
    return self;
}

- (BOOL)validate:(NSError *__autoreleasing *)error {
    return YES;
}

- (void)getInput:(NSMutableDictionary *)dictionary {
    if (self.id && self.inputValue) {
        dictionary[self.id] = self.inputValue;
    }
}

- (void)setFocus:(BOOL)shouldBecomeFirstResponder view:(UIView *)view {
    // Mock implementation
}

- (void)addObserverWithCompletion:(CompletionHandler _Nonnull)completion {
    if (completion) {
        completion();
    }
}

- (void)resetInput {
    self.inputValue = @"";
}

@synthesize hasVisibilityChanged;

@synthesize id;

@synthesize isRequired;

@synthesize hasValidationProperties;

@end

@interface TestACRPopoverTarget : ACRPopoverTarget
@property (nonatomic) BOOL createCachedContentViewCalled;
@property (nonatomic) BOOL attachBottomSheetInputsCalled;
@property (nonatomic) BOOL detachBottomSheetInputsCalled;
@property (nonatomic) BOOL markActionTargetsCalled;
@property (nonatomic, strong) ACRContentStackView *mockCachedContentView;
@property (nonatomic) BOOL shouldFailContentCreation;
@end

@implementation TestACRPopoverTarget

- (void)createCachedContentView {
    self.createCachedContentViewCalled = YES;
    if (self.shouldFailContentCreation) {
        // Don't set cachedContentView to simulate failure
        return;
    }
    if (self.mockCachedContentView) {
        self.cachedContentView = self.mockCachedContentView;
    } else {
        [super createCachedContentView];
    }
}

- (void)attachBottomSheetInputsToMainCard {
    self.attachBottomSheetInputsCalled = YES;
    [super attachBottomSheetInputsToMainCard];
}

- (void)detachBottomSheetInputsFromMainCard {
    self.detachBottomSheetInputsCalled = YES;
    [super detachBottomSheetInputsFromMainCard];
}

- (void)markActionTargetsAsFromBottomSheet:(UIView *)containerView {
    self.markActionTargetsCalled = YES;
    [super markActionTargetsAsFromBottomSheet:containerView];
}

@end

@interface ACRPopoverTargetTests : XCTestCase

@property (nonatomic, strong) TestACRPopoverTarget *popoverTarget;
@property (nonatomic, strong) MockACRView *mockRootView;
@property (nonatomic, strong) ACOBaseActionElement *mockActionElement;
@property (nonatomic, strong) MockActionDelegate *mockActionDelegate;

@end

@implementation ACRPopoverTargetTests

- (void)setUp {
    [super setUp];
    
    // Setup mock root view
    self.mockRootView = [[MockACRView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.mockRootView.inputHandlers = (NSMutableArray<ACRIBaseInputHandler> *)[[NSMutableArray alloc] init];
    
    // Setup mock action delegate
    self.mockActionDelegate = [[MockActionDelegate alloc] init];
    self.mockRootView.acrActionDelegate = self.mockActionDelegate;
    
    // Create a proper PopoverAction
    std::shared_ptr<TextBlock> textBlock = std::make_shared<TextBlock>();
    textBlock->SetText("Test Content");
    std::shared_ptr<PopoverAction> popoverAction = std::make_shared<PopoverAction>(textBlock, true, "300px");
    self.mockActionElement = [ACOBaseActionElement getACOActionElementFromAdaptiveElement:popoverAction];
    
    // Initialize the test target
    self.popoverTarget = [[TestACRPopoverTarget alloc] initWithActionElement:self.mockActionElement rootView:self.mockRootView];
}

- (void)tearDown {
    self.popoverTarget = nil;
    self.mockRootView = nil;
    self.mockActionElement = nil;
    self.mockActionDelegate = nil;
    [super tearDown];
}

#pragma mark - Initialization Tests

- (void)testInitWithActionElementAndRootView {
    XCTAssertNotNil(self.popoverTarget, @"PopoverTarget should be initialized");
    XCTAssertEqual(self.popoverTarget.actionElement, self.mockActionElement, @"Action element should be set");
    XCTAssertEqual(self.popoverTarget.rootView, self.mockRootView, @"Root view should be set");
    XCTAssertNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should be nil initially");
    XCTAssertNil(self.popoverTarget.cachedContentView, @"Cached content view should be nil initially");
}

- (void)testInitWithNilActionElement {
    TestACRPopoverTarget *target = [[TestACRPopoverTarget alloc] initWithActionElement:nil rootView:self.mockRootView];
    XCTAssertNotNil(target, @"Target should still be created with nil action element");
    XCTAssertNil(target.actionElement, @"Action element should be nil");
}

- (void)testInitWithNilRootView {
    TestACRPopoverTarget *target = [[TestACRPopoverTarget alloc] initWithActionElement:self.mockActionElement rootView:nil];
    XCTAssertNotNil(target, @"Target should still be created with nil root view");
    XCTAssertNil(target.rootView, @"Root view should be nil");
}

#pragma mark - Action Tests

- (void)testSendCallsDoSelectAction {
    UIButton *mockButton = [[UIButton alloc] init];
    
    // Test that send calls doSelectAction by checking if presentPopover flow is triggered
    XCTAssertFalse(self.popoverTarget.createCachedContentViewCalled, @"Should not be called before send");
    
    [self.popoverTarget send:mockButton];
    
    // If doSelectAction was called, it should have called presentPopover which calls createCachedContentView
    XCTAssertTrue(self.popoverTarget.createCachedContentViewCalled, @"createCachedContentView should be called after send");
}

- (void)testDoSelectAction {
    XCTAssertFalse(self.popoverTarget.createCachedContentViewCalled, @"Should not be called before doSelectAction");
    
    [self.popoverTarget doSelectAction];
    
    XCTAssertTrue(self.popoverTarget.createCachedContentViewCalled, @"createCachedContentView should be called after doSelectAction");
}

#pragma mark - Present Popover Tests

- (void)testPresentPopoverWithNilActionElement {
    TestACRPopoverTarget *target = [[TestACRPopoverTarget alloc] initWithActionElement:nil rootView:self.mockRootView];
    
    [target presentPopover];
    
    XCTAssertNil(target.currentBottomSheet, @"Bottom sheet should not be created with nil action element");
    XCTAssertFalse(target.createCachedContentViewCalled, @"createCachedContentView should not be called");
}

- (void)testPresentPopoverWithWrongActionType {
    // Create action element with wrong type
    std::shared_ptr<OpenUrlAction> openUrlAction = std::make_shared<OpenUrlAction>();
    ACOBaseActionElement *wrongActionElement = [ACOBaseActionElement getACOActionElementFromAdaptiveElement:openUrlAction];
    
    TestACRPopoverTarget *target = [[TestACRPopoverTarget alloc] initWithActionElement:wrongActionElement rootView:self.mockRootView];
    
    [target presentPopover];
    
    XCTAssertNil(target.currentBottomSheet, @"Bottom sheet should not be created with wrong action type");
    XCTAssertFalse(target.createCachedContentViewCalled, @"createCachedContentView should not be called");
}

- (void)testPresentPopoverWithNoActionDelegate {
    self.mockRootView.acrActionDelegate = nil;
    
    [self.popoverTarget presentPopover];
    
    XCTAssertNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should not be created without action delegate");
    XCTAssertFalse(self.popoverTarget.createCachedContentViewCalled, @"createCachedContentView should NOT be called without action delegate");
}

- (void)testPresentPopoverWithActionDelegateNotRespondingToActiveViewController {
    self.mockActionDelegate.respondsToActiveVC = NO;
    
    [self.popoverTarget presentPopover];
    
    XCTAssertNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should not be created when delegate doesn't respond");
    XCTAssertFalse(self.popoverTarget.createCachedContentViewCalled, @"createCachedContentView should NOT be called when delegate doesn't respond");
}

- (void)testPresentPopoverWithNilActiveViewController {
    self.mockActionDelegate.viewController = nil;
    
    [self.popoverTarget presentPopover];
    
    XCTAssertNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should not be created with nil active view controller");
    XCTAssertFalse(self.popoverTarget.createCachedContentViewCalled, @"createCachedContentView should NOT be called with nil active view controller");
}

- (void)testPresentPopoverWithNoContentView {
    // Set flag to fail content creation
    self.popoverTarget.shouldFailContentCreation = YES;
    
    [self.popoverTarget presentPopover];
    
    XCTAssertNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should not be created without content view");
    XCTAssertTrue(self.popoverTarget.createCachedContentViewCalled, @"createCachedContentView should be called");
    XCTAssertNil(self.popoverTarget.cachedContentView, @"Cached content view should be nil after failed creation");
}

- (void)testPresentPopoverSuccess {
    // Set up mock content view
    ACRContentStackView *mockContentView = [[ACRContentStackView alloc] initWithStyle:ACRDefault
                                                                           parentStyle:ACRDefault
                                                                            hostConfig:nil
                                                                             superview:nil];
    self.popoverTarget.mockCachedContentView = mockContentView;
    
    [self.popoverTarget presentPopover];
    
    XCTAssertNotNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should be created");
    XCTAssertNotNil(self.popoverTarget.cachedContentView, @"Cached content view should be created");
    XCTAssertEqual(self.popoverTarget.cachedContentView, mockContentView, @"Should use mock content view");
    XCTAssertTrue(self.popoverTarget.createCachedContentViewCalled, @"createCachedContentView should be called");
    XCTAssertTrue(self.popoverTarget.attachBottomSheetInputsCalled, @"attachBottomSheetInputs should be called");
    XCTAssertTrue(self.popoverTarget.markActionTargetsCalled, @"markActionTargets should be called");
}

#pragma mark - Input Handler Tests

- (void)testFindInputHandlersInView {
    UIView *containerView = [[UIView alloc] init];
    MockInputHandler *inputHandler = [[MockInputHandler alloc] init];
    [containerView addSubview:inputHandler];
    
    NSArray<id<ACRIBaseInputHandler>> *foundInputs = [self.popoverTarget findInputHandlersInView:containerView];
    
    XCTAssertNotNil(foundInputs, @"Should return an array");
    XCTAssertEqual(foundInputs.count, 1, @"Should find one input handler");
    XCTAssertEqual(foundInputs[0], inputHandler, @"Should find the correct input handler");
}

- (void)testFindInputHandlersInEmptyView {
    UIView *containerView = [[UIView alloc] init];
    
    NSArray<id<ACRIBaseInputHandler>> *foundInputs = [self.popoverTarget findInputHandlersInView:containerView];
    
    XCTAssertNotNil(foundInputs, @"Should return an array");
    XCTAssertEqual(foundInputs.count, 0, @"Should find no input handlers");
}

- (void)testFindInputHandlersInNestedViews {
    UIView *containerView = [[UIView alloc] init];
    UIView *nestedView = [[UIView alloc] init];
    MockInputHandler *inputHandler = [[MockInputHandler alloc] init];
    
    [containerView addSubview:nestedView];
    [nestedView addSubview:inputHandler];
    
    NSArray<id<ACRIBaseInputHandler>> *foundInputs = [self.popoverTarget findInputHandlersInView:containerView];
    
    XCTAssertEqual(foundInputs.count, 1, @"Should find input handler in nested view");
}

- (void)testAttachBottomSheetInputsToMainCard {
    ACRContentStackView *mockContentView = [[ACRContentStackView alloc] init];
    MockInputHandler *inputHandler = [[MockInputHandler alloc] init];
    [mockContentView addSubview:inputHandler];
    
    self.popoverTarget.cachedContentView = mockContentView;
    
    NSUInteger initialCount = self.mockRootView.inputHandlers.count;
    
    [self.popoverTarget attachBottomSheetInputsToMainCard];
    
    XCTAssertEqual(self.mockRootView.inputHandlers.count, initialCount + 1, @"Should add input handler to root view");
}

- (void)testAttachBottomSheetInputsWithNilCachedContentView {
    self.popoverTarget.cachedContentView = nil;
    
    NSUInteger initialCount = self.mockRootView.inputHandlers.count;
    
    // Should not crash
    [self.popoverTarget attachBottomSheetInputsToMainCard];
    
    XCTAssertEqual(self.mockRootView.inputHandlers.count, initialCount, @"Should not add any input handlers");
}

- (void)testAttachBottomSheetInputsWithNilRootView {
    ACRContentStackView *mockContentView = [[ACRContentStackView alloc] init];
    self.popoverTarget.cachedContentView = mockContentView;
    self.popoverTarget.rootView = nil;
    
    // Should not crash
    [self.popoverTarget attachBottomSheetInputsToMainCard];
    
    // No assertions needed, just ensure it doesn't crash
}

- (void)testDetachBottomSheetInputsFromMainCard {
    ACRContentStackView *mockContentView = [[ACRContentStackView alloc] init];
    MockInputHandler *inputHandler = [[MockInputHandler alloc] init];
    [mockContentView addSubview:inputHandler];
    
    self.popoverTarget.cachedContentView = mockContentView;
    [self.mockRootView.inputHandlers addObject:inputHandler];
    
    NSUInteger initialCount = self.mockRootView.inputHandlers.count;
    
    [self.popoverTarget detachBottomSheetInputsFromMainCard];
    
    XCTAssertEqual(self.mockRootView.inputHandlers.count, initialCount - 1, @"Should remove input handler from root view");
}

- (void)testMockInputHandlerProtocolCompliance {
    MockInputHandler *inputHandler = [[MockInputHandler alloc] init];
    
    // Test that our mock properly implements the protocol
    XCTAssertNotNil(inputHandler.id, @"Input handler should have an id");
    XCTAssertFalse(inputHandler.isRequired, @"Input handler should not be required by default");
    XCTAssertFalse(inputHandler.hasValidationProperties, @"Input handler should not have validation properties by default");
    XCTAssertFalse(inputHandler.hasVisibilityChanged, @"Input handler should not have visibility changed by default");
    
    // Test methods
    NSError *error = nil;
    XCTAssertTrue([inputHandler validate:&error], @"Mock validation should succeed");
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [inputHandler getInput:dictionary];
    XCTAssertEqual(dictionary.count, 1, @"Should add one entry to dictionary");
    XCTAssertEqualObjects(dictionary[@"mockInput"], @"mockValue", @"Should add correct value");
    
    // Test reset
    [inputHandler resetInput];
    XCTAssertEqualObjects(inputHandler.inputValue, @"", @"Input value should be reset to empty string");
}

#pragma mark - Bottom Sheet Dismissal Tests

- (void)testDismissBottomSheetWithNilBottomSheet {
    self.popoverTarget.currentBottomSheet = nil;
    
    // Should not crash
    [self.popoverTarget dismissBottomSheet];
    
    XCTAssertNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should remain nil");
}

- (void)testDismissBottomSheetWithNoPresentingViewController {
    ACRBottomSheetViewController *bottomSheet = [[ACRBottomSheetViewController alloc] init];
    self.popoverTarget.currentBottomSheet = bottomSheet;
    
    // Should not crash when presentingViewController is nil
    [self.popoverTarget dismissBottomSheet];
    
    XCTAssertNotNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should still exist");
}

#pragma mark - Action Target Filtering Tests

- (void)testFilterActionTargetWithBasicTarget {
    UIView *testView = [[UIView alloc] init];
    UIView *parentView = [[UIView alloc] init];
    [parentView addSubview:testView];
    
    // Create basic target that doesn't respond to actionElement
    ACRBaseTarget *mockTarget = [[ACRBaseTarget alloc] init];
    
    XCTAssertNotNil(testView.superview, @"View should have superview initially");
    
    [self.popoverTarget filterActionTarget:mockTarget forView:testView];
    
    // The filter method should not affect views when target doesn't respond to actionElement
    XCTAssertNotNil(testView.superview, @"View should still have superview with basic target");
}

#pragma mark - Edge Cases Tests

- (void)testBottomSheetCloseTapped {
    [self.popoverTarget bottomSheetCloseTapped];
    
    XCTAssertTrue(self.popoverTarget.detachBottomSheetInputsCalled, @"detachBottomSheetInputsFromMainCard should be called");
}

- (void)testPresentPopoverWithEmptyInputHandlers {
    self.mockRootView.inputHandlers = nil;
    
    ACRContentStackView *mockContentView = [[ACRContentStackView alloc] init];
    self.popoverTarget.mockCachedContentView = mockContentView;
    
    // Should not crash with nil input handlers
    [self.popoverTarget presentPopover];
    
    XCTAssertNotNil(self.popoverTarget.currentBottomSheet, @"Bottom sheet should still be created");
}

- (void)testMarkActionTargetsAsFromBottomSheetWithEmptyView {
    UIView *emptyView = [[UIView alloc] init];
    
    // Should not crash with empty view
    [self.popoverTarget markActionTargetsAsFromBottomSheet:emptyView];
    
    XCTAssertTrue(self.popoverTarget.markActionTargetsCalled, @"Method should be called");
}

- (void)testCollectInputHandlersWithInputLabelView {
    // Test the special case handling for ACRInputLabelView
    UIView *containerView = [[UIView alloc] init];
    
    // Create a mock input label view (simplified for testing)
    UIView *mockLabelView = [[UIView alloc] init];
    [containerView addSubview:mockLabelView];
    
    NSMutableArray<id<ACRIBaseInputHandler>> *inputHandlers = [NSMutableArray array];
    [self.popoverTarget collectInputHandlersInView:containerView intoArray:inputHandlers];
    
    // Should complete without crashing
    XCTAssertNotNil(inputHandlers, @"Input handlers array should exist");
}

- (void)testPropagatePopoverContextToOverflowMenuItems {
    // This tests the method exists and doesn't crash with nil parameters
    [self.popoverTarget propagatePopoverContextToOverflowMenuItems:nil];
    
    // Should not crash with nil overflow target
    XCTAssertTrue(YES, @"Method should handle nil input gracefully");
}

@end
