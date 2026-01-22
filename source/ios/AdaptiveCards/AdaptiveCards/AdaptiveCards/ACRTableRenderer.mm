//
//  ACRTableRenderer
//  ACRTableRenderer.mm
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "ACRTableRenderer.h"
#import "ACRTableView.h"
#import "SwiftAdaptiveCardObjcBridge.h"

@implementation ACRTableRenderer

+ (ACRTableRenderer *)getInstance
{
    static ACRTableRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRTable;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
           rootView:(ACRView *)rootView
             inputs:(NSMutableArray *)inputs
    baseCardElement:(ACOBaseCardElement *)acoElem
         hostConfig:(ACOHostConfig *)acoConfig
{
    // Check if we should use Swift for rendering
    BOOL useSwiftRendering = [SwiftAdaptiveCardObjcBridge useSwiftForRendering];
    NSArray *swiftTableColumns = nil;
    NSArray *swiftTableRows = nil;
    BOOL swiftShowGridLines = NO;
    if (useSwiftRendering) {
        swiftTableColumns = [SwiftAdaptiveCardObjcBridge getTableColumns:acoElem useSwift:YES];
        swiftTableRows = [SwiftAdaptiveCardObjcBridge getTableRows:acoElem useSwift:YES];
        swiftShowGridLines = [SwiftAdaptiveCardObjcBridge getTableShowGridLines:acoElem useSwift:YES];
    }

    [rootView.context pushBaseCardElementContext:acoElem];
    ACRTableView *tableView = [[ACRTableView alloc] init:acoElem
                                               viewGroup:viewGroup
                                                rootView:rootView
                                                  inputs:inputs
                                              hostConfig:acoConfig];
    [rootView.context popBaseCardElementContext:acoElem];

    return tableView;
}

@end
