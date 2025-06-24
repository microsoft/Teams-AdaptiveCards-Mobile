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
#import "ACRBottomSheetViewController.h"
#import "ACRBottomSheetConfiguration.h"

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
        return;
    }
    
    UIViewController *host = [dlg presenterViewControllerForAction:action inCard:card];
    if (!host) {
        return;                                 
    }
    
    UIStackView *stack = [[UIStackView alloc] init];
        stack.axis = UILayoutConstraintAxisVertical;
        stack.spacing = 12;
        stack.translatesAutoresizingMaskIntoConstraints = NO;

        // add 15 sample labels to exceed 2/3 screen; change the count to test
        for (int i = 0; i < 2; ++i) {
            UILabel *lbl = [[UILabel alloc] init];
            lbl.text = [NSString stringWithFormat:@"Row %d", i+1];
            lbl.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
            [stack addArrangedSubview:lbl];
        }
        CGFloat minMultiplier = 0.2;
        CGFloat maxMultiplier = 0.66;
        
    
        ACRBottomSheetConfiguration *config = [[ACRBottomSheetConfiguration alloc] initWithMinMultiplier:minMultiplier maxMultiplier:maxMultiplier];
        
        ACRBottomSheetViewController *sheet =  [[ACRBottomSheetViewController alloc] initWithContent:stack
                                                                   configuration:config];
        [host presentViewController:sheet animated:YES completion:nil];
    
}
@end
