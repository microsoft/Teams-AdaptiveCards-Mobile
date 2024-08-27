//
//  ARCGridViewLayout.h
//  AdaptiveCards
//
//  Created by hiteshkumar on 07/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//
#ifdef SWIFT_PACKAGE
/// Swift Package Imports
#import "AreaGridLayout.h"
#else
/// Cocoapods Imports
#import <AdaptiveCards/AreaGridLayout.h>
#endif
#import "ACOVisibilityManager.h"
#import "ACRIContentHoldingView.h"
#import <UIKit/UIKit.h>

@interface ARCGridViewLayout : UIView<ACRIContentHoldingView>

- (instancetype)initWithGridLayout:(std::shared_ptr<AdaptiveCards::AreaGridLayout> const &)gridLayout
                             style:(ACRContainerStyle)style
                       parentStyle:(ACRContainerStyle)parentStyle
                        hostConfig:(ACOHostConfig *)acoConfig
                         superview:(UIView *)superview;

@end
