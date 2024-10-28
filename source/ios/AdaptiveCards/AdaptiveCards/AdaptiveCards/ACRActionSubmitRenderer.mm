//
//  ACRActionSubmitRenderer
//  ACRActionSubmitRenderer.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRActionSubmitRenderer.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRAggregateTarget.h"
#import "ACRBaseActionElementRenderer.h"
#import "ACRButton.h"
#import "SubmitAction.h"
#import "UtiliOS.h"
#import "ACRInputLabelView.h"

@implementation ACRActionSubmitRenderer
NSMutableArray<ACRIBaseInputHandler> *_inputs;

+ (ACRActionSubmitRenderer *)getInstance
{
    static ACRActionSubmitRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

- (UIButton *)renderButton:(ACRView *)view
                    inputs:(NSArray *)inputs
                 superview:(UIView<ACRIContentHoldingView> *)superview
         baseActionElement:(ACOBaseActionElement *)acoElem
                hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<BaseActionElement> elem = [acoElem element];
    std::shared_ptr<SubmitAction> action = std::dynamic_pointer_cast<SubmitAction>(elem);
    NSString *title = [NSString stringWithCString:action->GetTitle().c_str() encoding:NSUTF8StringEncoding];
    UIButton *button = [ACRButton rootView:view baseActionElement:acoElem title:title andHostConfig:acoConfig];
    __weak __typeof(self) weakSelf = self;
    
    if(action->m_conditionallyEnabled && button.isEnabled)
    {
        _inputs = [[NSMutableArray<ACRIBaseInputHandler> alloc] initWithArray:inputs];
        BOOL atleastOneInputRequired = NO;
        for (id<ACRIBaseInputHandler> input in _inputs)
        {
            if (input.isRequired) 
            {
                atleastOneInputRequired = YES;
                [input addObserverWithCompletion:^{
                    __strong __typeof(self) strongSelf = weakSelf;
                    [button setEnabled:[strongSelf validateInputs]];
                }];
            }
        }
        // update button enable state only if alteast one input is required
        if(atleastOneInputRequired) 
        {
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

- (BOOL)validateInputs 
{
    BOOL validationResult = NO;
    for (id<ACRIBaseInputHandler> input in _inputs) {
        if(input.isRequired && !validationResult)
        {
            ACRInputLabelView *labelView = (ACRInputLabelView *)input;
            if (labelView) {
                validationResult |= [labelView.getInputHandler validate:nil];
            } else 
            {
                validationResult |= [input validate:nil];
            }
        }
    }
    return  validationResult;
}
@end

