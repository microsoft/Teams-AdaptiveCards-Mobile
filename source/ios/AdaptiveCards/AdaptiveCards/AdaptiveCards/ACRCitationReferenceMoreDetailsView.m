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
@end

@implementation ACRCitationReferenceMoreDetailsView

#pragma mark - Initialization

- (instancetype)initWithAdaptiveCard:(UIView *)adaptiveCard {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setupContentViewWithAdaptiveCard: adaptiveCard];
    }
    return self;
}

#pragma mark - Base Class Overrides

- (void)setupContentViewWithAdaptiveCard:(UIView *)cardView {
    
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.rootStackView addArrangedSubview:contentView];
    self.contentView = contentView;
    
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:cardView];
//    [self.rootStackView addArrangedSubview:cardView];
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
        NSLog(@"ACRCitationReferenceMoreDetailsView: Set root stack view distribution to fill");
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Debug: Log the final frame sizes after layout
    NSLog(@"ACRCitationReferenceMoreDetailsView frame: %.2f x %.2f", 
          self.frame.size.width, self.frame.size.height);
    if (self.adaptiveCard) {
        NSLog(@"Adaptive card frame: %.2f x %.2f", 
              self.adaptiveCard.frame.size.width, self.adaptiveCard.frame.size.height);
    }
}

@end
