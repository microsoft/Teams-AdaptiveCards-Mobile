//
//  ACRBadgeView.m
//  AdaptiveCards
//
//  Created by reenulnu on 09/10/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACRBadgeView.h"

@implementation ACRBadgeView
{
    NSString *_text;
    ACRBadgeAppearance _appearance;
    ACRIconPosition _iconPosition;
    ACRBadgeSize _size;
    ACRShape _shape;
    ACRBadgeStyle _style;
    ACOHostConfig *_hostConfig;
    UIView *_iconImageView;
    UILabel *_textLabel;
}


- (instancetype)initWithText:(NSString*)text
                        image:(UIView*)imageView
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
        _iconImageView = imageView;
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
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_iconImageView];
    
    // Initialize the UILabel
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.text = _text;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_textLabel];
    
    // Set top and bottom constraints for the iconImageView and textLabel
    [NSLayoutConstraint activateConstraints:@[
        [_iconImageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_iconImageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_textLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
    
    // Width and height constraints for each star
    [NSLayoutConstraint activateConstraints:@[
        [_iconImageView.widthAnchor constraintEqualToConstant:40],
        [_iconImageView.heightAnchor constraintEqualToConstant:40]
    ]];
    
    // Leading and Trailing constraint for the last star
    [NSLayoutConstraint activateConstraints:@[
        [_textLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [_iconImageView.leadingAnchor constraintEqualToAnchor:_textLabel.trailingAnchor constant:10],
        [_iconImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
    
    //setting colors
    
}


@end
