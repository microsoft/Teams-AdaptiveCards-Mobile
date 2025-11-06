//
//  ACRCitationReferenceMoreDetailsView.m
//  AdaptiveCards
//
//  Created by Harika P on 05/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationReferenceMoreDetailsView.h"

@interface ACRCitationReferenceMoreDetailsView ()
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *adaptiveCard;
@end

@implementation ACRCitationReferenceMoreDetailsView

#pragma mark - Initialization

#import "ACRCitationReferenceMoreDetailsView.h"

@implementation ACRCitationReferenceMoreDetailsView

#pragma mark - Initialization

- (instancetype)initWithAdaptiveCard:(UIView *)adaptiveCard {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _adaptiveCard = adaptiveCard;
        [self setupUI];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setupUI {
    self.backgroundColor = [UIColor systemBackgroundColor];
    
    if (self.adaptiveCard) {
        self.adaptiveCard.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.adaptiveCard];
        
        // Set up constraints to fill the view
        [NSLayoutConstraint activateConstraints:@[
            [self.adaptiveCard.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.adaptiveCard.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [self.adaptiveCard.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [self.adaptiveCard.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        // Set priorities for proper sizing
        [self.adaptiveCard setContentCompressionResistancePriority:UILayoutPriorityRequired 
                                                           forAxis:UILayoutConstraintAxisVertical];
        [self.adaptiveCard setContentHuggingPriority:UILayoutPriorityDefaultLow 
                                             forAxis:UILayoutConstraintAxisVertical];
    }
}

@end

#pragma mark - Base Class Overrides

- (void)setupContentViewWithAdaptiveCard:(UIView *)cardView {
    
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.rootStackView addArrangedSubview:contentView];
    self.contentView = contentView;
    
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:cardView];
    self.adaptiveCard = cardView;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.adaptiveCard.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.adaptiveCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.adaptiveCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.adaptiveCard.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor]
    ]];
    
    [self.adaptiveCard setContentCompressionResistancePriority:UILayoutPriorityRequired
                                                       forAxis:UILayoutConstraintAxisVertical];
    // Ensure the root stack view fills available space
    if (self.rootStackView) {
        self.rootStackView.distribution = UIStackViewDistributionFill;
    }
}

@end
