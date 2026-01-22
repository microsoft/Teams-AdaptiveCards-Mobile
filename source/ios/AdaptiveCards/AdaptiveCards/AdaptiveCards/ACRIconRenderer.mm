//
//  ACRIconRenderer.m
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
#import "SwiftAdaptiveCardObjcBridge.h"

@implementation ACRIconRenderer

+ (ACRIconRenderer *)getInstance
{
    static ACRIconRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRIcon;
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
    std::shared_ptr<Icon> icon = std::dynamic_pointer_cast<Icon>(elem);

    // Get properties - use bridge for Swift, C++ for legacy
    NSString *svgPayloadURL;
    CGFloat iconSizeValue;
    UIColor *imageTintColor;
    BOOL isFilled;

    if (useSwiftRendering) {
        // Get icon name and build SVG path
        NSString *iconName = [SwiftAdaptiveCardObjcBridge getIconName:acoElem useSwift:YES];
        if (iconName.length > 0) {
            NSString *svgPath = [NSString stringWithFormat:@"%@/%@.json", iconName, iconName];
            svgPayloadURL = cdnURLForIcon(svgPath);
        } else {
            svgPayloadURL = @"";
        }

        // Convert size index to actual size value
        // 0=xxSmall, 1=xSmall, 2=small, 3=standard, 4=medium, 5=large, 6=xLarge, 7=xxLarge
        NSInteger sizeIndex = [SwiftAdaptiveCardObjcBridge getIconSize:acoElem useSwift:YES];
        IconSize iconSize;
        switch (sizeIndex) {
            case 0: iconSize = IconSize::xxSmall; break;
            case 1: iconSize = IconSize::xSmall; break;
            case 2: iconSize = IconSize::Small; break;
            case 3: iconSize = IconSize::Standard; break;
            case 4: iconSize = IconSize::Medium; break;
            case 5: iconSize = IconSize::Large; break;
            case 6: iconSize = IconSize::xLarge; break;
            case 7: iconSize = IconSize::xxLarge; break;
            default: iconSize = IconSize::Standard; break;
        }
        iconSizeValue = getIconSize(iconSize);

        // Convert foreground color index to ForegroundColor enum
        // 0=default, 1=dark, 2=light, 3=accent, 4=good, 5=warning, 6=attention
        NSInteger colorIndex = [SwiftAdaptiveCardObjcBridge getIconForegroundColor:acoElem useSwift:YES];
        ForegroundColor foregroundColor;
        switch (colorIndex) {
            case 0: foregroundColor = ForegroundColor::Default; break;
            case 1: foregroundColor = ForegroundColor::Dark; break;
            case 2: foregroundColor = ForegroundColor::Light; break;
            case 3: foregroundColor = ForegroundColor::Accent; break;
            case 4: foregroundColor = ForegroundColor::Good; break;
            case 5: foregroundColor = ForegroundColor::Warning; break;
            case 6: foregroundColor = ForegroundColor::Attention; break;
            default: foregroundColor = ForegroundColor::Default; break;
        }
        imageTintColor = [acoConfig getTextBlockColor:(ACRContainerStyle::ACRDefault) textColor:foregroundColor subtleOption:false];

        // Convert style index (0=regular, 1=filled)
        NSInteger styleIndex = [SwiftAdaptiveCardObjcBridge getIconStyle:acoElem useSwift:YES];
        isFilled = (styleIndex == 1);
    } else {
        svgPayloadURL = cdnURLForIcon(@(icon->GetSVGPath().c_str()));
        iconSizeValue = getIconSize(icon->getIconSize());
        imageTintColor = [acoConfig getTextBlockColor:(ACRContainerStyle::ACRDefault) textColor:icon->getForgroundColor() subtleOption:false];
        isFilled = (icon->getIconStyle() == IconStyle::Filled);
    }

    CGSize size = CGSizeMake(iconSizeValue, iconSizeValue);

    ACRSVGImageView *iconView = [[ACRSVGImageView alloc] init:svgPayloadURL
                                                          rtl:rootView.context.rtl
                                                     isFilled:isFilled
                                                         size:size
                                                    tintColor:imageTintColor];

    ACRSVGIconHoldingView *wrappingView = [[ACRSVGIconHoldingView alloc] init:iconView size:size];

    wrappingView.translatesAutoresizingMaskIntoConstraints = NO;

    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:wrappingView withAreaName:areaName];

    configRtl(iconView, rootView.context);
    configRtl(wrappingView, rootView.context);

    std::shared_ptr<BaseActionElement> selectAction = icon->GetSelectAction();
    ACOBaseActionElement *acoSelectAction = [ACOBaseActionElement getACOActionElementFromAdaptiveElement:selectAction];
    addSelectActionToView(acoConfig, acoSelectAction, rootView, wrappingView, viewGroup);

    // Configure visibility for the wrapping view so toggle visibility actions work correctly
    configVisibility(wrappingView, elem);

    return iconView;
}

@end
