//
//  ACRPopoverTarget.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 01/07/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRPopoverTarget.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACRBottomSheetViewController.h"
#import "ACRBottomSheetConfiguration.h"
#import "ACRContentStackView.h"
#import "ACRRegistration.h"
#import "ACRBaseCardElementRenderer.h"  
#import "PopoverAction.h"
#import <AdaptiveCards/ACRRegistration.h>
#import <AdaptiveCards/ACOBaseCardElement.h>
#import <AdaptiveCards/ACRIBaseCardElementRenderer.h>
#import "ACRView.h"
#import <UIKit/UIKit.h>

@implementation ACRPopoverTarget {
    ACRBottomSheetViewController *currentBottomSheet;
}

- (instancetype)initWithActionElement:(ACOBaseActionElement *)actionElement rootView:(ACRView *)rootView
{
    self = [super init];
    if (self) {
        _actionElement = actionElement;
        _rootView = rootView;
        _isFromBottomSheet = NO;
        currentBottomSheet = nil;
        _cachedContentView = nil;
    }
    return self;
}

- (IBAction)send:(UIButton *)sender
{
    [self doSelectAction];
}

- (void)doSelectAction
{
    [self presentPopover];
}


- (void)presentPopover
{
    if (!_actionElement || _actionElement.type != ACRPopover) {
        return;
    }
    
    id<ACRActionDelegate> dlg = _rootView.acrActionDelegate;
    if (![dlg respondsToSelector:@selector(presenterViewControllerForAction:inCard:)]) {
        return;
    }
    
    UIViewController *host = [dlg presenterViewControllerForAction:_actionElement inCard:[_rootView card]];
    if (!host) {
        return;
    }
    
    // Create or reuse cached content view for input retention
    if (!_cachedContentView) {
        [self createCachedContentView];
    }
    
    if (!_cachedContentView) {
        return; // Failed to create content
    }
    
    // Configure bottom sheet appearance
    CGFloat minMultiplier = 0.2;
    CGFloat maxMultiplier = 0.66;
    
    ACRBottomSheetConfiguration *config = [[ACRBottomSheetConfiguration alloc]
        initWithMinMultiplier:minMultiplier
        maxMultiplier:maxMultiplier];
    
    // Create and present the bottom sheet with cached content
        currentBottomSheet = [[ACRBottomSheetViewController alloc]
            initWithContent:_cachedContentView
            configuration:config];
        
        [host presentViewController:currentBottomSheet animated:YES completion:nil];
}

- (void)createCachedContentView
{
    // Get the popover content from the action
    std::shared_ptr<BaseActionElement> base = [_actionElement element];
    auto popoverAction = std::dynamic_pointer_cast<AdaptiveCards::PopoverAction>(base);
    std::shared_ptr<AdaptiveCards::BaseCardElement> content = popoverAction ? popoverAction->GetContent() : nullptr;
    
    if (!content) {
        return;
    }
    
    ACOBaseCardElement *acoElement = [[ACOBaseCardElement alloc] initWithBaseCardElement:content];
    
    // Get the appropriate renderer for the content
    ACRCardElementType elementType = (ACRCardElementType)content->GetElementType();
    NSNumber *key = @(elementType);
    ACRBaseCardElementRenderer *renderer = [[ACRRegistration getInstance] getRenderer:key];
    if (!renderer) {
        return;
    }
    
    // Prepare shared inputs (shared with main card for state consistency)
    NSMutableArray *sharedInputs = (NSMutableArray *)[[_rootView card] getInputs];
    if (!sharedInputs) {
        sharedInputs = [NSMutableArray array];
        [[_rootView card] setInputs:sharedInputs];
    }
    _cachedContentView = [[ACRContentStackView alloc] initWithStyle:ACRDefault
                                                         parentStyle:ACRDefault
                                                          hostConfig:_rootView.hostConfig
                                                           superview:_rootView];
     
     // Render the content into the cached container
     [renderer render:_cachedContentView
             rootView:_rootView
               inputs:sharedInputs
      baseCardElement:acoElement
           hostConfig:_rootView.hostConfig];
    
    [self markActionTargetsAsFromBottomSheet:_cachedContentView];
 }

- (void)markActionTargetsAsFromBottomSheet:(UIView *)containerView
{
    // Traverse all subviews to find and mark action targets
    for (UIView *subview in containerView.subviews) {
        // Check if this view has any gesture recognizers with ACRBaseTarget
        for (UIGestureRecognizer *recognizer in subview.gestureRecognizers) {
            if ([recognizer.delegate isKindOfClass:[ACRBaseTarget class]]) {
                ACRBaseTarget *target = (ACRBaseTarget *)recognizer.delegate;
                target.parentPopoverTarget = self;
            }
        }
        
        // Check if this view has any target-action connections with ACRBaseTarget
        if ([subview isKindOfClass:[UIControl class]]) {
            UIControl *control = (UIControl *)subview;
            NSSet *targets = [control allTargets];
            for (id target in targets) {
                if ([target isKindOfClass:[ACRBaseTarget class]]) {
                    ACRBaseTarget *baseTarget = (ACRBaseTarget *)target;
                    baseTarget.parentPopoverTarget = self;
                }
            }
        }
        
        // Recursively process subviews
        [self markActionTargetsAsFromBottomSheet:subview];
    }
}

- (void)dismissBottomSheetAndClearCache
{
    if (currentBottomSheet && currentBottomSheet.presentingViewController) {
        [currentBottomSheet dismissViewControllerAnimated:YES completion:^{
            self->_cachedContentView = nil;
        }];
    } else {
        _cachedContentView = nil;
    }
    currentBottomSheet = nil;
}
- (void)clearCachedContent
{
    _cachedContentView = nil;
}
@end
