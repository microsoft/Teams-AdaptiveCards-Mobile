//
//  ACRToggleVisibilityTarget
//  ACRToggleVisibilityTarget.mm
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ACRToggleVisibilityTarget.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACOVisibilityManager.h"
#import "ACRRendererPrivate.h"
#import "ACRView.h"
#import "BaseActionElement.h"
#import "ToggleVisibilityTarget.h"
#import "ACRIFeatureFlagResolver.h"
#import "ACRRegistration.h"

@implementation ACRToggleVisibilityTarget {
    ACOHostConfig *_config;
    __weak ACRView *_rootView;
    ACOBaseActionElement *_actionElement;
}

- (instancetype)initWithActionElement:(ACOBaseActionElement *)actionElement
                               config:(ACOHostConfig *)config
                             rootView:(ACRView *)rootView
{
    self = [super init];
    if (self) {
        _config = config;
        _rootView = rootView;
        _actionElement = actionElement;
    }
    return self;
}

- (void)doSelectAction
{
    NSObject<ACRIFeatureFlagResolver> *featureFlagResolver = [[ACRRegistration getInstance] getFeatureFlagResolver];
    BOOL isSplitButtonEnabled = [featureFlagResolver boolForFlag:@"isSplitButtonEnabled"] ?: NO;
    isSplitButtonEnabled = isSplitButtonEnabled &&
    [_rootView.acrActionDelegate respondsToSelector:@selector(showBottomSheetForSplitButton:completion:)];
    /// Perform default implementation if:
    /// 1. If split button is disabled or
    /// 2. There are no menuactions or
    /// 3.a. There are menuactions and
    /// 3.b. (If the action is from bottom sheet) or (If there's no implementation of showBottomSheetForSplitButton method in delegate)
    if (!isSplitButtonEnabled ||
        _actionElement.menuActions.count <= 0 ||
        (_actionElement.menuActions.count > 0 &&
         (_actionElement.isActionFromSplitButtonBottomSheet)))
    {
        [self doSelectActionWithAction:_actionElement];
    }
    else
    {
        NSArray<ACOBaseActionElement *> *menuActions = [@[ _actionElement ] arrayByAddingObjectsFromArray:_actionElement.menuActions];
        __weak __typeof(self) weakSelf = self;
        [_rootView.acrActionDelegate showBottomSheetForSplitButton: menuActions completion:^(ACOBaseActionElement *acoElement) {
            __strong __typeof(self) strongSelf = weakSelf;
            if (acoElement.type == ACRToggleVisibility)
            {
                [strongSelf doSelectActionWithAction:acoElement];
            }
            [strongSelf->_rootView.acrActionDelegate didFetchUserResponses:[strongSelf->_rootView card] action:acoElement];
        }];
    }

    [_rootView.acrActionDelegate didFetchUserResponses:[_rootView card] action:_actionElement];
}

- (void) doSelectActionWithAction:(ACOBaseActionElement *)actionElement
{
    NSMutableSet<id<ACOIVisibilityManagerFacade>> *facades = [[NSMutableSet alloc] init];
    std::shared_ptr<BaseActionElement> elem = [actionElement element];
    std::shared_ptr<ToggleVisibilityAction> action = std::dynamic_pointer_cast<ToggleVisibilityAction>(elem);
    for (const auto &target : action->GetTargetElements()) {
        NSString *hashString = [NSString stringWithCString:target->GetElementId().c_str() encoding:NSUTF8StringEncoding];
        NSUInteger tag = hashString.hash;
        UIView *view = [_rootView viewWithTag:tag];
        BOOL bHide = NO;

        id<ACOIVisibilityManagerFacade> facade = [_rootView.context retrieveVisiblityManagerWithTag:view.tag];
        [facades addObject:facade];

        AdaptiveCards::IsVisible toggleEnum = target->GetIsVisible();
        if (toggleEnum == AdaptiveCards::IsVisibleToggle) {
            BOOL isHidden = view.isHidden;
            bHide = !isHidden;
        } else if (toggleEnum == AdaptiveCards::IsVisibleTrue) {
            bHide = NO;
        } else {
            bHide = YES;
        }

        if (facade) {
            if (bHide) {
                [facade hideView:view];
            } else {
                [facade unhideView:view];
            }
        }
    }

    for (id<ACOIVisibilityManagerFacade> viewToUpdateVisibility in facades) {
        [viewToUpdateVisibility updatePaddingVisibility];
    }
}

@end
