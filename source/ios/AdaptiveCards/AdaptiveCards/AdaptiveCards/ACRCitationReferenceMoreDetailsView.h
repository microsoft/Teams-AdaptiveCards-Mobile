//
//  ACRCitationReferenceMoreDetailsView.h
//  AdaptiveCards
//
//  Created by Harika P on 05/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACOAdaptiveCard.h"

@class ACOReference;
@class ACOCitation;
@class ACRCitationReferenceMoreDetailsView;

NS_ASSUME_NONNULL_BEGIN

/**
 * A custom UIView that renders a citation reference with a Adaptive card with no actionable elements
 */
@interface ACRCitationReferenceMoreDetailsView : UIView

/**
 * The Adaptive card to display
 */
@property (nonatomic, strong) UIView *adaptiveCard;

/**
 * Initialize with a adaptive card
 * @param adaptiveCard  Adaptive card that needs to be displayed inside more details bottomsheet
 */
- (instancetype)initWithAdaptiveCard:(UIView *)adaptiveCard;

@end

NS_ASSUME_NONNULL_END
