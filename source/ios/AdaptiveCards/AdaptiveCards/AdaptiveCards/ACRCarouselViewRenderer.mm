//
//  ACRCarouselViewRenderer.mm
//  AdaptiveCards
//
//  Copyright © 2024 Microsoft. All rights reserved.
//


#import "ACRCarouselViewRenderer.h"
#import "ACRCarouselView.h"
#import "SwiftAdaptiveCardObjcBridge.h"

@implementation ACRCarouselViewRenderer


+ (ACRCarouselViewRenderer *)getInstance
{
    static ACRCarouselViewRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRCarousel;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig
{
    // Check if we should use Swift for rendering
    BOOL useSwiftRendering = [SwiftAdaptiveCardObjcBridge useSwiftForRendering];
    NSArray *swiftCarouselPages = nil;
    NSArray *swiftCarouselPageItems = nil;
    if (useSwiftRendering) {
        swiftCarouselPages = [SwiftAdaptiveCardObjcBridge getCarouselPages:acoElem useSwift:YES];
        swiftCarouselPageItems = [SwiftAdaptiveCardObjcBridge getCarouselPageItems:acoElem useSwift:YES];
    }

    return [[ACRCarouselView alloc] initWithViewGroup:viewGroup
                                             rootView:rootView
                                               inputs:inputs
                                      baseCardElement:acoElem
                                           hostConfig:acoConfig];
}

@end
