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
#import "ACRRatingInputView.h"

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
        
    ACRRatingInputView *ratingView = [[ACRRatingInputView alloc] init:ratingInput->GetValue() max:ratingInput->GetMax() size:getRatingSize(ratingInput->GetRatingSize()) ratingColor:getRatingColor(ratingInput->GetRatingColor()) readOnly:NO];
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    ratingView.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapperView addSubview:ratingView];
    
    [NSLayoutConstraint activateConstraints:@[
        [wrapperView.topAnchor constraintEqualToAnchor:ratingView.topAnchor],
        [wrapperView.bottomAnchor constraintEqualToAnchor:ratingView.bottomAnchor]
    ]];
        
    ACRHorizontalAlignment acrHorizontalAlignment = getACRHorizontalAlignment(ratingInput->GetHorizontalAlignment().value_or(HorizontalAlignment::Right));
    
    switch (acrHorizontalAlignment) {
        case ACRCenter:
            [NSLayoutConstraint activateConstraints:@[
                [wrapperView.centerXAnchor constraintEqualToAnchor:ratingView.centerXAnchor]
            ]];
            break;
        case ACRRight:
            [NSLayoutConstraint activateConstraints:@[
                [wrapperView.trailingAnchor constraintEqualToAnchor:ratingView.trailingAnchor]
            ]];
            break;
        case ACRLeft:
            [NSLayoutConstraint activateConstraints:@[
                [wrapperView.leadingAnchor constraintEqualToAnchor:ratingView.leadingAnchor]
            ]];
    }
    
    [viewGroup addArrangedSubview:wrapperView];
  
    return wrapperView;
}

@end
