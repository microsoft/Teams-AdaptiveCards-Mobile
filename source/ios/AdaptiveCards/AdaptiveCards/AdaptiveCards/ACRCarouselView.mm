//
//  ACRCarouselView.mm
//  AdaptiveCards
//
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACOBaseCardElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRColumnView.h"
#import "ACRContentHoldingUIView.h"
#import "CarouselPage.h"
#import "ACRRendererPrivate.h"
#import "ACRPageControl.h"
#import "ACRCarouselPageView.h"
#import "ACRCarouselPageContainerView.h"
#import "ACRCarouselView.h"
#import "ACRCarouselPageContainerView.h"
#import "Carousel.h"
#import "UtiliOS.h"

@interface ACRCarouselView()

@property NSInteger carouselPageViewIndex;
@property ACRPageControl *pageControl;
@property NSMutableArray<UIView *> *carouselPageViewList;
@property std::shared_ptr<Carousel> carousel;
@property ACRCarouselPageContainerView *carouselPagesContainerView;

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
    
    for(auto carouselPage: carousel->GetPages())
    {
        
        ACOBaseCardElement *acoElement = [[ACOBaseCardElement alloc] initWithBaseCardElement:carouselPage];
        
        UIView * carouselPageView = [[ACRCarouselPageView alloc] render:carouselViewContainer
                                                               rootView:rootView
                                                                 inputs:inputs
                                                        baseCardElement:acoElement
                                                             hostConfig:acoConfig];
        carouselPageView.hidden = YES;
        
        [self.carouselPageViewList addObject:carouselPageView];
    }
    
    if (self.carouselPageViewList.count == 0)
    {
        return self;
    }
    
    ACRCarouselPageContainerView * carouselPagesContainerView = [[ACRCarouselPageContainerView alloc] initWithCarouselPageViewList:_carouselPageViewList
                                                                                               pageAnimation:carousel->getPageAnimation()];
    self.carouselPagesContainerView = carouselPagesContainerView;
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
  
    
    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:self withAreaName:areaName];
    
    [self addSubview:carouselViewContainer];
    [NSLayoutConstraint activateConstraints:@[
        [self.leadingAnchor constraintEqualToAnchor:carouselViewContainer.leadingAnchor],
        [self.trailingAnchor constraintEqualToAnchor:carouselViewContainer.trailingAnchor],
        [self.bottomAnchor constraintEqualToAnchor:carouselViewContainer.bottomAnchor],
        [self.topAnchor constraintEqualToAnchor:carouselViewContainer.topAnchor]
    ]];
    
    [self constructGestures:self];
    
    return self;
}

-(void) constructGestures:(UIView *)view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
    panGesture.delegate = self;
}

- (void)handleLeftSwipe
{
    NSInteger newCarouselPageViewIndex = MIN(self.carouselPageViewIndex+1, self.carouselPageViewList.count-1);
    if(newCarouselPageViewIndex == self.carouselPageViewIndex)
    {
        return;
    }
    [self.pageControl setCurrentPage:newCarouselPageViewIndex];
    
    [_carouselPagesContainerView setCurrentPage:newCarouselPageViewIndex];
    _carouselPageViewIndex = newCarouselPageViewIndex;
}

- (void)handleRightSwipe
{
    NSInteger newCarouselPageViewIndex = MAX(self.carouselPageViewIndex-1, 0);
    
    if(newCarouselPageViewIndex == self.carouselPageViewIndex)
    {
        return;
    }
    
    [self.pageControl setCurrentPage:newCarouselPageViewIndex];
    [self.carouselPagesContainerView setCurrentPage:newCarouselPageViewIndex];
    _carouselPageViewIndex = newCarouselPageViewIndex;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    // Get the translation and velocity of the pan gesture
    CGPoint translation = [gesture translationInView:self];
    
    // Calculate distance based on translation
    CGFloat distance = fabs(translation.x);

    // Thresholds
    CGFloat minimumSwipeDistance = 60.0;
    
    // Check the state of the gesture recognizer
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        
        if(distance > minimumSwipeDistance)
        {
            if(translation.x > 0 )
            {
                [self handleRightSwipe];
            } else
            {
                [self handleLeftSwipe];
            }
        }
    }
}

@end
