//
//  ACRPopoverPresenter.h
//  AdaptiveCards
//
//  Created by Jitisha Azad on 17/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdaptiveCards/AdaptiveCards.h>
#import "ACRView.h"
#import <UIKit/UIViewController.h>

@interface ACRPopoverPresenter : NSObject

+ (void)presentSheetForAction:(ACOBaseActionElement *)action
                         card:(ACOAdaptiveCard *)card
                         view:(ACRView *)rootView;

@end
