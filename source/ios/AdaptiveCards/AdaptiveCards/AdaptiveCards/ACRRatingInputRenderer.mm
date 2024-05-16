//
//  ACRRatingInputRenderer.m
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
#import "ACRNumericTextField.h"
#import "ACRTextInputHandler.h"
#import "ACRRatingInputRenderer.h"
#import "UtiliOS.h"
#import "RatingInput.h"

@implementation ACRRatingInputRenderer

+ (ACRRatingInputRenderer *)getInstance
{
    static ACRRatingInputRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRRatingInput;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<RatingInput> ratingInput = std::dynamic_pointer_cast<RatingInput>(elem);
    return [[UIView alloc] init];
}

@end
