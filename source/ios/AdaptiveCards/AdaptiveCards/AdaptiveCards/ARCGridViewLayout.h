//
//  ARCGridViewLayout.h
//  AdaptiveCards
//
//  Created by hiteshkumar on 07/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACOVisibilityManager.h"
#import "ACRIContentHoldingView.h"
#import <UIKit/UIKit.h>
#import <AreaGridLayout.h>

@interface ARCGridViewLayout : UIView<ACRIContentHoldingView>

- (instancetype)initWithGridLayout:(std::shared_ptr<AdaptiveCards::AreaGridLayout> const &)gridLayout
                             style:(ACRContainerStyle)style
                       parentStyle:(ACRContainerStyle)parentStyle
                        hostConfig:(ACOHostConfig *)acoConfig
                         superview:(UIView *)superview;

@end
