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
    NSMutableArray<UIView *> *carouselPages = [[NSMutableArray alloc] init];
    
    for( auto carouselPage : carousel->GetItems()) {
        UIView *carouselPageView = [[CarouselPageView alloc] renderWithCarouselPage:carouselPage
                                                                          viewGroup:viewGroup
                                                                           rootView:rootView
                                                                             inputs:inputs
                                                                    baseCardElement:acoElem
                                                                         hostConfig:acoConfig];
        [carouselPages addObject:carouselPageView];
    }
    
    CarouselViewBottomBar *carouselViewBottomBar = [[CarouselViewBottomBar alloc] initWithViews:carouselPages];
    
    CarouselView * carouselView = [[CarouselView alloc] initWithCarouselViewBottomBar:carouselViewBottomBar];
    
    NSString *areaName = stringForCString(elem->GetAreaGridName());
    
    [viewGroup addArrangedSubview:carouselView withAreaName:areaName];
    
    [NSLayoutConstraint activateConstraints:@[
        [carouselView.leadingAnchor constraintEqualToAnchor:viewGroup.leadingAnchor],
        [carouselView.trailingAnchor constraintEqualToAnchor:viewGroup.trailingAnchor]
    ]];
    
    carouselView.translatesAutoresizingMaskIntoConstraints = NO;
    carouselView.clipsToBounds = YES;
    return carouselView;
}

@end
