//
//  ACRCustomActionRenderer
//  ACRCustomActionRenderer.mm
//
//  Copyright © 2019 Microsoft. All rights reserved.
//

#import "ACRCustomActionRenderer.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRContentHoldingUIView.h"
#import "ACRRegistration.h"
#import "SharedAdaptiveCard.h"
#import "UnknownAction.h"
#import "UtiliOS.h"
#import "SwiftAdaptiveCardObjcBridge.h"

// this is an entry point to custom parsing and rendering
// it will call a registered custom parser to deserialize, then the deserialized object is rendered by calling
// the appropriate custom renderer
@implementation ACRCustomActionRenderer

+ (ACRCustomActionRenderer *)getInstance
{
    static ACRCustomActionRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRActionType)elemType
{
    return ACRUnknownAction;
}

- (UIButton *)renderButton:(ACRView *)view
                    inputs:(NSMutableArray *)inputs
                 superview:(UIView<ACRIContentHoldingView> *)superview
         baseActionElement:(ACOBaseActionElement *)acoElem
                hostConfig:(ACOHostConfig *)acoConfig
{
    // Check if we should use Swift for rendering
    BOOL useSwiftRendering = [SwiftAdaptiveCardObjcBridge useSwiftForRendering];

    std::shared_ptr<UnknownAction> unknownAction = std::dynamic_pointer_cast<UnknownAction>([acoElem element]);
    // we get back a deserialized action object by calling a custom parser registered via host
    ACOBaseActionElement *customAction = deserializeUnknownActionToCustomAction(unknownAction);
    if (customAction) {
        ACRRegistration *reg = [ACRRegistration getInstance];

        // Get type string - use Swift bridge when available, otherwise fallback to C++
        NSString *type;
        if (useSwiftRendering) {
            type = [SwiftAdaptiveCardObjcBridge getUnknownActionTypeString:acoElem useSwift:YES];
            if (type.length == 0) {
                // Fallback to C++ if Swift returns empty (element may not be Swift-parsed)
                type = [NSString stringWithCString:unknownAction->GetElementTypeString().c_str() encoding:NSUTF8StringEncoding];
            }
        } else {
            type = [NSString stringWithCString:unknownAction->GetElementTypeString().c_str() encoding:NSUTF8StringEncoding];
        }

        ACRBaseActionElementRenderer *renderer = [reg getActionRenderer:[NSNumber numberWithLong:type.hash]];

        if (renderer) {
            // render a button by calling custom renderer
            return [renderer renderButton:view inputs:inputs superview:superview baseActionElement:customAction hostConfig:acoConfig];
        }
    }
    return nil;
}

@end
