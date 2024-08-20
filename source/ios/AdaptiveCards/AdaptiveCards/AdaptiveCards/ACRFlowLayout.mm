//
//  ACRFlowLayout.m
//  AdaptiveCards
//
//  Created by Abhishek on 16/08/24.
//  Copyright © 2024 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRFlowLayout.h"
#import "ACOBaseCardElementPrivate.h"
#include "ACOHostConfigPrivate.h"
#import "ACRShowCardTarget.h"
#import "ACRViewPrivate.h"
#import "UtiliOS.h"

using namespace AdaptiveCards;

@implementation ACRFlowLayout {
    NSMutableArray *_targets;
    NSMutableArray<ACRShowCardTarget *> *_showcardTargets;
    ACRContainerStyle _style;
    NSMutableDictionary<NSString *, NSValue *> *_subviewIntrinsicContentSizeCollection;
    ACRVerticalContentAlignment _verticalContentAlignment;
    ACRHorizontalAlignment _horizontalAlignment;
    UIStackView *_verticalStack;
    UIStackView *_horizontalStack;
    CGFloat _remainingRowSpace;
    CGFloat _availableRowSpace;
    std::shared_ptr<FlowLayout> _layout;
}

- (instancetype)initWithFlowLayout:(std::shared_ptr<AdaptiveCards::FlowLayout> const &)flowLayout
                             style:(ACRContainerStyle)style
                       parentStyle:(ACRContainerStyle)parentStyle
                        hostConfig:(ACOHostConfig *)acoConfig
                          maxWidth:(CGFloat)maxWidth
                         superview:(UIView *)superview

{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    self = [self initWithFrame:superview.frame attributes:nil];
    if (self) {
        _style = style;
        _layout = flowLayout;
        _availableRowSpace = maxWidth;
        _remainingRowSpace = _availableRowSpace;
        if (style != ACRNone &&
            style != parentStyle) {
            self.backgroundColor = [acoConfig getBackgroundColorForContainerStyle:_style];
            [self setBorderColorWithHostConfig:config];
        }
        [self setUpGrid];
    }
    return self;
}

- (instancetype)initWithStyle:(ACRContainerStyle)style
                  parentStyle:(ACRContainerStyle)parentStyle
                   hostConfig:(ACOHostConfig *)acoConfig
                    superview:(UIView *)superview
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    self = [self initWithFrame:superview.frame attributes:nil];
    if (self) {
        _style = style;
        if (style != ACRNone &&
            style != parentStyle) {
            self.backgroundColor = [acoConfig getBackgroundColorForContainerStyle:_style];
            [self setBorderColorWithHostConfig:config];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame attributes:(nullable NSDictionary<NSString *, id> *)attributes
{
     return [super initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (void)setUpGrid
{
    _verticalStack = [self createVerticalStack];
    [self addNewRowWithView:nil];
    NSLayoutConstraint *selfWidth = [self.widthAnchor constraintEqualToConstant:_availableRowSpace];
    selfWidth.priority = 999;
    [NSLayoutConstraint activateConstraints:@[selfWidth]];
}

- (void)addNewRowWithView:(UIView *)view
{
    _horizontalStack = [self createHorizontalStack];
    [_verticalStack addArrangedSubview:_horizontalStack];
    if(view)
    {
        [_horizontalStack addArrangedSubview:view];
    }
}

- (void)addViewInCurrentRow:(UIView *)view
{
    [_horizontalStack addArrangedSubview:view];
}


- (UIStackView *)createHorizontalStack
{
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentFill; // TODO: Fill this actual fill
    stackView.distribution = UIStackViewDistributionFillEqually; // TODO: Fill this actual distribution
    stackView.spacing = 10; // TODO: Fill this actual row spacing
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    return stackView;
}

- (UIStackView *)createVerticalStack
{
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.spacing = 10; // TODO: Fill this actual column spacing
    
    [self addSubview:stackView];
    
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0],
        [stackView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0]]];
    
    return stackView;
}

- (void)setBorderColorWithHostConfig:(std::shared_ptr<HostConfig> const &)config
{
    auto borderColor = config->GetBorderColor([ACOHostConfig getSharedContainerStyle:_style]);
    UIColor *color = [ACOHostConfig convertHexColorCodeToUIColor:borderColor];

    [[self layer] setBorderColor:[color CGColor]];
}

- (CGFloat)sizeForView:(UIView *)view
{
    CGFloat widthForItem = view.intrinsicContentSize.width;
    
    if (_layout->GetItemPixelWidth() != -1)
    {
        widthForItem = _layout->GetItemPixelWidth();
    }
    CGFloat maxItemWidth = _layout->GetMaxItemPixelWidth();
    if (maxItemWidth != -1 && widthForItem > maxItemWidth)
    {
        widthForItem = maxItemWidth;
    }
    
    CGFloat minItemWidth = _layout->GetMinItemPixelWidth();
    if (minItemWidth != -1 && widthForItem < minItemWidth)
    {
        widthForItem = minItemWidth;
    }
    
    return widthForItem;
}

- (void)addArrangedSubview:(UIView *)view
{
    CGFloat sizeForView = [self sizeForView:view];
    CGFloat rowSpacing = 10;
    if (_remainingRowSpace > (sizeForView + rowSpacing))
    {
        [self addViewInCurrentRow:view];
        _remainingRowSpace -= (sizeForView + rowSpacing);
    }
    else
    {
        [self addNewRowWithView:view];
        _remainingRowSpace = _availableRowSpace - (sizeForView + rowSpacing);
    }
}

- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)insertionIndex
{
    
}

- (void)removeLastViewFromArrangedSubview
{
    
}

- (void)removeAllArrangedSubviews
{
    
}

- (void)addTarget:(NSObject *)target
{
    
}
- (void)configureForSelectAction:(ACOBaseActionElement *)action rootView:(ACRView *)rootView
{
    
}

- (void)adjustHuggingForLastElement
{
    
}

- (ACRContainerStyle)style
{
    return _style;
}

- (void)setStyle:(ACRContainerStyle)stye
{
    
}

- (void)hideAllShowCards
{
    
}

- (NSUInteger)subviewsCounts
{
    return 10;
}

- (NSUInteger)arrangedSubviewsCounts
{
    return 10;
}

- (UIView *)getLastSubview
{
    return  self;
}

- (void)updateLayoutAndVisibilityOfRenderedView:(UIView *)renderedView
                                     acoElement:(ACOBaseCardElement *)acoElem
                                      separator:(ACRSeparator *)separator
                                       rootView:(ACRView *)rootView
{
    
}

- (UIView *)addPaddingFor:(UIView *)view
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)decreaseIntrinsicContentSize:(UIView *)view
{
    
}

- (void)increaseIntrinsicContentSize:(UIView *)view
{
    
}


@end
