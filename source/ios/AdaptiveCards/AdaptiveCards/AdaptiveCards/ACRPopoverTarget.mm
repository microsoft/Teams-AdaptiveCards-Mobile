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
#import "ACRIBaseInputHandler.h"
#import "ACRView.h"
#import <UIKit/UIKit.h>
#import "ACRInputLabelView.h"
#import "ACROverflowTarget.h"

@implementation ACRPopoverTarget
{
    ACRBottomSheetViewController *currentBottomSheet;
}

- (instancetype)initWithActionElement:(ACOBaseActionElement *)actionElement rootView:(ACRView *)rootView
{
    self = [super init];
    if (self)
    {
        _actionElement = actionElement;
        _rootView = rootView;
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
    if (!_actionElement || _actionElement.type != ACRPopover)
    {
        return;
    }
    
    id<ACRActionDelegate> actionDelegate = _rootView.acrActionDelegate;
    if (![actionDelegate respondsToSelector:@selector(activeViewController)])
    {
        return;
    }
    
    UIViewController *host = [actionDelegate activeViewController];
    if (!host)
    {
        return;
    }
    
    // Create or reuse cached content view for input retention
    if (!_cachedContentView)
    {
        [self createCachedContentView];
    }
    else
    {
        [self markActionTargetsAsFromBottomSheet:_cachedContentView];
    }
    
    if (!_cachedContentView)
    {
        return;
    }
    [self attachBottomSheetInputsToMainCard];
    
    CGFloat minMultiplier = 0.2;
    CGFloat maxMultiplier = 0.66;
    CGFloat borderHeight = 0.5;
    CGFloat closeButtonTopInset = 16;
    CGFloat closeButtonSideInset = 12;
    CGFloat closeButtonToScrollGap = 20;
    CGFloat contentPadding = 16;
    CGFloat closeButtonSize = 28.0;
    
    ACRBottomSheetConfiguration *config = [[ACRBottomSheetConfiguration alloc] initWithMinMultiplier:minMultiplier
                                                                                       maxMultiplier:maxMultiplier
                                                                                        borderHeight:borderHeight
                                                                                 closeButtonTopInset:closeButtonTopInset
                                                                                closeButtonSideInset:closeButtonSideInset
                                                                              closeButtonToScrollGap:closeButtonToScrollGap
                                                                                      contentPadding:contentPadding
                                                                                     closeButtonSize:closeButtonSize];
    
    currentBottomSheet = [[ACRBottomSheetViewController alloc]
                          initWithContent:_cachedContentView
                          configuration:config];
    
    __weak ACRPopoverTarget *weakSelf = self;
    currentBottomSheet.onDismissBlock = ^{
        __strong ACRPopoverTarget *strongSelf = weakSelf;
        if (strongSelf)
        {
            [strongSelf detachBottomSheetInputsFromMainCard];
        }
    };
    [host presentViewController:currentBottomSheet animated:YES completion:nil];
    
}

- (void)bottomSheetCloseTapped
{
    [self detachBottomSheetInputsFromMainCard];
    
}

- (void)createCachedContentView
{
    // Get the popover content from the action
    std::shared_ptr<BaseActionElement> base = [_actionElement element];
    auto popoverAction = std::dynamic_pointer_cast<AdaptiveCards::PopoverAction>(base);
    std::shared_ptr<AdaptiveCards::BaseCardElement> content = popoverAction ? popoverAction->GetContent() : nullptr;
    
    if (!content)
    {
        return;
    }
    
    ACOBaseCardElement *acoElement = [[ACOBaseCardElement alloc] initWithBaseCardElement:content];
    
    ACRCardElementType elementType = (ACRCardElementType)content->GetElementType();
    NSNumber *key = @(elementType);
    ACRBaseCardElementRenderer *renderer = [[ACRRegistration getInstance] getRenderer:key];
    if (!renderer)
    {
        return;
    }
    
    // Prepare shared inputs (shared with main card for state consistency)
    NSMutableArray *sharedInputs = (NSMutableArray *)[[_rootView card] getInputs];
    if (!sharedInputs)
    {
        sharedInputs = [NSMutableArray array];
        [[_rootView card] setInputs:sharedInputs];
    }
    _cachedContentView = [[ACRContentStackView alloc] initWithStyle:ACRDefault
                                                        parentStyle:ACRDefault
                                                         hostConfig:_rootView.hostConfig
                                                          superview:_rootView];
    _rootView.isRenderingInBottomSheet = YES;
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
    for (UIView *subview in containerView.subviews)
    {
        for (UIGestureRecognizer *recognizer in subview.gestureRecognizers)
        {
            if ([recognizer.delegate isKindOfClass:[ACRBaseTarget class]])
            {
                ACRBaseTarget *target = (ACRBaseTarget *)recognizer.delegate;
                target.parentPopoverTarget = self;
                [self filterActionTarget:target forView:subview];
            }
        }
        
        // Check if this view has any target-action connections with ACRBaseTarget
        if ([subview isKindOfClass:[UIControl class]])
        {
            UIControl *control = (UIControl *)subview;
            NSSet *targets = [control allTargets];
            for (id target in targets)
            {
                if ([target isKindOfClass:[ACRBaseTarget class]])
                {
                    ACRBaseTarget *baseTarget = (ACRBaseTarget *)target;
                    baseTarget.parentPopoverTarget = self;
                    [self filterActionTarget:baseTarget forView:subview];
                    if ([baseTarget isKindOfClass:[ACROverflowTarget class]])
                    {
                        [self propagatePopoverContextToOverflowMenuItems:(ACROverflowTarget *)baseTarget];
                    }
                }
            }
        }
        
        [self markActionTargetsAsFromBottomSheet:subview];
    }
}

- (void)propagatePopoverContextToOverflowMenuItems:(ACROverflowTarget *)overflowTarget
{
    NSArray<ACROverflowMenuItem *> *menuItems = overflowTarget.menuItems;
    for (ACROverflowMenuItem *menuItem in menuItems)
    {
        NSObject<ACRSelectActionDelegate> *itemTarget = menuItem.target;
        if ([itemTarget isKindOfClass:[ACRBaseTarget class]])
        {
            ACRBaseTarget *baseTarget = (ACRBaseTarget *)itemTarget;
            baseTarget.parentPopoverTarget = self;
        }
    }
}

- (void)filterActionTarget:(ACRBaseTarget *)target forView:(UIView *)view
{
    if ([target respondsToSelector:@selector(actionElement)])
    {
        ACOBaseActionElement *actionElement = [target performSelector:@selector(actionElement)];
        if (actionElement)
        {
            ACRActionType actionType = actionElement.type;
            
            // Hide forbidden actions in bottom sheet
            if (actionType == ACRToggleVisibility ||
                actionType == ACRShowCard ||
                actionType == ACRPopover)
            {
                [view removeFromSuperview];
            }
            
            if ((actionType == ACRSubmit || actionType == ACRExecute) &&
                actionElement.menuActions.count > 0)
            {
                actionElement.isActionFromSplitButtonBottomSheet = YES;
                
            }
        }
    }
}

- (void)dismissBottomSheet
{
    if (currentBottomSheet && currentBottomSheet.presentingViewController)
    {
        [currentBottomSheet dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)attachBottomSheetInputsToMainCard
{
    if (!_cachedContentView || !_rootView)
    {
        return;
    }
    
    
    NSMutableArray *bottomSheetInputs = [NSMutableArray array];
    [self findInputHandlersInView:_cachedContentView inputs:bottomSheetInputs];
    
    [_rootView.inputHandlers addObjectsFromArray:bottomSheetInputs];
}


- (void)findInputHandlersInView:(UIView *)view inputs:(NSMutableArray *)inputHandlers
{
    if ([view conformsToProtocol:@protocol(ACRIBaseInputHandler)])
    {
        id<ACRIBaseInputHandler> inputHandler = (id<ACRIBaseInputHandler>)view;
        [inputHandlers addObject:inputHandler];
        
        if ([view isKindOfClass:[ACRInputLabelView class]])
        {
            ACRInputLabelView *labelView = (ACRInputLabelView *)view;
            NSObject<ACRIBaseInputHandler> *underlyingHandler = [labelView getInputHandler];
            if (underlyingHandler && underlyingHandler != labelView)
            {
                
                underlyingHandler.isRequired = NO;
            }
        }
    }
    
    for (UIView *subview in view.subviews)
    {
        [self findInputHandlersInView:subview inputs:inputHandlers];
    }
}

- (void)detachBottomSheetInputsFromMainCard
{
    if (!_cachedContentView || !_rootView)
    {
        return;
    }
    
    NSMutableArray *bottomSheetInputs = [NSMutableArray array];
    [self findInputHandlersInView:_cachedContentView inputs:bottomSheetInputs];
    
    for (id<ACRIBaseInputHandler> input in bottomSheetInputs)
    {
        [_rootView.inputHandlers removeObject:input];
    }
}

@end
