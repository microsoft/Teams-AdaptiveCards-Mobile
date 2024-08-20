//
//  ACRFlowLayout.h
//  AdaptiveCards
//

#import <UIKit/UIKit.h>
#import "ACOVisibilityManager.h"
#import "ACRIContentHoldingView.h"
#import "ACRTapGestureRecognizerEventHandler.h"
#import "FlowLayout.h"

@interface ACRFlowLayout: UIView<ACRIContentHoldingView>

- (instancetype)initWithFlowLayout:(std::shared_ptr<AdaptiveCards::FlowLayout> const &)flowLayout
                             style:(ACRContainerStyle)style
                       parentStyle:(ACRContainerStyle)parentStyle
                        hostConfig:(ACOHostConfig *)acoConfig
                          maxWidth:(CGFloat)maxWidth
                         superview:(UIView *)superview;

@end

