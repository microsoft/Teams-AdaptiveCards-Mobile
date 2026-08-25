//
//  ACROverflowTarget
//  ACROverflowTarget.h
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "ACOActionOverflow.h"
#import "ACRBaseTarget.h"
#import "ACRIContentHoldingView.h"
#import "ACRView.h"
#import <UIKit/UIKit.h>

@interface ACROverflowMenuItem : NSObject

@property (readonly) NSString *title;
@property (readonly) NSString *iconUrl;
@property (readonly) NSObject<ACRSelectActionDelegate> *target;
- (void)loadIconImageWithSize:(CGSize)size
                 onIconLoaded:(void (^)(UIImage *))onIconLoaded;

@end

@interface ACROverflowTarget : ACRBaseTarget

- (instancetype)initWithActionElement:(ACOActionOverflow *)actionElement
                             rootView:(ACRView *)rootView;

- (void)setInputs:(NSMutableArray *)inputs
        superview:(UIView<ACRIContentHoldingView> *)superview;

@property (readonly) NSArray<ACROverflowMenuItem *> *menuItems;

/// The control that opened the overflow menu. VoiceOver focus is returned here when the
/// menu is dismissed, so the user lands back where they were instead of at the top of
/// the screen.
@property (nonatomic, weak) UIView *accessibilityFocusAnchor;

@end
