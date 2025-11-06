//
//  ACRCitationReferenceMoreDetailsView.h
//  AdaptiveCards
//
//  Created by Harika P on 05/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACRCitationReferenceMoreDetailsView;

NS_ASSUME_NONNULL_BEGIN

/**
 * A view that displays an adaptive card content.
 */
@interface ACRCitationReferenceMoreDetailsView : UIView


/**
 * Initialize with an adaptive card
 * @param adaptiveCard The adaptive card view to display below the header
 */
- (instancetype)initWithAdaptiveCard:(UIView *)adaptiveCard;

@end

NS_ASSUME_NONNULL_END
