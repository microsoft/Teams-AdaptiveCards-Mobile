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

static const NSString *Accent = @"Accent";
static const NSString *Good = @"Good";
static const NSString *Warning = @"Warning";
static const NSString *Attention = @"Attention";

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
    
    // Set colors for light theme - default values
    NSDictionary *colors = @{
        Accent: @"#0F6CBD",
        Good: @"#107C10",
        Warning: @"#835B00",
        Attention: @"#C50F1F"
    };
    
    // In case of dark theme use these colors
    if (UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
        colors = @{
            Accent: @"#2886DE",
            Good: @"#10893C",
            Warning: @"#EAA300",
            Attention: @"#B83746"
        };
    }
    NSString *progressColor = @"";
    switch(progressBar->GetColor())
    {
        case AdaptiveCards::ProgressBarColor::Accent:
            progressColor = [colors objectForKey:Accent];
            break;
        case AdaptiveCards::ProgressBarColor::Warning:
            progressColor = [colors objectForKey:Warning];
            break;
        case AdaptiveCards::ProgressBarColor::Good:
            progressColor = [colors objectForKey:Good];
            break;
        case AdaptiveCards::ProgressBarColor::Attention:
            progressColor = [colors objectForKey:Attention];
            break;
    }
    std::string color([progressColor UTF8String]);
    self.progressView.progressTintColor = [ACOHostConfig convertHexColorCodeToUIColor:color];
    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:self.progressView withAreaName:areaName];
    std::optional<double> progress = progressBar->GetValue();
    if(progress.has_value())
    {
        self.progressView.progress = static_cast<float>(*progress)/progressBar->GetMax();
    }
    else
    {
        std::string color([[colors objectForKey:Accent] UTF8String]);
        CGFloat pulseWidth = 60;
        CGFloat barHeight = self.progressView.bounds.size.height;
        CGFloat barWidth = self.progressView.bounds.size.width;
        
        self.glowLayer = [CAGradientLayer layer];
        self.glowLayer.frame = CGRectMake(-pulseWidth, 0, pulseWidth, barHeight);
        self.glowLayer.colors = @[
            (__bridge id)[UIColor clearColor].CGColor,
            (__bridge id)[ACOHostConfig convertHexColorCodeToUIColor:color].CGColor,
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
        [self.glowLayer addAnimation:animation forKey:@"glowSlide"];

    }
    return self.progressView;
}

@end
