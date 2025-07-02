//
//  ACRPopoverTarget.h
//  AdaptiveCards
//
//  Created by Jitisha Azad on 01/07/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACOInputResults.h"
#import "ACRBaseTarget.h"
#import <AdaptiveCards/ACOInputResults.h>
#import <AdaptiveCards/ACRBaseTarget.h>

#import "ACRIContentHoldingView.h"
#import "ACRView.h"
#import <UIKit/UIKit.h>

@interface ACRPopoverTarget : ACRBaseTarget

@property ACOBaseActionElement *actionElement;
@property (weak) ACRView *rootView;
@property (assign) BOOL isFromBottomSheet; // Mark if action originated from bottom sheet
@property (strong) ACRContentStackView *cachedContentView;

- (instancetype)initWithActionElement:(ACOBaseActionElement *)actionElement rootView:(ACRView *)rootView;

// Event handler when the popover action is triggered (button tap, image tap, etc.)
- (IBAction)send:(UIButton *)sender;

// Main action method - presents the popover content in bottom sheet
- (void)doSelectAction;

// Present popover with content - can be called directly for any UI element
- (void)presentPopover;

// Dismiss popover if currently presented
- (void)dismissBottomSheetAndClearCache;

- (void)clearCachedContent;



@end
