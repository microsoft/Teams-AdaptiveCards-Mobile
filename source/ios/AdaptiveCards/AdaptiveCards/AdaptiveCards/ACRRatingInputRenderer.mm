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
#import "SwiftAdaptiveCardObjcBridge.h"
#import "ACRRatingView.h"
#import "ACRRatingInputDataSource.h"

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
         hostConfig:(ACOHostConfig *)acoConfig
{
    // Check if we should use Swift for rendering
    BOOL useSwiftRendering = [SwiftAdaptiveCardObjcBridge useSwiftForRendering];

    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<RatingInput> ratingInput = std::dynamic_pointer_cast<RatingInput>(elem);

    // Get properties - use bridge for Swift, C++ for legacy
    double value;
    NSInteger maxValue;
    ACRRatingSize ratingSize;
    ACRRatingColor ratingColor;
    ACRHorizontalAlignment acrHorizontalAlignment;

    if (useSwiftRendering) {
        value = [SwiftAdaptiveCardObjcBridge getRatingInputValue:acoElem useSwift:YES];
        double max = [SwiftAdaptiveCardObjcBridge getRatingInputMax:acoElem useSwift:YES];
        maxValue = max > 5 ? 5 : (NSInteger)max;

        // Convert size index to ACRRatingSize (0=medium, 1=large)
        NSInteger sizeIndex = [SwiftAdaptiveCardObjcBridge getRatingInputSize:acoElem useSwift:YES];
        ratingSize = (sizeIndex == 1) ? ACRLarge : ACRMedium;

        // Convert color index to ACRRatingColor (0=neutral, 1=marigold)
        NSInteger colorIndex = [SwiftAdaptiveCardObjcBridge getRatingInputColor:acoElem useSwift:YES];
        ratingColor = (colorIndex == 1) ? ACRMarigold : ACRNeutral;

        // Convert horizontal alignment index (0=left, 1=center, 2=right)
        NSInteger alignmentIndex = [SwiftAdaptiveCardObjcBridge getRatingInputHorizontalAlignment:acoElem useSwift:YES];
        // Note: Default for RatingInput is Right (2)
        if (alignmentIndex == 0) {
            acrHorizontalAlignment = ACRLeft;
        } else if (alignmentIndex == 1) {
            acrHorizontalAlignment = ACRCenter;
        } else {
            acrHorizontalAlignment = ACRRight;
        }
    } else {
        value = ratingInput->GetValue();
        maxValue = ratingInput->GetMax() > 5 ? 5 : ratingInput->GetMax();
        ratingSize = getRatingSize(ratingInput->GetRatingSize());
        ratingColor = getRatingColor(ratingInput->GetRatingColor());
        acrHorizontalAlignment = getACRHorizontalAlignment(ratingInput->GetHorizontalAlignment().value_or(HorizontalAlignment::Right));
    }

    ACRRatingView *ratingView = [[ACRRatingView alloc] initWithEditableValue:value max:maxValue size:ratingSize ratingColor:ratingColor hostConfig:acoConfig];

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

    ACRRatingInputDataSource *ratingInputDataSource = [[ACRRatingInputDataSource alloc] initWithInputRating:ratingInput WithHostConfig:config];
    ratingInputDataSource.ratingView = ratingView;

    ACRInputLabelView *inputLabelView = [[ACRInputLabelView alloc] initInputLabelView:rootView acoConfig:acoConfig adaptiveInputElement:ratingInput inputView:wrapperView accessibilityItem:ratingView viewGroup:viewGroup dataSource:ratingInputDataSource];

    [inputs addObject:inputLabelView];

    [inputLabelView addAccessibleItems:[ratingView accessibleChildren]];

    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:inputLabelView withAreaName:areaName];

    return inputLabelView;
}

@end
