//
//  ACRCitationReferenceMoreDetailsView.m
//  AdaptiveCards
//
//  Created by Harika P on 05/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationReferenceMoreDetailsView.h"
#import "ACOReference.h"
#import "ACOCitation.h"
#import "ACOBundle.h"

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

@interface UIColor (ACRCitationReferenceMoreDetailsView)
+ (UIColor *)grayColorWithValue:(NSInteger)value;
@end

@interface ACRCitationReferenceMoreDetailsView ()

// Main structure - Root vertical stack view
@property (nonatomic, weak) UIStackView *rootStackView;

// Header section with title and separator
@property (nonatomic, weak) UIView *headerSection;
@property (nonatomic, weak) UILabel *headerTitleLabel;
@property (nonatomic, weak) UIView *separatorView;

// Main content horizontal stack view
@property (nonatomic, weak) UIStackView *mainContentStackView;

@end

@implementation ACRCitationReferenceMoreDetailsView

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (instancetype)initWithAdaptiveCard:(UIView *)adaptiveCard
{
    self = [self initWithFrame:CGRectZero];
    self.adaptiveCard = adaptiveCard;
    [self setupUI];
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = [UIColor systemBackgroundColor];
    
    // Create root vertical stack view with padding
    UIStackView *rootStackView = [[UIStackView alloc] init];
    rootStackView.axis = UILayoutConstraintAxisVertical;
    rootStackView.spacing = kACRCitationViewSpacing;
    rootStackView.alignment = UIStackViewAlignmentFill;
    rootStackView.translatesAutoresizingMaskIntoConstraints = NO;


    [self addSubview:rootStackView];
    self.rootStackView = rootStackView;
    
    // Setup header section (title only, no separator)
    UIView *headerSection = [self setupHeaderSection];
    [self.rootStackView addArrangedSubview:headerSection];
    self.headerSection = headerSection;

    
    // Add separator as direct child of main view (spans full width)
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor grayColorWithValue:kACRCitationSeparatorColor];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:separatorView];
    self.separatorView = separatorView;
    
    // Setup main content section
    UIStackView *mainContentStackView = [self setupMainContentSection];
    [self.rootStackView addArrangedSubview:mainContentStackView];
    self.mainContentStackView = mainContentStackView;

    // Setup constraints
    [self setupConstraints];
}

// Header section with "References" title only
- (UIView *) setupHeaderSection {
    UIView *headerSection = [[UIView alloc] init];
    headerSection.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Header title label
    UILabel *headerTitleLabel = [[UILabel alloc] init];
    headerTitleLabel.text = NSLocalizedString(@"References", nil);
    headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    headerTitleLabel.font = [UIFont systemFontOfSize:kACRCitationHeaderFontSize weight:UIFontWeightSemibold];
    headerTitleLabel.textColor =  [UIColor grayColorWithValue:kACRCitationHeaderTextColor];
    headerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;


    [headerSection addSubview:headerTitleLabel];
    self.headerTitleLabel = headerTitleLabel;

    return headerSection;
}

// Main content horizontal stack view
- (UIStackView *)setupMainContentSection {
    UIStackView *mainContentStackView = [[UIStackView alloc] init];
    mainContentStackView.axis = UILayoutConstraintAxisHorizontal;
    mainContentStackView.spacing = kACRCitationViewSpacing;
    mainContentStackView.alignment = UIStackViewAlignmentTop;
    mainContentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [mainContentStackView addArrangedSubview:self.adaptiveCard];
    
    return mainContentStackView;
}

- (void)setupConstraints {
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
    
    // Constraints for adaptive card view
    [NSLayoutConstraint activateConstraints:@[
        [self.adaptiveCard.topAnchor constraintEqualToAnchor:self.mainContentStackView.topAnchor],
        [self.adaptiveCard.leadingAnchor constraintEqualToAnchor:self.mainContentStackView.leadingAnchor],
        [self.adaptiveCard.trailingAnchor constraintEqualToAnchor:self.mainContentStackView.trailingAnchor],
        [self.adaptiveCard.bottomAnchor constraintEqualToAnchor:self.mainContentStackView.bottomAnchor]
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

@end

#pragma mark - UIColor Private Extension

@implementation UIColor (ACRCitationReferenceMoreDetailsView)

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
