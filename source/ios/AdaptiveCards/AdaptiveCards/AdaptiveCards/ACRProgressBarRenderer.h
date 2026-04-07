//
//  ACRProgressBarRenderer.h
//  AdaptiveCards
//
//  Created by Harika P on 07/05/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRBaseCardElementRenderer.h"

@interface ACRProgressBarRenderer : ACRBaseCardElementRenderer

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) CAGradientLayer *glowLayer;

+ (ACRProgressBarRenderer *)getInstance;

@end
