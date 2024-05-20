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
#import "ACRRatingInputView.h"

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
    std::shared_ptr<RatingLabel> ratingLabel = std::dynamic_pointer_cast<RatingLabel>(elem);
    
    ACRRatingInputView *ratingView = [[ACRRatingInputView alloc] init:ratingLabel->GetValue() max:ratingLabel->GetMax() size:getRatingSize(ratingLabel->GetRatingSize()) ratingColor:getRatingColor(ratingLabel->GetRatingColor()) readOnly:YES];
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    ratingView.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapperView addSubview:ratingView];
    
    [NSLayoutConstraint activateConstraints:@[
        [wrapperView.topAnchor constraintEqualToAnchor:ratingView.topAnchor],
        [wrapperView.bottomAnchor constraintEqualToAnchor:ratingView.bottomAnchor]
    ]];
        
    ACRHorizontalAlignment acrHorizontalAlignment = getACRHorizontalAlignment(ratingLabel->GetHorizontalAlignment().value_or(HorizontalAlignment::Right));
    
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
