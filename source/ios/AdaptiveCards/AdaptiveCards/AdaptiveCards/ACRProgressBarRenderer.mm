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
#import "SwiftAdaptiveCardObjcBridge.h"

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
    // Check if we should use Swift for rendering
    BOOL useSwiftRendering = [SwiftAdaptiveCardObjcBridge useSwiftForRendering];
    double swiftProgressBarValue = 0.0;
    if (useSwiftRendering) {
        swiftProgressBarValue = [SwiftAdaptiveCardObjcBridge getProgressBarValue:acoElem useSwift:YES];
    }

    return nil;
}

@end
