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
#import "SwiftAdaptiveCardObjcBridge.h"
#import "ACRRatingView.h"

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
         hostConfig:(ACOHostConfig *)acoConfig
{
    // Check if we should use Swift for rendering
    BOOL useSwiftRendering = [SwiftAdaptiveCardObjcBridge useSwiftForRendering];

    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<RatingLabel> ratingLabel = std::dynamic_pointer_cast<RatingLabel>(elem);

    // Get properties - use bridge for Swift, C++ for legacy
    double value;
    NSInteger maxValue;
    ACRRatingSize ratingSize;
    ACRRatingColor ratingColor;
    ACRRatingStyle ratingStyle;
    NSInteger count;
    ACRHorizontalAlignment acrHorizontalAlignment;

    if (useSwiftRendering) {
        value = [SwiftAdaptiveCardObjcBridge getRatingLabelValue:acoElem useSwift:YES];
        double max = [SwiftAdaptiveCardObjcBridge getRatingLabelMax:acoElem useSwift:YES];
        maxValue = max > 5 ? 5 : (NSInteger)max;

        // Convert size index to ACRRatingSize (0=medium, 1=large)
        NSInteger sizeIndex = [SwiftAdaptiveCardObjcBridge getRatingLabelSize:acoElem useSwift:YES];
        ratingSize = (sizeIndex == 1) ? ACRLarge : ACRMedium;

        // Convert color index to ACRRatingColor (0=neutral, 1=marigold)
        NSInteger colorIndex = [SwiftAdaptiveCardObjcBridge getRatingLabelColor:acoElem useSwift:YES];
        ratingColor = (colorIndex == 1) ? ACRMarigold : ACRNeutral;

        // Convert style index to ACRRatingStyle (0=default, 1=compact)
        NSInteger styleIndex = [SwiftAdaptiveCardObjcBridge getRatingLabelStyle:acoElem useSwift:YES];
        ratingStyle = (styleIndex == 1) ? ACRCompactStyle : ACRDefaultStyle;

        // Get count (nullable)
        NSNumber *countNumber = [SwiftAdaptiveCardObjcBridge getRatingLabelCount:acoElem useSwift:YES];
        count = countNumber ? [countNumber integerValue] : 0;

        // Convert horizontal alignment index (0=left, 1=center, 2=right)
        NSInteger alignmentIndex = [SwiftAdaptiveCardObjcBridge getRatingLabelHorizontalAlignment:acoElem useSwift:YES];
        // Note: Default for RatingLabel is Right (2)
        if (alignmentIndex == 0) {
            acrHorizontalAlignment = ACRLeft;
        } else if (alignmentIndex == 1) {
            acrHorizontalAlignment = ACRCenter;
        } else {
            acrHorizontalAlignment = ACRRight;
        }
    } else {
        value = ratingLabel->GetValue();
        maxValue = ratingLabel->GetMax() > 5 ? 5 : ratingLabel->GetMax();
        ratingSize = getRatingSize(ratingLabel->GetRatingSize());
        ratingColor = getRatingColor(ratingLabel->GetRatingColor());
        ratingStyle = getRatingStyle(ratingLabel->GetRatingStyle());
        count = ratingLabel->GetCount().value_or(0);
        acrHorizontalAlignment = getACRHorizontalAlignment(ratingLabel->GetHorizontalAlignment().value_or(HorizontalAlignment::Right));
    }

    ACRRatingView *ratingView = [[ACRRatingView alloc] initWithReadonlyValue:value
                                                                         max:maxValue
                                                                        size:ratingSize
                                                                 ratingColor:ratingColor
                                                                       style:ratingStyle
                                                                       count:count
                                                                  hostConfig:acoConfig];

    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    ratingView.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapperView addSubview:ratingView];

    [NSLayoutConstraint activateConstraints:@[
        [wrapperView.topAnchor constraintEqualToAnchor:ratingView.topAnchor],
        [wrapperView.bottomAnchor constraintEqualToAnchor:ratingView.bottomAnchor]
    ]];

    switch (acrHorizontalAlignment)
    {
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

    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:wrapperView withAreaName:areaName];

    return wrapperView;
}

@end
