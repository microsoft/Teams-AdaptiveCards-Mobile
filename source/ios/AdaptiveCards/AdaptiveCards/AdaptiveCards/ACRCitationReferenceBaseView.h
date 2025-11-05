//
//  ACRCitationBaseView.h
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 05/11/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ACRCitationReferenceBaseView)
+ (UIColor *)grayColorWithValue:(NSInteger)value;
@end

/**
 * Base class for citation views that provides common header UI with "References" title and separator.
 * Subclasses should override setupContentView to add their specific content below the header.
 */
@interface ACRCitationReferenceBaseView : UIView

// Header UI components - available to subclasses
@property (nonatomic, weak, readonly) UIStackView *rootStackView;
@property (nonatomic, weak, readonly) UIView *headerSection;
@property (nonatomic, weak, readonly) UILabel *headerTitleLabel;
@property (nonatomic, weak, readonly) UIView *separatorView;

/**
 * Override this method in subclasses to add content below the header.
 * The rootStackView is already set up and ready to receive content views.
 * Call [super setupContentView] first, then add your content to rootStackView.
 */
- (void)setupContentView;

/**
 * Override this method in subclasses to add content-specific constraints.
 * Base class constraints for header and separator are already set up.
 */
- (void)setupContentConstraints;

@end

NS_ASSUME_NONNULL_END