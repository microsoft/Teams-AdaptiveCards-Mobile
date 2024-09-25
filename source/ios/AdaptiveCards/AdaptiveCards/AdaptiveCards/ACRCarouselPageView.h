//
//  ACRCarouselPageView.h
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 25/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACOHostConfig.h"
#import "ACRContentStackView.h"
#import "ACRView.h"
#import <UIKit/UIKit.h>

@interface ACRCarouselPageView : NSObject

-(UIView *) render:(UIView<ACRIContentHoldingView> *)viewGroup
                         rootView:(ACRView *)rootView
                           inputs:(NSMutableArray *)inputs
                  baseCardElement:(ACOBaseCardElement *)acoElem
                       hostConfig:(ACOHostConfig *)acoConfig;
@end
