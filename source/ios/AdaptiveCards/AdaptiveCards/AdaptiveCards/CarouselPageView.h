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
#import "ACRBaseCardElementRenderer.h"

@interface CarouselPageView : NSObject 

-(UIView *) renderWithCarouselPage:(std::shared_ptr<AdaptiveCards::CarouselPage>) carouselPage
                        viewGroup:(UIView<ACRIContentHoldingView> *)viewGroup
                         rootView:(ACRView *)rootView
                           inputs:(NSMutableArray *)inputs
                  baseCardElement:(ACOBaseCardElement *)containerElem
                        hostConfig:(ACOHostConfig *)acoConfig;
@end
