//
//  ACRProgressBarRenderer.mm
//  AdaptiveCards
//
//  Created by Harika P on 07/05/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRProgressBarRenderer.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRRegistration.h"
#import "ProgressBar.h"
#import "UtiliOS.h"

@implementation ACRProgressBarRenderer

+ (ACRProgressBarRenderer *)getInstance
{
    static ACRProgressBarRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRProgressBar;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<ProgressBar> progressBar = std::dynamic_pointer_cast<ProgressBar>(elem);
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.layer.masksToBounds = YES;


    switch(progressBar->GetColor())
    {
        case AdaptiveCards::ProgressBarColor::Accent:
            self.progressView.progressTintColor = [UIColor systemBlueColor];
            break;
        case AdaptiveCards::ProgressBarColor::Warning:
            self.progressView.progressTintColor = [UIColor systemOrangeColor];
            break;
        case AdaptiveCards::ProgressBarColor::Good:
            self.progressView.progressTintColor = [UIColor systemGreenColor];
            break;
        case AdaptiveCards::ProgressBarColor::Attention:
            self.progressView.progressTintColor = [UIColor systemRedColor];
            break;
    }
    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:self.progressView withAreaName:areaName];
    std::optional<double> progress = progressBar->GetValue();
    if(progress.has_value())
    {
        self.progressView.progress = static_cast<float>(*progress)/progressBar->GetMax();
    }
    else
    {
        CGFloat pulseWidth = 60;
        CGFloat barHeight = self.progressView.bounds.size.height;
        CGFloat barWidth = self.progressView.bounds.size.width;
        
        self.glowLayer = [CAGradientLayer layer];
        self.glowLayer.frame = CGRectMake(-pulseWidth, 0, pulseWidth, barHeight); // Start off-screen
        self.glowLayer.colors = @[
            (__bridge id)[UIColor clearColor].CGColor,
            (__bridge id)[UIColor systemBlueColor].CGColor,
            (__bridge id)[UIColor clearColor].CGColor
        ];
        self.glowLayer.startPoint = CGPointMake(0, 0.5);
        self.glowLayer.endPoint = CGPointMake(1, 0.5);
        self.glowLayer.locations = @[@0.0, @0.5, @1.0];

        [self.progressView.layer addSublayer:self.glowLayer];

        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        animation.fromValue = @( -pulseWidth / 2 );
        animation.toValue = @( (barWidth + pulseWidth) * 2 );
        animation.duration = 4.0;
        animation.repeatCount = HUGE_VALF;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [self.glowLayer addAnimation:animation forKey:@"glowSlide"];

    }
    return self.progressView;
}

@end
