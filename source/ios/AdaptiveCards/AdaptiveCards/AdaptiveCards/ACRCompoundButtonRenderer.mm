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
#import "ACRUILabel.h"
#import "UtiliOS.h"

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
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<CompoundButton> compoundButton = std::dynamic_pointer_cast<CompoundButton>(elem);
    std::shared_ptr<IconInfo> icon = compoundButton->getIcon();
   
    
    
    UIStackView *verticalStack = [[UIStackView alloc] initWithFrame:CGRectZero];
    verticalStack.axis = UILayoutConstraintAxisVertical;
    verticalStack.translatesAutoresizingMaskIntoConstraints = NO;
    verticalStack.alignment = UIStackViewAlignmentLeading;
    verticalStack.spacing = 5;
    
    UIStackView *horizontalStack = [[UIStackView alloc] initWithFrame:CGRectZero];
    horizontalStack.translatesAutoresizingMaskIntoConstraints = NO;
    horizontalStack.spacing = 5;
    horizontalStack.alignment = UIStackViewAlignmentCenter;
    
    if(icon != nil){
        ACRSVGIconHoldingView* iconView = [self getIconViewWithIconInfo:icon
                                                               rootView:rootView
                                                             hostConfig:acoConfig];
        [horizontalStack addArrangedSubview:iconView];
    }
   
    
    UILabel *titleLabel = [self getTitleLabelWithText:compoundButton->getTitle() viewGroup:viewGroup hostConfig:acoConfig];
    
    UILabel* descriptionLabel = [self getDescriptionLabelWithText:compoundButton->getDescription()
                                                           viewGroup:viewGroup
                                                          hostConfig:acoConfig];
    
    ACRUILabel *badgeLabel = [self getBadgeLabelWithText:compoundButton->getBadge()
                                               viewGroup:viewGroup
                                              hostConfig:acoConfig];
    
    [horizontalStack addArrangedSubview:titleLabel];
    
    if(! isNullOrEmpty(badgeLabel.text))
    {
        [horizontalStack addArrangedSubview:badgeLabel];
    }
    
    [verticalStack addArrangedSubview:horizontalStack];
    [verticalStack addArrangedSubview:descriptionLabel];
    
    configRtl(verticalStack, rootView.context);
    
    std::shared_ptr<BaseActionElement> selectAction = compoundButton->GetSelectAction();
    ACOBaseActionElement *acoSelectAction = [ACOBaseActionElement getACOActionElementFromAdaptiveElement:selectAction];
    addSelectActionToView(acoConfig, acoSelectAction, rootView, verticalStack, viewGroup);
    [viewGroup addArrangedSubview:verticalStack];
    
    verticalStack.accessibilityLabel = @(compoundButton->getTitle().c_str());
    
    return verticalStack;
}

-(UILabel*) getTitleLabelWithText:(std::string) title
                             viewGroup:(UIView<ACRIContentHoldingView> *)viewGroup
                            hostConfig:(ACOHostConfig *)acoConfig
{
    UILabel * titleLabel = [[UILabel alloc] init];
    titleLabel.textColor =  [acoConfig getTextBlockColor:[viewGroup style] textColor:ForegroundColor::Default subtleOption:NO];
    titleLabel.text = @(title.c_str());
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    return titleLabel;
}

-(ACRSVGIconHoldingView*) getIconViewWithIconInfo:(std::shared_ptr<IconInfo>) icon
                                      rootView:(ACRView *)rootView
                                    hostConfig:(ACOHostConfig *)acoConfig;
{
    NSString *svgPayloadURL = @(icon->GetSVGResourceURL().c_str());
    UIColor *imageTintColor = [acoConfig getTextBlockColor:(ACRContainerStyle::ACRDefault) textColor:icon->getForgroundColor() subtleOption:false];
    CGSize size = CGSizeMake(icon->getSize(), icon->getSize());
    
    ACRSVGImageView *iconView = [[ACRSVGImageView alloc] init:svgPayloadURL
                                                          rtl:rootView.context.rtl
                                                         size:size
                                                    tintColor:imageTintColor];
    ACRSVGIconHoldingView *iconViewWraper = [[ACRSVGIconHoldingView alloc] init:iconView size:size];
    iconViewWraper.translatesAutoresizingMaskIntoConstraints = NO;
    return iconViewWraper;
}

-(UILabel*) getDescriptionLabelWithText:(std::string) description
                             viewGroup:(UIView<ACRIContentHoldingView> *)viewGroup
                            hostConfig:(ACOHostConfig *)acoConfig
{
    UILabel * descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.textColor =  [acoConfig getTextBlockColor:[viewGroup style] textColor:ForegroundColor::Default subtleOption:NO];
    descriptionLabel.text = @(description.c_str());
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descriptionLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return descriptionLabel;
}

-(ACRUILabel*) getBadgeLabelWithText:(std::string) badge
                             viewGroup:(UIView<ACRIContentHoldingView> *)viewGroup
                            hostConfig:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    ACRUILabel * badgeLabel = [[ACRUILabel alloc] init];
    badgeLabel.textColor =  [acoConfig getTextBlockColor:[viewGroup style] textColor:ForegroundColor::Default subtleOption:NO];
    badgeLabel.text = @(badge.c_str());
    badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    badgeLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    std::string badgeBackgroundColor = config->GetCompoundButtonConfig().badgeConfig.backgroundColor;
    badgeLabel.backgroundColor = [ACOHostConfig convertHexColorCodeToUIColor:badgeBackgroundColor];
    badgeLabel.layer.cornerRadius = 12;
    badgeLabel.clipsToBounds = YES;
    badgeLabel.textAlignment = NSTextAlignmentCenter;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(2.4, 7.2, 2.4, 7.2);
    badgeLabel.textContainerInset = insets;
    return badgeLabel;
}

@end
