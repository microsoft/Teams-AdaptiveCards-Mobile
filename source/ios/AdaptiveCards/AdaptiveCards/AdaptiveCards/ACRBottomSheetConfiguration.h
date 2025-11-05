//
//  ACRBottomSheetConfiguration.h
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACOHostConfig.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Configuration class for customizing bottom sheet presentation behavior and appearance.
 * This class provides settings for height constraints, UI element positioning, and visual styling
 * of bottom sheets used to display Adaptive Card content.
 */
@interface ACRBottomSheetConfiguration : NSObject

#pragma mark - Height Configuration

/// The minimum height multiplier (0.0 - 1.0) relative to the screen height
@property (nonatomic) CGFloat minHeightMultiplier;

/// The maximum height multiplier (0.0 - 1.0) relative to the screen height
@property (nonatomic) CGFloat maxHeightMultiplier;

/// The miniimum height in points. If set, this overrides minHeightMultiplier
@property (nonatomic) CGFloat minHeight;

#pragma mark - Visual Styling

/// The height of the top border/handle indicator in points
@property (nonatomic) CGFloat borderHeight;

/// The padding applied to the content area in points
@property (nonatomic) CGFloat contentPadding;

#pragma mark - Close Button Configuration

/// Whether to show the close button
@property (nonatomic) BOOL showCloseButton;

/// The size of the close button in points (width and height)
@property (nonatomic) CGFloat closeButtonSize;

/// The insets for the close button from the edges (top, left, bottom, right)
/// Note: The bottom inset represents the gap between the close button and scrollable content
@property (nonatomic) UIEdgeInsets closeButtonInsets;

#pragma mark - Host Configuration

/// The host configuration used for styling Adaptive Card content
@property (nonatomic, strong) ACOHostConfig *hostConfig;

#pragma mark - Initialization

/**
 * Designated initializer for creating a bottom sheet configuration with default values.
 *
 * @param hostConfig The host configuration for content styling
 * @return A configured ACRBottomSheetConfiguration instance with default values
 */
- (instancetype)initWithHostConfig:(ACOHostConfig *)hostConfig NS_DESIGNATED_INITIALIZER;

/**
 * Unavailable. Use initWithHostConfig: instead.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
