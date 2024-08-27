//
//  ACRFlowLayout.h
//  AdaptiveCards
//

#ifdef SWIFT_PACKAGE
/// Swift Package Imports
#import "FlowLayout.h"
#import "ACRIContentHoldingView.h"
#else
/// Cocoapods Imports
#import <AdaptiveCards/FlowLayout.h>
#import <AdaptiveCards/ACRIContentHoldingView.h>
#endif

@interface ACRFlowLayout: UIView<ACRIContentHoldingView>

- (instancetype)initWithFlowLayout:(std::shared_ptr<AdaptiveCards::FlowLayout> const &)flowLayout
                             style:(ACRContainerStyle)style
                       parentStyle:(ACRContainerStyle)parentStyle
                        hostConfig:(ACOHostConfig *)acoConfig
                          maxWidth:(CGFloat)maxWidth
                         superview:(UIView *)superview;

@end

