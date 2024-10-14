//
//  ACRBadgeView.m
//  AdaptiveCards
//
//  Created by reenulnu on 09/10/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRBadgeView.h"
#import "ACOBundle.h"
#import "ACOHostConfigPrivate.h"
#include "IconInfo.h"
#import "Icon.h"
#import "ACRSVGImageView.h"
#import "ACRSVGIconHoldingView.h"

@implementation ACRBadgeView
{
    NSString *_text;
    NSString *_iconUrl;
    BOOL _isFilled;
    ACRBadgeAppearance _appearance;
    ACRIconPosition _iconPosition;
    ACRBadgeSize _size;
    ACRShape _shape;
    ACRBadgeStyle _style;
    ACOHostConfig *_hostConfig;
    UIView *_iconImageView;
    UILabel *_textLabel;
    ACRView *_rootView;
}


- (instancetype)initWithRootView:(ACRView *)rootView
                            text:(NSString*)text
                        iconUrl:(NSString*)iconUrl
                        isFilled:(BOOL)isFilled
                    appearance:(ACRBadgeAppearance)appearance
                    iconPosition:(ACRIconPosition)iconPosition
                            size:(ACRBadgeSize)size
                           shape:(ACRShape)shape
                            style:(ACRBadgeStyle)style
                        hostConfig:(ACOHostConfig *)hostConfig
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        _text = text;
        _iconUrl = iconUrl;
        _isFilled = isFilled;
        _rootView = rootView;
        _appearance = appearance;
        _iconPosition = iconPosition;
        _size = size;
        _shape = shape;
        _style = style;
        _hostConfig = hostConfig;
        [self setupBadgeView];
    }
    return self;
}

- (void)setupBadgeView {
    
    BadgeAppearanceDefinition definition = [self getBadgeAppearanceDefinition];
    self.backgroundColor = [ACOHostConfig convertHexColorCodeToUIColor: definition.backgroundColor.c_str()];
    self.layer.borderColor  =  [ACOHostConfig convertHexColorCodeToUIColor: definition.strokeColor.c_str()].CGColor;
    self.layer.borderWidth = 2;
    if(_iconUrl != nil)
    {
        [self addIconView:definition];
    }
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.text = _text;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _textLabel.textColor = [ACOHostConfig convertHexColorCodeToUIColor: definition.textColor.c_str()];
    [self addSubview:_textLabel];
    [self setCornerRadius];
    [self setupConstraints];
    
}

-(void)setCornerRadius
{
    switch (_shape) {
        case ACRSquare:
            self.layer.cornerRadius = 0;
            break;
        case ACRRounded:
            self.layer.cornerRadius = 4;
            break;
        case ACRCircular:
            self.layer.cornerRadius = 15;
            break;
        default:
            self.layer.cornerRadius = 0;
    }
}

-(void)addIconView:(BadgeAppearanceDefinition) definition
{
    CGSize size = CGSizeMake(16.0,16.0);
    UIColor *imageTintColor = [ACOHostConfig convertHexColorCodeToUIColor: definition.textColor.c_str()];
    ACRSVGImageView *iconView = [[ACRSVGImageView alloc] init:_iconUrl
                                                          rtl:_rootView.context.rtl
                                                     isFilled:_isFilled
                                                         size:size
                                                    tintColor:imageTintColor];
    
    ACRSVGIconHoldingView *imageView = [[ACRSVGIconHoldingView alloc] init:iconView size:size];
    _iconImageView = imageView;
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_iconImageView];
}

- (void)setupConstraints
{
    [NSLayoutConstraint activateConstraints:@[
        [_textLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:2],
        [_textLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-2],
    ]];
    
    if(_iconImageView == nil)
    {
        [NSLayoutConstraint activateConstraints:@[
            [_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10]
        ]];
    }
    else if(_iconPosition == ACRBeforePosition)
    {
        [NSLayoutConstraint activateConstraints:@[
            [_iconImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [_textLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:10],
            [_textLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
            [_iconImageView.centerYAnchor constraintEqualToAnchor:_textLabel.centerYAnchor],
            [_iconImageView.widthAnchor constraintEqualToConstant:16],
            [_iconImageView.heightAnchor constraintEqualToConstant:16],
        ]];
    } else
    {
        [NSLayoutConstraint activateConstraints:@[
            [_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
            [_iconImageView.leadingAnchor constraintEqualToAnchor:_textLabel.trailingAnchor constant:10],
            [_iconImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
            [_iconImageView.centerYAnchor constraintEqualToAnchor:_textLabel.centerYAnchor],
            [_iconImageView.widthAnchor constraintEqualToConstant:40],
            [_iconImageView.heightAnchor constraintEqualToConstant:40]
        ]];
    }
}

- (BadgeAppearanceDefinition )getBadgeAppearanceDefinition
{
    BadgeStylesDefinition badgeStyles = [_hostConfig getHostConfig]->GetBadgeStyles();
    BadgeStyleDefinition badgeStyle;
    BadgeAppearanceDefinition definition;
    
    switch (_style) {
        case ACRBadgeDefaultStyle:
            badgeStyle =  badgeStyles.defaultPalette;
            break;
        case ACRBadgeAccentStyle:
            badgeStyle =  badgeStyles.accentPalette;
            break;
        case ACRBadgeAttentionStyle:
            badgeStyle =  badgeStyles.attentionPalette;
            break;
        case ACRBadgeGoodStyle:
            badgeStyle =  badgeStyles.goodPalette;
            break;
        case ACRBadgeInformativeStyle:
            badgeStyle =  badgeStyles.informativePalette;
            break;
        case ACRBadgeSubtleStyle:
            badgeStyle =  badgeStyles.subtlePalette;
            break;
        case ACRBadgeWarningStyle:
            badgeStyle = badgeStyles.warningPalette;
            break;
        default:
            badgeStyle =  badgeStyles.defaultPalette;
    }
    switch (_appearance) {
        case ACRFilled:
            definition = badgeStyle.filledStyle;
            break;
        case ACRTint:
            definition = badgeStyle.tintStyle;
            break;
        default:
            definition = badgeStyle.filledStyle;;
    }
    return definition;
}

@end
