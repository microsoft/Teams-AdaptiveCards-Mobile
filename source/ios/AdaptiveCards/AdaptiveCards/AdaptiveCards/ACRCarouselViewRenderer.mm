//
//  ACRCarouselViewRenderer.m
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 09/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACOBaseCardElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRColumnView.h"
#import "ACRContentHoldingUIView.h"
#import "ACRImageProperties.h"
#import "ACRTapGestureRecognizerFactory.h"
#import "ACRUIImageView.h"
#import "ACRView.h"
#import "Enums.h"
#import "Icon.h"
#import "SharedAdaptiveCard.h"
#import "UtiliOS.h"
#import "ACRSVGImageView.h"
#import "ACRSVGIconHoldingView.h"
#import "CompoundButton.h"
#import "ACRCompoundButtonRenderer.h"
#import "ACRUILabel.h"
#import "UtiliOS.h"
#import "ACRCarouselViewRenderer.h"
#import "Carousel.h"
#import "ACRCarouselView.h"
#import "CarouselViewBottomBar.h"
#import "ACRRenderer.h"
#import "FlowLayout.h"
#import "AreaGridLayout.h"
#import "ACRFlowLayout.h"
#import "ARCGridViewLayout.h"
#import "ACRLayoutHelper.h"
#import "CarouselPage.h"
#import "ACRRendererPrivate.h"
#import "ACRPageIndicator.h"

@interface ACRCarouselViewRenderer()

@property NSInteger carouselPageViewIndex;
@property PageControl *pageControl;
@property NSMutableArray<UIView *> *carouselPageViewList;
@property std::shared_ptr<Carousel> carousel;
@end

@implementation ACRCarouselViewRenderer


+ (ACRCarouselViewRenderer *)getInstance
{
    static ACRCarouselViewRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRCarouselView;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Carousel> carousel = std::dynamic_pointer_cast<Carousel>(elem);
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    self.carouselPageViewList = [[NSMutableArray alloc] init];
    
    self.carousel = carousel;
    
    UIView * carouselPagesContainerView = [[UIView alloc] init];
    carouselPagesContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    for(auto carouselPage: carousel->GetItems()) {
        UIView * carouselPageView = [self getCarouselPageView:carouselPage
                                                    viewGroup:viewGroup
                                                     rootView:rootView
                                                       inputs:inputs
                                              baseCardElement:acoElem
                                                   hostConfig:acoConfig];
        [self.carouselPageViewList addObject:carouselPageView];
    }
    
    if (self.carouselPageViewList.count == 0) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    for(UIView *carouselPageView in self.carouselPageViewList) {
        carouselPageView.translatesAutoresizingMaskIntoConstraints = NO;
        carouselPageView.clipsToBounds = YES;
        carouselPageView.hidden = YES;
        [carouselPagesContainerView addSubview:carouselPageView];
        [NSLayoutConstraint activateConstraints:@[
            [carouselPageView.leadingAnchor constraintEqualToAnchor:carouselPagesContainerView.leadingAnchor],
            [carouselPageView.trailingAnchor constraintEqualToAnchor:carouselPagesContainerView.trailingAnchor],
            [carouselPageView.topAnchor constraintEqualToAnchor:carouselPagesContainerView.topAnchor],
            [carouselPageView.bottomAnchor constraintEqualToAnchor:carouselPagesContainerView.bottomAnchor],
            [carouselPagesContainerView.heightAnchor constraintGreaterThanOrEqualToAnchor:carouselPageView.heightAnchor]
        ]];
    }
    
    [self constructSwipeActions:carouselPagesContainerView];
    
    if(self.carouselPageViewList.count > 0) {
        self.carouselPageViewList[0].hidden = NO;
        self.carouselPageViewIndex = 0;
    }
    
    PageControlConfig *pageControlConfig = [[PageControlConfig alloc] initWithNumberOfPages:self.carouselPageViewList.count
                                                                               displayPages:@5
                                                                         hidesForSinglePage:@0
                                                                   accessibilityValueFormat:@""];
    
    self.pageControl = [[PageControl alloc] initWithFrame:CGRectZero];
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pageControl setConfig:pageControlConfig];
    
    UIStackView *carouselView = [[UIStackView alloc] init];
    carouselView.axis = UILayoutConstraintAxisVertical;
    carouselView.alignment = UIStackViewAlignmentCenter;
    carouselView.translatesAutoresizingMaskIntoConstraints = NO;
    carouselView.spacing = 20;
    carouselView.clipsToBounds = YES;
    
    [carouselView addArrangedSubview:carouselPagesContainerView];
    [carouselView addArrangedSubview:self.pageControl];
    
    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:carouselView withAreaName:areaName];
    
    return carouselView;
}

-(void) constructSwipeActions:(UIView *)view {
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(handleLeftSwipe:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(handleRightSwipe:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:rightSwipe];
}

- (void)handleLeftSwipe:(UISwipeGestureRecognizer *)gesture {
    NSInteger newCarouselPageViewIndex = MIN(self.carouselPageViewIndex+1, self.carouselPageViewList.count-1);
    if(newCarouselPageViewIndex == self.carouselPageViewIndex) {
        return;
    }
    [self.pageControl setCurrentPage:newCarouselPageViewIndex];
    
    UIView *oldView = self.carouselPageViewList[self.carouselPageViewIndex];
    UIView *newView = self.carouselPageViewList[newCarouselPageViewIndex];
    
    switch (self.carousel->getPageAnimation()) {
        case PageAnimation::Slide:
            [self slideAnimationForNextView:oldView
                                   showView:newView];
            break;
        case PageAnimation::CrossFade:
            [self crossfadeFromView:oldView toView:newView];
        case PageAnimation::None:
            oldView.hidden = YES;
            newView.hidden = NO;
        default:
            break;
    }
    self.carouselPageViewIndex = newCarouselPageViewIndex;
}

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)gesture {
    NSInteger newCarouselPageViewIndex = MAX(self.carouselPageViewIndex-1, 0);
    
    if(newCarouselPageViewIndex == self.carouselPageViewIndex) {
        return;
    }
    
    [self.pageControl setCurrentPage:newCarouselPageViewIndex];
    
    UIView *oldView = self.carouselPageViewList[self.carouselPageViewIndex];
    UIView *newView = self.carouselPageViewList[newCarouselPageViewIndex];
    
    switch (self.carousel->getPageAnimation()) {
        case PageAnimation::Slide:
            [self slideAnimationForPreviousView:oldView
                                   showView:newView];
            break;
        case PageAnimation::CrossFade:
            [self crossfadeFromView:oldView toView:newView];
        case PageAnimation::None:
            oldView.hidden = YES;
            newView.hidden = NO;
        default:
            break;
    }
    self.carouselPageViewIndex = newCarouselPageViewIndex;
}

- (void)crossfadeFromView:(UIView *)fromView toView:(UIView *)toView {
    
    [UIView transitionWithView:fromView.superview
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        fromView.hidden = YES;  // Hide the current view
                        toView.hidden = NO;    // Show the next view
                    }
                    completion:nil];
}

- (void)slideAnimationForNextView:(UIView *)viewToHide showView:(UIView *)viewToShow {
    // Prepare the view to show
    viewToShow.transform = CGAffineTransformMakeTranslation(viewToShow.bounds.size.width, 0);
    viewToShow.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        // Slide out the current view
        viewToHide.transform = CGAffineTransformMakeTranslation(-viewToHide.bounds.size.width, 0);
        
        // Slide in the new view
        viewToShow.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        viewToHide.hidden = YES;
        viewToHide.transform = CGAffineTransformIdentity; // Reset transform for future use
    }];
}

- (void)slideAnimationForPreviousView:(UIView *)viewToHide showView:(UIView *)viewToShow {
    // Prepare the view to show
    viewToShow.transform = CGAffineTransformMakeTranslation(-viewToShow.bounds.size.width, 0);
    viewToShow.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        // Slide out the current view
        viewToHide.transform = CGAffineTransformMakeTranslation(viewToHide.bounds.size.width, 0);

        // Slide in the new view
        viewToShow.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        viewToHide.hidden = YES;
        viewToHide.transform = CGAffineTransformIdentity; // Reset transform for future use
    }];
}

- (UIView *)  getCarouselPageView:(std::shared_ptr<AdaptiveCards::BaseCardElement>) element
                        viewGroup:(UIView<ACRIContentHoldingView> *)viewGroup
                         rootView:(ACRView *)rootView
                           inputs:(NSMutableArray *)inputs
                  baseCardElement:(ACOBaseCardElement *)acoElem
                       hostConfig:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<CarouselPage> containerElem = std::dynamic_pointer_cast<CarouselPage>(element);
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    float widthOfElement = [rootView widthForElement:elem->GetInternalId().Hash()];
    std::shared_ptr<Layout> final_layout = [[[ACRLayoutHelper alloc] init] layoutToApplyFrom:containerElem->GetLayouts() andHostConfig:acoConfig];
    [rootView.context pushBaseCardElementContext:acoElem];
    ACRFlowLayout *flowContainer;
    ARCGridViewLayout *gridLayout;
    if(final_layout->GetLayoutContainerType() == LayoutContainerType::Flow)
    {
        NSObject<ACRIFeatureFlagResolver> *featureFlagResolver = [[ACRRegistration getInstance] getFeatureFlagResolver];
        BOOL isFlowLayoutEnabled = [featureFlagResolver boolForFlag:@"isFlowLayoutEnabled"] ?: NO;
        
        if(isFlowLayoutEnabled)
        {
            std::shared_ptr<FlowLayout> flow_layout = std::dynamic_pointer_cast<FlowLayout>(final_layout);
            // layout using flow layout
            flowContainer = [[ACRFlowLayout alloc] initWithFlowLayout:flow_layout
                                                                style:(ACRContainerStyle)containerElem->GetStyle()
                                                          parentStyle:[viewGroup style]
                                                           hostConfig:acoConfig
                                                             maxWidth:widthOfElement
                                                            superview:viewGroup];
            
            [ACRRenderer renderInGridOrFlow:flowContainer
                                   rootView:rootView
                                     inputs:inputs
                              withCardElems:containerElem->GetItems()
                              andHostConfig:acoConfig];
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
                                                                 style:(ACRContainerStyle)containerElem->GetStyle()
                                                           parentStyle:[viewGroup style]
                                                            hostConfig:acoConfig
                                                             superview:viewGroup];
            [ACRRenderer renderInGridOrFlow:gridLayout
                                   rootView:rootView
                                     inputs:inputs
                              withCardElems:containerElem->GetItems()
                              andHostConfig:acoConfig];
        }
    }

    ACRColumnView *container = [[ACRColumnView alloc] initWithStyle:(ACRContainerStyle)containerElem->GetStyle()
                                                        parentStyle:[viewGroup style]
                                                         hostConfig:acoConfig
                                                          superview:viewGroup];
    container.rtl = rootView.context.rtl;

    if(flowContainer != nil)
    {
        [container addArrangedSubview:flowContainer];
    }
    else if (gridLayout != nil)
    {
        [container addArrangedSubview:gridLayout];
    }
    else
    {
        [ACRRenderer render:container
                   rootView:rootView
                     inputs:inputs
              withCardElems:containerElem->GetItems()
              andHostConfig:acoConfig];
    }
    
    [self configureBorderForCarouselPage:containerElem container:container config:acoConfig];
    
    renderBackgroundImage(containerElem->GetBackgroundImage(), container, rootView);

    container.frame = viewGroup.frame;

    [container setClipsToBounds:NO];

    std::shared_ptr<BaseActionElement> selectAction = containerElem->GetSelectAction();
    ACOBaseActionElement *acoSelectAction = [ACOBaseActionElement getACOActionElementFromAdaptiveElement:selectAction];
    [container configureForSelectAction:acoSelectAction rootView:rootView];

    [container configureLayoutAndVisibility:GetACRVerticalContentAlignment(containerElem->GetVerticalContentAlignment().value_or(VerticalContentAlignment::Top))
                                  minHeight:containerElem->GetMinHeight()
                                 heightType:GetACRHeight(containerElem->GetHeight())
                                       type:ACRContainer];

    container.accessibilityElements = [container getArrangedSubviews];
    [rootView.context popBaseCardElementContext:acoElem];
    return container;
}

- (void)configureBorderForCarouselPage:(std::shared_ptr<CarouselPage> ) containerElem
                             container:(ACRContentStackView *)container
                                config:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    bool shouldShowBorder = containerElem->GetShowBorder();
    if(shouldShowBorder)
    {
        ACRContainerStyle style = (ACRContainerStyle)containerElem->GetStyle();
        container.layer.borderWidth = config->GetBorderWidth(containerElem->GetElementType());
        auto borderColor = config->GetBorderColor([ACOHostConfig getSharedContainerStyle:style]);
        UIColor *color = [ACOHostConfig convertHexColorCodeToUIColor:borderColor];
        // we will add padding for any column element which has shouldShowBorder.
        [container applyPadding:config->GetSpacing().paddingSpacing priority:1000];
        [[container layer] setBorderColor:[color CGColor]];
    }
    
    bool roundedCorner = containerElem->GetRoundedCorners();
    if (roundedCorner)
    {
        container.layer.cornerRadius = config->GetCornerRadius(containerElem->GetElementType());
    }
}

@end

