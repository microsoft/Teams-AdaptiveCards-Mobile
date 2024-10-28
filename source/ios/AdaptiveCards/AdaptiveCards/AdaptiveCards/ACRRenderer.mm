//
//  ACRRenderer.mm
//  ACRRenderer.h
//
//  Copyright © 2017 Microsoft. All rights reserved.
//
#import "ACOAdaptiveCardPrivate.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRBaseActionElementRenderer.h"
#import "ACRBaseCardElementRenderer.h"
#import "ACRColumnSetView.h"
#import "ACRColumnView.h"
#import "ACRContentHoldingUIScrollView.h"
#import "ARCGridViewLayout.h"
#import "ACRImageRenderer.h"
#import "ACRRegistration.h"
#import "ACRRegistrationPrivate.h"
#import "ACRRendererPrivate.h"
#import "ACRSeparator.h"
#import "ACRUIImageView.h"
#import "ACRViewController.h"
#import "ACRViewPrivate.h"
#import "UtiliOS.h"
#import "ACRLayoutHelper.h"
#import "ACRFlowLayout.h"
#import "FlowLayout.h"
#import "AreaGridLayout.h"

using namespace AdaptiveCards;

@implementation ACRRenderer

- (instancetype)init
{
    self = [super init];
    return self;
}

// This interface is exposed to outside, and returns ACRRenderResult object
// This object contains a viewController instance which defer rendering adaptiveCard until viewDidLoad is called.
+ (ACRRenderResult *)render:(ACOAdaptiveCard *)card config:(ACOHostConfig *)config widthConstraint:(float)width delegate:(id<ACRActionDelegate>)acrActionDelegate
{
    ACRRenderResult *result = [[ACRRenderResult alloc] init];
    // Initializes ACRView instance with HostConfig and AdaptiveCard
    // ACRViewController does not render adaptiveCard until viewDidLoad calls render
    ACRView *view = [[ACRView alloc] init:card hostconfig:config widthConstraint:width delegate:acrActionDelegate];
    result.view = view;
    result.warnings = view.warnings;
    result.succeeded = YES;
    return result;
}

// This interface is exposed to outside, and returns ACRRenderResult object
// This object contains a viewController instance which defer rendering adaptiveCard until viewDidLoad is called.
+ (ACRRenderResult *)render:(ACOAdaptiveCard *)card config:(ACOHostConfig *)config widthConstraint:(float)width
{
    return [ACRRenderer render:card config:config widthConstraint:width delegate:nil];
}

// This interface is exposed to outside, and returns ACRRenderResult object
// This object contains a viewController instance which defer rendering adaptiveCard until viewDidLoad is called.
+ (ACRRenderResult *)renderAsViewController:(ACOAdaptiveCard *)card config:(ACOHostConfig *)config frame:(CGRect)frame delegate:(id<ACRActionDelegate>)acrActionDelegate
{
    ACRRenderResult *result = [[ACRRenderResult alloc] init];
    // Initializes ACRView instance with HostConfig and AdaptiveCard
    // ACRView does not render adaptiveCard until viewDidLoad calls render
    ACRViewController *viewcontroller = [[ACRViewController alloc] init:card hostconfig:config frame:frame delegate:acrActionDelegate];
    result.viewcontroller = viewcontroller;
    result.warnings = ((ACRView *)viewcontroller.view).warnings;
    result.succeeded = YES;
    return result;
}

// transforms (i.e. renders) an adaptiveCard to a new UIView instance
+ (UIView *)renderWithAdaptiveCards:(std::shared_ptr<AdaptiveCard> const &)adaptiveCard
                             inputs:(NSMutableArray *)inputs
                            context:(ACRView *)rootView
                     containingView:(ACRColumnView *)containingView
                         hostconfig:(ACOHostConfig *)config
{
    ACRLayoutHelper *layoutHelper = [[ACRLayoutHelper alloc] init];
    [layoutHelper distributeWidth:[[ACRRegistration getInstance] getHostCardContainer] rootView:rootView forElement:adaptiveCard andHostConfig:config];

    std::vector<std::shared_ptr<BaseCardElement>> body = adaptiveCard->GetBody();
    ACRColumnView *verticalView = containingView;

    std::vector<std::shared_ptr<BaseActionElement>> actions = adaptiveCard->GetActions();
    
    if (!actions.empty()) {
        [rootView loadImagesForActionsAndCheckIfAllActionsHaveIconImages:actions hostconfig:config hash:iOSInternalIdHash(adaptiveCard->GetInternalId().Hash())];
    }
    
    // set context
    ACOAdaptiveCard *wrapperCard = [[ACOAdaptiveCard alloc] init];
    [wrapperCard setCard:adaptiveCard];
    
    [rootView.context pushCardContext:wrapperCard];
    
    auto backgroundImageProperties = adaptiveCard->GetBackgroundImage();
    verticalView.rtl = rootView.context.rtl;

    std::shared_ptr<BaseActionElement> selectAction = adaptiveCard->GetSelectAction();
    if (selectAction) {
        ACOBaseActionElement *acoSelectAction = [ACOBaseActionElement getACOActionElementFromAdaptiveElement:selectAction];
        [verticalView configureForSelectAction:acoSelectAction rootView:rootView];
    }

    if ((backgroundImageProperties != nullptr) && !(backgroundImageProperties->GetUrl().empty())) {
        ObserverActionBlock observerAction =
            ^(NSObject<ACOIResourceResolver> *imageResourceResolver, NSString *key, std::shared_ptr<BaseCardElement> const &elem, NSURL *url, ACRView *rootView) {
                UIImageView *view = [imageResourceResolver resolveImageViewResource:url];
                if (view) {
                    [view addObserver:rootView
                           forKeyPath:@"image"
                              options:NSKeyValueObservingOptionNew
                              context:backgroundImageProperties.get()];

                    // store the image view and card for easy retrieval in ACRView::observeValueForKeyPath
                    [rootView setImageView:key view:view];
                }
            };
        [rootView loadBackgroundImageAccordingToResourceResolverIF:backgroundImageProperties key:@"backgroundImage" observerAction:observerAction];
    }

    ACRContainerStyle style = ([config getHostConfig]->GetAdaptiveCard().allowCustomStyle) ? (ACRContainerStyle)adaptiveCard->GetStyle() : ACRDefault;
    style = (style == ACRNone) ? ACRDefault : style;
    [verticalView setStyle:style];

    [rootView addBaseCardElementListToConcurrentQueue:body registration:[ACRRegistration getInstance]];
    
    std::shared_ptr<Layout> final_layout = [layoutHelper layoutToApplyFrom:adaptiveCard->GetLayouts() andHostConfig:config];
    ACRFlowLayout *flowContainer;
    ARCGridViewLayout *gridLayout;
    if(final_layout->GetLayoutContainerType() == LayoutContainerType::Flow)
    {
        NSObject<ACRIFeatureFlagResolver> *featureFlagResolver = [[ACRRegistration getInstance] getFeatureFlagResolver];
        BOOL isFlowLayoutEnabled = [featureFlagResolver boolForFlag:@"isFlowLayoutEnabled"] ?: NO;
        if (isFlowLayoutEnabled)
        {
            std::shared_ptr<FlowLayout> flow_layout = std::dynamic_pointer_cast<FlowLayout>(final_layout);
            // layout using flow layout
            flowContainer = [[ACRFlowLayout alloc] initWithFlowLayout:flow_layout
                                                                style:style
                                                          parentStyle:style
                                                           hostConfig:config
                                                             maxWidth:[[ACRRegistration getInstance] getHostCardContainer]
                                                            superview:containingView];
            
            [ACRRenderer renderInGridOrFlow:flowContainer
                                   rootView:rootView
                                     inputs:inputs
                              withCardElems:body
                              andHostConfig:config];
        }
    }
    else if (final_layout->GetLayoutContainerType() == LayoutContainerType::AreaGrid)
    {
        NSObject<ACRIFeatureFlagResolver> *featureFlagResolver = [[ACRRegistration getInstance] getFeatureFlagResolver];
        BOOL isGridLayoutEnabled = [featureFlagResolver boolForFlag:@"isGridLayoutEnabled"] ?: NO;
        if (isGridLayoutEnabled)
        {
            std::shared_ptr<AreaGridLayout> grid_layout = std::dynamic_pointer_cast<AreaGridLayout>(final_layout);
            gridLayout = [[ARCGridViewLayout alloc] initWithGridLayout:grid_layout
                                                                 style:style
                                                           parentStyle:style
                                                            hostConfig:config
                                                             superview:containingView];
            [ACRRenderer renderInGridOrFlow:gridLayout
                                   rootView:rootView
                                     inputs:inputs
                              withCardElems:body
                              andHostConfig:config];
        }
    }
    
    @try {
        
        if(flowContainer != nil)
        {
            [verticalView addArrangedSubview:flowContainer];
        }
        else if(gridLayout != nil)
        {
            [verticalView addArrangedSubview:gridLayout];
        }
        else
        {
            [ACRRenderer render:verticalView rootView:rootView inputs:inputs withCardElems:body andHostConfig:config];
        }

        [verticalView configureLayoutAndVisibility:GetACRVerticalContentAlignment(adaptiveCard->GetVerticalContentAlignment())
                                         minHeight:adaptiveCard->GetMinHeight()
                                        heightType:GetACRHeight(adaptiveCard->GetHeight())
                                              type:ACRColumn];

        [[rootView card] setInputs:inputs];

        if (!actions.empty()) {
            [ACRSeparator renderActionsSeparator:verticalView hostConfig:[config getHostConfig]];

            // renders buttons and their associated actions
            ACOAdaptiveCard *card = [[ACOAdaptiveCard alloc] init];
            [card setCard:adaptiveCard];
            [ACRRenderer renderActions:rootView inputs:inputs superview:verticalView card:card hostConfig:config];
        }
        
    } @catch (ACOFallbackException *e) {
        
        handleRootFallback(rootView.card.card, verticalView, rootView, inputs, config);
    }
    
    // renders background image for AdaptiveCard and an inner AdaptiveCard in a ShowCard
    renderBackgroundImage(backgroundImageProperties, verticalView, rootView);

    [rootView.context popCardContext:wrapperCard];

    return verticalView;
}

+ (UIView *)renderActions:(ACRView *)rootView
                   inputs:(NSMutableArray *)inputs
                superview:(UIView<ACRIContentHoldingView> *)superview
                     card:(ACOAdaptiveCard *)card
               hostConfig:(ACOHostConfig *)config
{
    ACRRegistration *reg = [ACRRegistration getInstance];
    return [[reg getActionSetRenderer] renderButtons:rootView inputs:inputs superview:superview card:card hostConfig:config];
}

+ (UIView *)render:(UIView<ACRIContentHoldingView> *)view
          rootView:(ACRView *)rootView
            inputs:(NSMutableArray *)inputs
     withCardElems:(std::vector<std::shared_ptr<BaseCardElement>> const &)elems
     andHostConfig:(ACOHostConfig *)config
{
    ACRRegistration *reg = [ACRRegistration getInstance];
    ACOBaseCardElement *acoElem = [[ACOBaseCardElement alloc] init];
    ACOFeatureRegistration *featureReg = [ACOFeatureRegistration getInstance];
    
    // Get responsive layout's host width
    HostWidthConfig hostWidthConfig = [config getHostConfig]->getHostWidth();
    HostWidth hostWidth = convertHostCardContainerToHostWidth([reg getHostCardContainer], hostWidthConfig);

    UIView *renderedView = nil;

    auto firstelem = elems.begin();

    for (const auto &elem : elems) {
        ACRSeparator *separator = nil;
        if (*firstelem != elem && renderedView && elem->MeetsTargetWidthRequirement(hostWidth)) {
            separator = [ACRSeparator renderSeparation:elem
                                          forSuperview:view
                                        withHostConfig:[config getHostConfig]];
        }

        ACRBaseCardElementRenderer *renderer =
            [reg getRenderer:[NSNumber numberWithInt:(int)elem->GetElementType()]];

        if (renderer == nil) {
            NSLog(@"Unsupported card element type:%d\n", (int)elem->GetElementType());
            continue;
        }

        [acoElem setElem:elem];

        @try {
            if ([acoElem meetsRequirements:featureReg] == NO){
                @throw [ACOFallbackException fallbackException];
            }
            if (elem->MeetsTargetWidthRequirement(hostWidth) == false){
                continue;
            }

            renderedView = [renderer render:view rootView:rootView inputs:inputs baseCardElement:acoElem hostConfig:config];

            [view updateLayoutAndVisibilityOfRenderedView:renderedView acoElement:acoElem separator:separator rootView:rootView];

            if (separator && !renderedView) {
                [(ACRContentStackView *)view removeViewFromContentStackView:separator];
            }
        } @catch (ACOFallbackException *e) {
            
            handleFallbackException(e, view, rootView, inputs, elem, config, true);
        }
    }

    view.accessibilityElements = [(ACRContentStackView *)view getArrangedSubviews];

    return view;
}

+ (UIView *)renderInGridOrFlow:(UIView<ACRIContentHoldingView> *)view
                      rootView:(ACRView *)rootView
                        inputs:(NSMutableArray *)inputs
                 withCardElems:(std::vector<std::shared_ptr<BaseCardElement>> const &)elems
                 andHostConfig:(ACOHostConfig *)config
{
    ACRRegistration *reg = [ACRRegistration getInstance];
    ACOBaseCardElement *acoElem = [[ACOBaseCardElement alloc] init];
    ACOFeatureRegistration *featureReg = [ACOFeatureRegistration getInstance];

    // Get responsive layout's host width
    HostWidthConfig hostWidthConfig = [config getHostConfig]->getHostWidth();
    HostWidth hostWidth = convertHostCardContainerToHostWidth([reg getHostCardContainer], hostWidthConfig);

    UIView *renderedView = nil;

    for (const auto &elem : elems)
    {
        ACRBaseCardElementRenderer *renderer =
        [reg getRenderer:[NSNumber numberWithInt:(int)elem->GetElementType()]];

        if (renderer == nil)
        {
            NSLog(@"Unsupported card element type:%d\n", (int)elem->GetElementType());
            continue;
        }

        [acoElem setElem:elem];

        @try
        {
            if ([acoElem meetsRequirements:featureReg] == NO)
            {
                @throw [ACOFallbackException fallbackException];
            }

            if (elem->MeetsTargetWidthRequirement(hostWidth) == false)
            {
                continue;
            }

            if (!elem->GetIsVisible())
            {
                continue;
            }

            renderedView = [renderer render:view rootView:rootView inputs:inputs baseCardElement:acoElem hostConfig:config];

            [view updateLayoutAndVisibilityOfRenderedView:renderedView acoElement:acoElem separator:nil rootView:rootView];
        }
        @catch (ACOFallbackException *e)
        {
            handleFallbackException(e, view, rootView, inputs, elem, config, true);
        }
    }

    return view;

}
@end
