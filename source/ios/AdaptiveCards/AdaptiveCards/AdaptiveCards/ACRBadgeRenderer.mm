//
//  ACRBadgeRenderer.m
//  AdaptiveCards
//
//  Created by reenulnu on 08/10/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACOBaseCardElementPrivate.h"
#import "ACOBundle.h"
#import "ACOHostConfigPrivate.h"
#import "ACRInputLabelViewPrivate.h"
#import "ACRBadgeRenderer.h"
#import "UtiliOS.h"
#import "Badge.h"
#import "Icon.h"
#import "ACRSVGImageView.h"
#import "ACRSVGIconHoldingView.h"
#include "IconInfo.h"
#import "ACRBadgeView.h"

@implementation ACRBadgeRenderer 

+ (ACRBadgeRenderer *)getInstance
{
    static ACRBadgeRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRBadge;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Badge> badge = std::dynamic_pointer_cast<Badge>(elem);
    std::shared_ptr<IconInfo> icon = std::make_shared<IconInfo>();
    icon->SetName(badge->GetBadgeIcon());
    icon->setIconSize(AdaptiveCards::IconSize::Large);
    icon->setIconStyle(AdaptiveCards::IconStyle::Filled);
    icon->setForgroundColor(AdaptiveCards::ForegroundColor::Good);

    
    NSString *svgPayloadURL = cdnURLForIcon(@(icon->GetSVGPath().c_str()));
    CGSize size = CGSizeMake(getIconSize(IconSize::Standard), getIconSize(IconSize::Standard));
    
    UIColor *imageTintColor = [acoConfig getTextBlockColor:(ACRContainerStyle::ACRDefault) textColor:icon->getForgroundColor() subtleOption:false];
    BOOL isFilled = (badge->GetBadgeAppearance() == BadgeAppearance::Filled);
    ACRSVGImageView *iconView = [[ACRSVGImageView alloc] init:svgPayloadURL
                                                          rtl:rootView.context.rtl
                                                     isFilled:isFilled
                                                         size:size
                                                    tintColor:imageTintColor];
    
    ACRSVGIconHoldingView *imageView = [[ACRSVGIconHoldingView alloc] init:iconView size:size];
    
    ACRBadgeView *badgeView = [[ACRBadgeView alloc] initWithText:[NSString stringWithCString:badge->GetText().c_str() encoding:NSUTF8StringEncoding]
                                                            image:imageView
                                                            appearance:getBadgeAppearance(badge->GetBadgeAppearance())
                                                            iconPosition:getIconPosition(badge->GetIconPosition())
                                                            size:getBadgeSize(badge->GetBadgeSize())
                                                            shape:getShape(badge->GetShape())
                                                            style:getBadgeStyle(badge->GetBadgeStyle())
                                                      hostConfig:acoConfig];

    
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectZero];
    wrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    badgeView.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapperView addSubview:badgeView];
    
    [NSLayoutConstraint activateConstraints:@[
        [wrapperView.topAnchor constraintEqualToAnchor:badgeView.topAnchor],
        [wrapperView.bottomAnchor constraintEqualToAnchor:badgeView.bottomAnchor]
    ]];
    
    ACRHorizontalAlignment acrHorizontalAlignment = getACRHorizontalAlignment(badge->GetHorizontalAlignment().value_or(HorizontalAlignment::Right));
    
    switch (acrHorizontalAlignment)
    {
        case ACRCenter:
            [NSLayoutConstraint activateConstraints:@[
                [wrapperView.centerXAnchor constraintEqualToAnchor:badgeView.centerXAnchor]
            ]];
            break;
        case ACRRight:
            [NSLayoutConstraint activateConstraints:@[
                [wrapperView.trailingAnchor constraintEqualToAnchor:badgeView.trailingAnchor]
            ]];
            break;
        case ACRLeft:
            [NSLayoutConstraint activateConstraints:@[
                [wrapperView.leadingAnchor constraintEqualToAnchor:badgeView.leadingAnchor]
            ]];
    }
    
    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:wrapperView withAreaName:areaName];
  
    return wrapperView;
}

@end
