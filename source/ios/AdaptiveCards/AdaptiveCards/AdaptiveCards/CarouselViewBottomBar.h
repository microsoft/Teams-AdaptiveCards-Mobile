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

@property (readonly) NSArray<CarouselPageView *> *views;

-(instancetype) initWithViews:(NSArray<CarouselPageView *>*)carouselPageView;
-(void) showPreviousView;
-(void) showNextView;
@end
