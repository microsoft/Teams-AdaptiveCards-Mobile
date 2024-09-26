//
//  ACRCarouselPageContainerView.h
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

@implementation ACRCarouselPageContainerView

-(instancetype) initWithCarouselPageViewList:(NSMutableArray<UIView *> *)carouselPageViewList
{
    self = [super init];
    for(UIView *carouselPageView in carouselPageViewList) {
        carouselPageView.translatesAutoresizingMaskIntoConstraints = NO;
        carouselPageView.clipsToBounds = YES;
        carouselPageView.hidden = YES;
        [self addSubview:carouselPageView];
        [NSLayoutConstraint activateConstraints:@[
            [carouselPageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [carouselPageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [carouselPageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [carouselPageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [self.heightAnchor constraintGreaterThanOrEqualToAnchor:carouselPageView.heightAnchor]
        ]];
    }
    
    return self;
}

@end
