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
@property (nonatomic, weak) ACRView *rootView;
@property (nonatomic, strong) ACRContentStackView *cachedContentView;

- (instancetype)initWithActionElement:(ACOBaseActionElement *)actionElement rootView:(ACRView *)rootView;

- (void)dismissBottomSheet;

- (void)detachBottomSheetInputsFromMainCard;

@end
