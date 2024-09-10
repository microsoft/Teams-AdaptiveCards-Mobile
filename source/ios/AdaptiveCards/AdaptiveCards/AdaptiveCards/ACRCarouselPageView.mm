//
//  ACRCarouselPageView.m
//  AdaptiveCards
//
//  Created by Abhishek Gupta on 09/09/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import "CarouselPageView.h"
#import "ACRContainerRenderer.h"
#import "ACRRenderer.h"

@interface CarouselPageView()

@property NSArray<UIView *> *views;

@end

@implementation CarouselPageView

- (instancetype)initWithViews:(NSArray<UIView *> *)views {
    self = [super init];
    self.views = views;
    if(self) {
        self.axis = UILayoutConstraintAxisVertical;
        self.alignment = UIStackViewAlignmentLeading;
    }
    
    for (UIView *view in self.views) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addArrangedSubview:view];
    }
    return self;
}

-(instancetype) initWithCarouselPage:(std::shared_ptr<AdaptiveCards::CarouselPage>) carouselPage
                           viewGroup:(UIView<ACRIContentHoldingView> *)viewGroup
                            rootView:(ACRView *)rootView
                              inputs:(NSMutableArray *)inputs
                     baseCardElement:(ACOBaseCardElement *)acoElem
                          hostConfig:(ACOHostConfig *)acoConfig
{
    self = [super init];
    
    ACRColumnView *container = [[ACRColumnView alloc] initWithFrame:CGRectZero];
    container.rtl = rootView.context.rtl;

    [viewGroup addArrangedSubview:container];
    
    
    container.frame = viewGroup.frame;

    [ACRRenderer render:container
               rootView:rootView
                 inputs:inputs
          withCardElems:carouselPage->GetItems()
          andHostConfig:acoConfig];

    [container setClipsToBounds:NO];


    [container configureLayoutAndVisibility:GetACRVerticalContentAlignment(containerElem->GetVerticalContentAlignment().value_or(VerticalContentAlignment::Top))
                                  minHeight:carouselPage->GetMinHeight()
                                 heightType:GetACRHeight(carouselPage->GetHeight())
                                       type:ACRContainer];

    [rootView.context popBaseCardElementContext:acoElem];

    container.accessibilityElements = [container getArrangedSubviews];

    return self;
}

@end

