//
//  ACRCompoundButtonRenderer.m
//  AdaptiveCards
//
//  Created by Abhishek on 24/04/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRIconRenderer.h"
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

@implementation ACRCompoundButtonRenderer

+ (ACRCompoundButtonRenderer *)getInstance
{
    static ACRCompoundButtonRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRCompoundButton;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<CompoundButton> compoundButton = std::dynamic_pointer_cast<CompoundButton>(elem);
    std::shared_ptr<IconInfo> icon = compoundButton->getIcon();
    NSString *svgPayloadURL = @(icon->GetSVGResourceURL().c_str());
    UIColor *imageTintColor = [acoConfig getTextBlockColor:(ACRContainerStyle::ACRDefault) textColor:icon->getForgroundColor() subtleOption:false];
    CGSize size = CGSizeMake(icon->getSize(), icon->getSize());
    
    ACRSVGImageView *iconView = [[ACRSVGImageView alloc] init:svgPayloadURL
                                                          rtl:rootView.context.rtl
                                                         size:size
                                                    tintColor:imageTintColor];
    ACRSVGIconHoldingView *wrappingView = [[ACRSVGIconHoldingView alloc] init:iconView size:size];

    wrappingView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [viewGroup addArrangedSubview:wrappingView];
    
    configRtl(iconView, rootView.context);
    configRtl(wrappingView, rootView.context);
    return iconView;
}

@end
