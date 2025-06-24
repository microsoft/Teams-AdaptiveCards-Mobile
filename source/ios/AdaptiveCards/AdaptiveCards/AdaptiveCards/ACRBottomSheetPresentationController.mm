//
//  ACRBottomSheetPresentationController.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 24/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRBottomSheetPresentationController.h"

@implementation ACRBottomSheetPresentationController
- (CGRect)frameOfPresentedViewInContainerView
{

    CGFloat want = self.presentedViewController.preferredContentSize.height;
    return CGRectMake(0, self.containerView.bounds.size.height - want, self.containerView.bounds.size.width, want);
}

- (void)containerViewWillLayoutSubviews
{
    self.presentedView.frame        = [self frameOfPresentedViewInContainerView];
    self.presentedView.layer.cornerRadius = 12;
    self.presentedView.clipsToBounds      = YES;
}

- (void)presentationTransitionWillBegin {}
- (void)dismissalTransitionWillBegin     {}
@end
