//
//  ACRRatingLabelRenderer.m
//  AdaptiveCards
//
//  Created by Abhishek on 14/05/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRInputNumberRenderer.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACOBundle.h"
#import "ACOHostConfigPrivate.h"
#import "ACRContentHoldingUIView.h"
#import "ACRInputLabelViewPrivate.h"
#import "ACRRatingLabelRenderer.h"
#import "UtiliOS.h"
#import "RatingLabel.h"

@implementation ACRRatingLabelRenderer

+ (ACRRatingLabelRenderer *)getInstance
{
    static ACRRatingLabelRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRRatingLabel;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<RatingLabel> ratingInput = std::dynamic_pointer_cast<RatingLabel>(elem);
    return [[UIView alloc] init];
}

@end
