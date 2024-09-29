//
//  ACRCarouselView.mm
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 25/09/24.
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
#import "ACRRenderer.h"
#import "FlowLayout.h"
#import "AreaGridLayout.h"
#import "ACRFlowLayout.h"
#import "ARCGridViewLayout.h"
#import "ACRLayoutHelper.h"
#import "CarouselPage.h"
#import "ACRRendererPrivate.h"
#import "ACRPageControl.h"
#import "ACRCarouselPageView.h"
#import "ACRCarouselPageContainerView.h"
#import "ACRCarouselView.h"
#import "ACRCarouselView.h"
#import "ACRCarouselPageContainerView.h"

@interface ACRCarouselView()

@property NSInteger carouselPageViewIndex;
@property ACRPageControl *pageControl;
@property NSMutableArray<UIView *> *carouselPageViewList;
@property std::shared_ptr<Carousel> carousel;

@end

@implementation ACRCarouselView

-(instancetype) initWithViewGroup:(UIView<ACRIContentHoldingView> *)viewGroup
                      rootView:(ACRView *)rootView
                        inputs:(NSMutableArray *)inputs
               baseCardElement:(ACOBaseCardElement *)acoElem
                    hostConfig:(ACOHostConfig *)acoConfig
{
    self = [super initWithFrame:CGRectZero];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Carousel> carousel = std::dynamic_pointer_cast<Carousel>(elem);
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    self.carouselPageViewList = [[NSMutableArray alloc] init];
    
    self.carousel = carousel;
    
    
    ACRColumnView *carouselViewContainer = [[ACRColumnView alloc] initWithStyle:(ACRContainerStyle)carousel->GetStyle()
                                                        parentStyle:[viewGroup style]
                                                         hostConfig:acoConfig
                                                          superview:viewGroup];
    
    for(auto carouselPage: carousel->GetItems()) {
        
        ACOBaseCardElement *acoElement = [[ACOBaseCardElement alloc] initWithBaseCardElement:carouselPage];
        
        UIView * carouselPageView = [[ACRCarouselPageView alloc] render:carouselViewContainer
                                                               rootView:rootView
                                                                 inputs:inputs
                                                        baseCardElement:acoElement
                                                             hostConfig:acoConfig];
        carouselPageView.hidden = YES;
        
        [self.carouselPageViewList addObject:carouselPageView];
    }
    
    if (self.carouselPageViewList.count == 0) {
        return self;
    }
    
    UIView * carouselPagesContainerView = [[ACRCarouselPageContainerView alloc] initWithCarouselPageViewList:_carouselPageViewList];
    
    self.carouselPageViewList[0].hidden = NO;
    self.carouselPageViewIndex = 0;
    
    std::string selctedPageControlTintColor = config->GetPageControlConfig().selectedTintColor;
    std::string unselctedPageControlTintColor = config->GetPageControlConfig().unselectedTintColor;
    
    ACRPageControlConfig *pageControlConfig = [[ACRPageControlConfig alloc] initWithNumberOfPages:self.carouselPageViewList.count
                                                                                     displayPages:@7
                                                                                 selctedTintColor:[ACOHostConfig convertHexColorCodeToUIColor:selctedPageControlTintColor]
                                                                               unselctedTintColor:[ACOHostConfig convertHexColorCodeToUIColor:unselctedPageControlTintColor]];
    
    self.pageControl = [[ACRPageControl alloc] initWithConfig:pageControlConfig];
    
    UIStackView *carouselStackView = [[UIStackView alloc] init];
    [carouselViewContainer addArrangedSubview:carouselStackView];
    
    carouselStackView.axis = UILayoutConstraintAxisVertical;
    carouselStackView.alignment = UIStackViewAlignmentCenter;
    carouselStackView.translatesAutoresizingMaskIntoConstraints = NO;
    carouselStackView.spacing = 20;
    carouselStackView.clipsToBounds = YES;
    
    [carouselStackView addArrangedSubview:carouselPagesContainerView];
    [carouselStackView addArrangedSubview:self.pageControl];
    [carouselStackView addArrangedSubview:[[UIView alloc] initWithFrame:CGRectZero]];
    
    configBleed(rootView, elem, carouselViewContainer, acoConfig);
    [self constructSwipeActions:carouselViewContainer];
    
    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:self withAreaName:areaName];
    
    [self addSubview:carouselViewContainer];
    [NSLayoutConstraint activateConstraints:@[
        [self.leadingAnchor constraintEqualToAnchor:carouselViewContainer.leadingAnchor],
        [self.trailingAnchor constraintEqualToAnchor:carouselViewContainer.trailingAnchor],
        [self.bottomAnchor constraintEqualToAnchor:carouselViewContainer.bottomAnchor],
        [self.topAnchor constraintEqualToAnchor:carouselViewContainer.topAnchor]
    ]];
    
    return self;
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
            [self slideAnimationForLeftSwipeForViewToHide:oldView
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
            [self slideAnimationForRightSwipeForViewToHide:oldView
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
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        fromView.hidden = YES;  // Hide the current view
                        toView.hidden = NO;    // Show the next view
                    }
                    completion:nil];
}

- (void)slideAnimationForLeftSwipeForViewToHide:(UIView *)viewToHide showView:(UIView *)viewToShow {
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

- (void)slideAnimationForRightSwipeForViewToHide:(UIView *)viewToHide showView:(UIView *)viewToShow {
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

@end


