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
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<Icon> icon = std::dynamic_pointer_cast<Icon>(elem);
    
    NSString *svgPayloadURL = cdnURLForIcon(@(icon->GetSVGPath().c_str()));
    CGSize size = CGSizeMake(getIconSize(icon->getIconSize()), getIconSize(icon->getIconSize()));
    
    UIColor *imageTintColor = [acoConfig getTextBlockColor:(ACRContainerStyle::ACRDefault) textColor:icon->getForgroundColor() subtleOption:false];
    BOOL isFilled = (icon->getIconStyle() == IconStyle::Filled);
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

    // An interactive icon (one with a selectAction) must be reachable and named for
    // VoiceOver. Without this the icon is not an accessibility element, so screen
    // reader users cannot find or activate it. Decorative icons (no selectAction) are
    // intentionally left non-accessible.
    //
    // Use the first meaningful name: the action's title, then its tooltip, then the
    // icon name. Deliberately not configureForAccessibilityLabel(), which *joins* title
    // and tooltip with ", " and so yields a leading ", " when the action has no title -
    // a string identical to the one already carried by the action's own button, which
    // would make this icon a duplicate element with the same announced name.
    if (acoSelectAction) {
        NSString *iconAccessibilityLabel = acoSelectAction.title.length ? acoSelectAction.title : nil;
        if (!iconAccessibilityLabel.length) {
            iconAccessibilityLabel = acoSelectAction.tooltip.length ? acoSelectAction.tooltip : nil;
        }
        if (!iconAccessibilityLabel.length) {
            iconAccessibilityLabel = [NSString stringWithCString:icon->GetName().c_str() encoding:NSUTF8StringEncoding];
        }
        if (iconAccessibilityLabel.length) {
            wrappingView.isAccessibilityElement = YES;
            wrappingView.accessibilityLabel = iconAccessibilityLabel;
            // OR the trait in so traits already applied by setAccessibilityTrait()
            // (for example UIAccessibilityTraitNotEnabled) are preserved.
            wrappingView.accessibilityTraits |= UIAccessibilityTraitButton;
        }
    }
    
    // Configure visibility for the wrapping view so toggle visibility actions work correctly
    configVisibility(wrappingView, elem);
    
    return iconView;
}

@end
