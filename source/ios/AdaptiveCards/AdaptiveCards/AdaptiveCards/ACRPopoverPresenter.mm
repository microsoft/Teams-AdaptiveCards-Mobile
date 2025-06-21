//
//  ACRPopoverPresenter.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 17/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//
#import "ACRPopoverPresenter.h"
#import <UIKit/UIKit.h>
#import <AdaptiveCards/AdaptiveCards.h>
#import <AdaptiveCards/ACRView.h>
#import <UIKit/UIViewController.h>
#import "ACRPopoverSheetVC.h"

@implementation ACRPopoverPresenter
+ (void)presentSheetForAction:(ACOBaseActionElement *)action
                         card:(ACOAdaptiveCard *)card
                         view:(ACRView *)root
{
    if (action.type!=ACRPopover) {
            return;
        }
    id<ACRActionDelegate> dlg = root.acrActionDelegate;
    if (![dlg respondsToSelector:@selector(presenterViewControllerForAction:inCard:)]) {
        return;                                 // host forgot to implement -> do nothing
    }
    
    UIViewController *host = [dlg presenterViewControllerForAction:action inCard:card];
    if (!host) {
        return;                                 // defensive ‑ the host returned nil
    }
    
    UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"ACRPopoverPresenter reached"
                                                message:@"delegate + validation path is working"
                                         preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [host presentViewController:alert animated:YES completion:nil];
    
}
@end
