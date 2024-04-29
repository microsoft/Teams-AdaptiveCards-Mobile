//
//  ACRActionExecuteRenderer
//  ACRActionExecuteRenderer.mm
//
//  Copyright © 2021 Microsoft. All rights reserved.
//

#import "ACRActionExecuteRenderer.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRAggregateTarget.h"
#import "ACRBaseActionElementRenderer.h"
#import "ACRButton.h"
#import "ExecuteAction.h"
#import "UtiliOS.h"
#import "ACRInputLabelView.h"

@implementation ACRActionExecuteRenderer
NSMutableArray<ACRIBaseInputHandler> *_inputsArray;
NSHashTable<UIButton *> * executeButtons = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];

+ (ACRActionExecuteRenderer *)getInstance
{
    static ACRActionExecuteRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

- (UIButton *)renderButton:(ACRView *)view
                    inputs:(NSArray *)inputs
                 superview:(UIView<ACRIContentHoldingView> *)superview
         baseActionElement:(ACOBaseActionElement *)acoElem
                hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<BaseActionElement> elem = [acoElem element];
    std::shared_ptr<ExecuteAction> action = std::dynamic_pointer_cast<ExecuteAction>(elem);

    NSString *title = [NSString stringWithCString:action->GetTitle().c_str() encoding:NSUTF8StringEncoding];

    UIButton *button = [ACRButton rootView:view baseActionElement:acoElem title:title andHostConfig:acoConfig];
    
    if(action->m_conditionallyEnabled && button.isEnabled)
    {
        _inputsArray = [[NSMutableArray<ACRIBaseInputHandler> alloc] initWithArray:inputs];
        BOOL atleastOneInputRequired = false;
        for (id<ACRIBaseInputHandler> input in _inputsArray) {
            if (input.isRequired) {
                atleastOneInputRequired = true;
                [input addObserverForValueChange:self];
            }
        }
        // update button enable state only if alteast one input is required
        if(atleastOneInputRequired) {
            [executeButtons addObject:button];
            [button setEnabled:[self validateInputs]];
        }
    }

    ACRAggregateTarget *target;
    if (ACRRenderingStatus::ACROk == buildTargetForButton([view getActionsTargetBuilderDirector], acoElem, button, &target)) {
        [superview addTarget:target];
    }

    [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    return button;
}

- (BOOL)validateInputs {
    BOOL validationResult = false;
    for (id<ACRIBaseInputHandler> input in _inputsArray) {
        if(input.isRequired && !validationResult)
        {
            ACRInputLabelView *labelView = (ACRInputLabelView *)input;
            if (labelView) {
                validationResult |= [labelView.getInputHandler validate:nil];
            } else {
                validationResult |= [input validate:nil];
            }
        }
    }
    return  validationResult;
}

- (void)inputValueChanged {
    for (UIButton *button in executeButtons)
    {
        [button setEnabled:[self validateInputs]];
    }
}
@end
