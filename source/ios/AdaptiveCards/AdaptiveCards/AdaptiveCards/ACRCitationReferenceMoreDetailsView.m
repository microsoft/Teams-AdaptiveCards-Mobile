//
//  ACRCitationReferenceMoreDetailsView.m
//  AdaptiveCards
//
//  Created by Harika P on 05/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRCitationReferenceMoreDetailsView.h"

@interface ACRCitationReferenceMoreDetailsView ()
@property (nonatomic, weak) UIStackView *contentStackView;
@end

@implementation ACRCitationReferenceMoreDetailsView

#pragma mark - Initialization

- (instancetype)initWithAdaptiveCard:(UIView *)adaptiveCard {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _adaptiveCard = adaptiveCard;
        [self setupContentView];
    }
    return self;
}

#pragma mark - Base Class Overrides

- (void)setupContentView {
    [super setupContentView];
    
    // Create content stack view to hold the adaptive card
    UIStackView *contentStackView = [[UIStackView alloc] init];
    contentStackView.axis = UILayoutConstraintAxisVertical;
    contentStackView.alignment = UIStackViewAlignmentFill;
    contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add the adaptive card to the content stack view
    if (self.adaptiveCard) {
        self.adaptiveCard.translatesAutoresizingMaskIntoConstraints = NO;
        [contentStackView addArrangedSubview:self.adaptiveCard];
    }
    
    // Add content stack view to the inherited root stack view
    [self.rootStackView addArrangedSubview:contentStackView];
    self.contentStackView = contentStackView;
}

- (void)setupContentConstraints {
    [super setupContentConstraints];
    
    // Content-specific constraints - the adaptive card should fill the content area
    if (self.adaptiveCard && self.contentStackView) {
        [NSLayoutConstraint activateConstraints:@[
            [self.adaptiveCard.topAnchor constraintEqualToAnchor:self.contentStackView.topAnchor],
            [self.adaptiveCard.leadingAnchor constraintEqualToAnchor:self.contentStackView.leadingAnchor],
            [self.adaptiveCard.trailingAnchor constraintEqualToAnchor:self.contentStackView.trailingAnchor],
            [self.adaptiveCard.bottomAnchor constraintEqualToAnchor:self.contentStackView.bottomAnchor]
        ]];
    }
}

@end
