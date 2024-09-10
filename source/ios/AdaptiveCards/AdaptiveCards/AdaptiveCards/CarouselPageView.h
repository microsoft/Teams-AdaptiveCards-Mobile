//
//  CarouselPageView.h
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 09/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Carousel.h"
#import "ACOBaseCardElement.h"
#import "CarouselPage.h"
#import "ACRView.h"

@interface CarouselPageView : UIStackView

-(instancetype) initWithViews:(NSArray<UIView *>*)views;
-(instancetype) initWithCarouselPage:(std::shared_ptr<AdaptiveCards::CarouselPage>) carouselPage
                           viewGroup:(UIView<ACRIContentHoldingView> *)viewGroup
                            rootView:(ACRView *)rootView
                              inputs:(NSMutableArray *)inputs
                     baseCardElement:(ACOBaseCardElement *)acoElem
                          hostConfig:(ACOHostConfig *)acoConfig;;
@end
