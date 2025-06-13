//
//  ACRActionPopoverRenderer.mm
//  AdaptiveCards
//
//  Created by Jitisha Azad on 12/06/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//
#import "ACRActionPopoverRenderer.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRAggregateTarget.h"
#import "ACRBaseActionElementRenderer.h"
#import "ACRButton.h"
#import "ACRIContentHoldingView.h"
#import "PopoverAction.h"
#import "UtiliOS.h"


@implementation ACRActionPopoverRenderer

+ (ACRActionPopoverRenderer *)getInstance
{
    static ACRActionPopoverRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

- (UIButton *)render_Button:(ACRView *)rootView
                    inputs:(NSMutableArray *)inputs
                 superview:(UIView<ACRIContentHoldingView> *)superview
         baseActionElement:(ACOBaseActionElement *)acoElem
                hostConfig:(ACOHostConfig *)acoConfig
{
    UIButton *containingView =[[UIButton  alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    containingView.backgroundColor = UIColor.redColor;
    [containingView setTitle:@"Popover" forState:UIControlStateNormal];
    return containingView;
                                           
}
- (UIButton *)renderButton:(ACRView *)rootView
                    inputs:(NSMutableArray *)inputs
                 superview:(UIView<ACRIContentHoldingView> *)superview
         baseActionElement:(ACOBaseActionElement *)acoElem
                hostConfig:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<BaseActionElement> elem = [acoElem element];
    std::shared_ptr<PopoverAction> action = std::dynamic_pointer_cast<PopoverAction>(elem);
    
    NSString *title = [NSString stringWithCString:action->GetTitle().c_str() encoding:NSUTF8StringEncoding];

    UIButton *button = [ACRButton rootView:rootView baseActionElement:acoElem title:title andHostConfig:acoConfig];
    
    ACRAggregateTarget *target;
    if (ACRRenderingStatus::ACROk == buildTargetForButton([rootView getActionsTargetBuilderDirector], acoElem, button, &target)) {
        [superview addTarget:target];
    }

    button.accessibilityTraits |= UIAccessibilityTraitLink;
    button.accessibilityTraits &= ~UIAccessibilityTraitButton;

    [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [button setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    return button;
}

@end
