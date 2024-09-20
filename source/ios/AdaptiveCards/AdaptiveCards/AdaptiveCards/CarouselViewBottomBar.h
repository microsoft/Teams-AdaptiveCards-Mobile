//
//  CarouselViewBottomBar.h
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 09/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarouselPageView.h"

@interface CarouselViewBottomBar : UIView

@property (readonly) NSArray<UIView *> *views;

-(instancetype) initWithViews:(NSArray<UIView *>*)carouselPageView;
-(void) showPreviousView;
-(void) showNextView;
@end

