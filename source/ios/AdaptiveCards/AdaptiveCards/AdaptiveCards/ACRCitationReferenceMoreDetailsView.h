//
//  ACRCitationReferenceMoreDetailsView.h
//  AdaptiveCards
//
//  Created by Harika P on 05/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACRCitationReferenceBaseView.h"

@class ACRCitationReferenceMoreDetailsView;

NS_ASSUME_NONNULL_BEGIN

/**
 * A view that displays an adaptive card with the standard citation reference header.
 * Inherits the "References" header and separator from ACRCitationReferenceBaseView.
 */
@interface ACRCitationReferenceMoreDetailsView : ACRCitationReferenceBaseView

/**
 * The Adaptive card to display
 */
@property (nonatomic, strong) UIView *adaptiveCard;

/**
 * Initialize with an adaptive card
 * @param adaptiveCard The adaptive card view to display below the header
 */
- (instancetype)initWithAdaptiveCard:(UIView *)adaptiveCard;

@end

NS_ASSUME_NONNULL_END
