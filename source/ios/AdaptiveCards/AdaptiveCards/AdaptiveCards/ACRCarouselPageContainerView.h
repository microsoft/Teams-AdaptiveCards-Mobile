//
//  ACRCarouselPageContainerView.h
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 25/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "ACOHostConfig.h"
#import "ACRContentStackView.h"
#import "ACRView.h"
#import <UIKit/UIKit.h>

@interface ACRCarouselPageContainerView : UIView

-(instancetype) initWithCarouselPageViewList:(NSMutableArray<UIView *> *)initWithCarouselPageViewList;

@end
