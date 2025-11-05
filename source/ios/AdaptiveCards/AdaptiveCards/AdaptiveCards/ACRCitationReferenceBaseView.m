//
//  ACRCitationReferenceBaseView.m
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 05/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationReferenceBaseView.h"

// Layout Constants
static const CGFloat kACRCitationViewSpacing = 8.0;

// Header Constants
static const CGFloat kACRCitationHeaderHeight = 40.0;
static const CGFloat kACRCitationHeaderTitleHeight = 28.0;
static const CGFloat kACRCitationHeaderBottomPadding = 12.0;
static const CGFloat kACRCitationHeaderFontSize = 17.0;
static const NSInteger kACRCitationHeaderTextColor = 32;

// Separator Constants
static const CGFloat kACRCitationSeparatorHeight = 1.0;
static const NSInteger kACRCitationSeparatorColor = 224;


@interface ACRCitationReferenceBaseView ()
@property (nonatomic, weak, readwrite) UIStackView *rootStackView;
@property (nonatomic, weak, readwrite) UIView *headerSection;
@property (nonatomic, weak, readwrite) UILabel *headerTitleLabel;
@property (nonatomic, weak, readwrite) UIView *separatorView;
@end

@implementation ACRCitationReferenceBaseView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBaseUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupBaseUI];
    }
    return self;
}

#pragma mark - Base UI Setup

- (void)setupBaseUI {
    self.backgroundColor = [UIColor systemBackgroundColor];
    
    // Create root vertical stack view with padding
    UIStackView *rootStackView = [[UIStackView alloc] init];
    rootStackView.axis = UILayoutConstraintAxisVertical;
    rootStackView.spacing = kACRCitationViewSpacing;
    rootStackView.alignment = UIStackViewAlignmentFill;
    rootStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:rootStackView];
    self.rootStackView = rootStackView;
    
    // Setup header section (title only)
    UIView *headerSection = [self setupHeaderSection];
    [self.rootStackView addArrangedSubview:headerSection];
    self.headerSection = headerSection;
    
    // Add separator as direct child of main view (spans full width)
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor grayColorWithValue:kACRCitationSeparatorColor];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:separatorView];
    self.separatorView = separatorView;
    
    // Setup base constraints
    [self setupBaseConstraints];
    
    // Allow subclasses to add their content
    [self setupContentView];
    
    // Allow subclasses to add their constraints
    [self setupContentConstraints];
}

- (UIView *)setupHeaderSection {
    UIView *headerSection = [[UIView alloc] init];
    headerSection.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Header title label
    UILabel *headerTitleLabel = [[UILabel alloc] init];
    headerTitleLabel.text = @"References";
    headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    headerTitleLabel.font = [UIFont systemFontOfSize:kACRCitationHeaderFontSize weight:UIFontWeightSemibold];
    headerTitleLabel.textColor = [UIColor grayColorWithValue:kACRCitationHeaderTextColor];
    headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [headerSection addSubview:headerTitleLabel];
    self.headerTitleLabel = headerTitleLabel;
    
    return headerSection;
}

- (void)setupBaseConstraints {
    // Root stack view constraints with padding
    [NSLayoutConstraint activateConstraints:@[
        [self.rootStackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:kACRCitationViewSpacing],
        [self.rootStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:kACRCitationViewSpacing],
        [self.rootStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-kACRCitationViewSpacing],
        [self.rootStackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-kACRCitationViewSpacing]
    ]];
    
    // Full-width separator positioned below header section
    [NSLayoutConstraint activateConstraints:@[
        [self.separatorView.topAnchor constraintEqualToAnchor:self.headerSection.bottomAnchor],
        [self.separatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.separatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.separatorView.heightAnchor constraintEqualToConstant:kACRCitationSeparatorHeight]
    ]];
    
    // Header section constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.headerSection.heightAnchor constraintEqualToConstant:kACRCitationHeaderHeight],
        [self.headerTitleLabel.heightAnchor constraintEqualToConstant:kACRCitationHeaderTitleHeight],
        [self.headerTitleLabel.topAnchor constraintEqualToAnchor:self.headerSection.topAnchor],
        [self.headerTitleLabel.leadingAnchor constraintEqualToAnchor:self.headerSection.leadingAnchor],
        [self.headerTitleLabel.trailingAnchor constraintEqualToAnchor:self.headerSection.trailingAnchor],
        [self.headerTitleLabel.bottomAnchor constraintEqualToAnchor:self.headerSection.bottomAnchor constant:-kACRCitationHeaderBottomPadding]
    ]];
}

#pragma mark - Subclass Override Points

- (void)setupContentView {
    // Base implementation does nothing - subclasses should override
    // Subclasses should add their content views to self.rootStackView
}

- (void)setupContentConstraints {
    // Base implementation does nothing - subclasses should override
    // Subclasses should add their content-specific constraints here
}

@end

#pragma mark - UIColor Private Extension

@implementation UIColor (ACRCitationReferenceBaseView)

+ (UIColor *)grayColorWithValue:(NSInteger)value {
    // Clamp value to 0-255 range
    NSInteger clampedValue = MAX(0, MIN(255, value));
    CGFloat normalizedValue = clampedValue / 255.0;
    
    return [UIColor colorWithRed:normalizedValue 
                           green:normalizedValue 
                            blue:normalizedValue 
                           alpha:1.0];
}

@end
