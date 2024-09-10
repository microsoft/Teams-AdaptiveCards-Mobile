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
    std::shared_ptr<Carousel> compoundButton = std::dynamic_pointer_cast<Carousel>(elem);
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

@end
