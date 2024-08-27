//
//  ACRFlowLayout.h
//  AdaptiveCards
//

#ifdef SWIFT_PACKAGE
/// Swift Package Imports
#import "FlowLayout.h"
#else
/// Cocoapods Imports
#import <AdaptiveCards/FlowLayout.h>
#endif

#import <UIKit/UIKit.h>
#import "ACOVisibilityManager.h"
#import "ACRIContentHoldingView.h"
#import "ACRTapGestureRecognizerEventHandler.h"

@interface ACRFlowLayout: UIView<ACRIContentHoldingView>

- (instancetype)initWithFlowLayout:(std::shared_ptr<AdaptiveCards::FlowLayout> const &)flowLayout
                             style:(ACRContainerStyle)style
                       parentStyle:(ACRContainerStyle)parentStyle
                        hostConfig:(ACOHostConfig *)acoConfig
                          maxWidth:(CGFloat)maxWidth
                         superview:(UIView *)superview;

@end

