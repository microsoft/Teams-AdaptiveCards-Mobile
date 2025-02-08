//
//  ACRToggleInputView.m
//  AdaptiveCards
//
//  Copyright © 2020 Microsoft. All rights reserved.
//

#import "ACRToggleInputView.h"
#import "ACOBundle.h"
#import <Foundation/Foundation.h>

@implementation ACRToggleInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit
{
    // Initialize contentView
    UIStackView *contentview = [[UIStackView alloc] init];
    contentview.axis = UILayoutConstraintAxisHorizontal;
    contentview.alignment = UIStackViewAlignmentCenter;
    contentview.translatesAutoresizingMaskIntoConstraints = NO;

    // Initialize title label
    UILabel *title = [[UILabel alloc] init];
    title.numberOfLines = 0;
    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [contentview addArrangedSubview:title];

    // Initialize toggle switch
    UISwitch *toggle = [[UISwitch alloc] init];
    toggle.translatesAutoresizingMaskIntoConstraints = NO;
    [contentview addArrangedSubview:toggle];

    [title setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    toggle.tintColor = self.switchOffStateColor;
    toggle.backgroundColor = self.switchOffStateColor;
    toggle.layer.cornerRadius = 16.0f;

    // Set properties
    _contentview = contentview;
    _title = title;
    _toggle = toggle;

    // Add contentview to the view
    [self addSubview:contentview];

    // Set constraints for contentView
    [NSLayoutConstraint activateConstraints:@[
        [contentview.leadingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.leadingAnchor],
        [contentview.trailingAnchor constraintEqualToAnchor:self.layoutMarginsGuide.trailingAnchor],
        [contentview.centerYAnchor constraintEqualToAnchor:self.layoutMarginsGuide.centerYAnchor],
        [contentview.heightAnchor constraintEqualToAnchor:self.heightAnchor],
    ]];

    // Configure margins
    if (@available(iOS 11.0, *)) {
        NSDirectionalEdgeInsets insets = self.directionalLayoutMargins;
        insets.leading = 0.0f;
        insets.trailing = 2.0f;
        self.directionalLayoutMargins = insets;
    } else {
        UIEdgeInsets insets = self.layoutMargins;
        insets.left = 0.0f;
        insets.right = 2.0f;
        self.layoutMargins = insets;
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize labelIntrinsicContentSize = [_title intrinsicContentSize];
    CGSize switchIntrinsicContentSize = [_toggle intrinsicContentSize];
    return CGSizeMake(labelIntrinsicContentSize.width + _contentview.spacing + switchIntrinsicContentSize.width, MAX(labelIntrinsicContentSize.height, switchIntrinsicContentSize.height));
}

@end
