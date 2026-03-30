//
//  ACOVisibilityManager.mm
//  AdaptiveCards
//
//  Copyright © 2021 Microsoft. All rights reserved.
//
//

#import "ACOVisibilityManager.h"
#import "ACRColumnView.h"
#import "ACREnums.h"
#import "ACRSeparator.h"

@implementation ACOVisibilityManager {
    /// tracks objects that are used in filling the space
    __weak ACOFillerSpaceManager *_fillerSpaceManager;
    /// tracks visible views
    NSMutableOrderedSet<NSNumber *> *_visibleViews;
}

- (instancetype)init:(ACOFillerSpaceManager *)fillerSpaceManager
{
    self = [super init];
    if (self) {
        _fillerSpaceManager = fillerSpaceManager;
        _visibleViews = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

- (BOOL)hasVisibleViews
{
    return _visibleViews.count > 0;
}

/// adds index of a visible view to a visible views collection, and the index is maintained in sorted order
/// in increasing order.
- (void)addVisibleView:(NSUInteger)index
{
    NSNumber *indexAsNumber = [NSNumber numberWithLong:index];
    if ([_visibleViews containsObject:indexAsNumber]) {
        return;
    }
    NSRange range = NSMakeRange(0, _visibleViews.count);
    NSUInteger insertionIndex = [_visibleViews indexOfObject:indexAsNumber
                                               inSortedRange:range
                                                     options:NSBinarySearchingInsertionIndex
                                             usingComparator:^(id num0, id num1) {
                                                 return [(NSNumber *)num0 compare:(NSNumber *)num1];
                                             }];
    [_visibleViews insertObject:indexAsNumber atIndex:insertionIndex];
}

/// removes the index of view from the visible views collection
/// maintain the sorted order after the removal
- (void)removeVisibleViewAtIndex:(NSUInteger)index
{
    NSNumber *indexAsNumber = [NSNumber numberWithLong:index];
    if (![_visibleViews containsObject:indexAsNumber]) {
        return;
    }
    NSRange range = NSMakeRange(0, _visibleViews.count);
    NSUInteger removalIndex = [_visibleViews indexOfObject:indexAsNumber
                                             inSortedRange:range
                                                   options:NSBinarySearchingInsertionIndex
                                           usingComparator:^(id num0, id num1) {
                                               return [(NSNumber *)num0 compare:(NSNumber *)num1];
                                           }];
    [_visibleViews removeObjectAtIndex:removalIndex];
}

/// YES means the index of view is currently the leading or top view
- (BOOL)amIHead:(NSUInteger)index
{
    NSNumber *indexAsNumber = [NSNumber numberWithLong:index];
    return (_visibleViews.count && [_visibleViews.firstObject isEqual:indexAsNumber]);
}

/// returns the current leading or top view's index
- (NSUInteger)getHeadIndexOfVisibleViews
{
    if (_visibleViews.count) {
        return [_visibleViews.firstObject longValue];
    }

    return NSNotFound;
}

/// change the visibility of the separator of a host view to `visibility`
/// `visibility` `YES` indicates that the separator will be hidden
- (void)changeVisiblityOfSeparator:(UIView *)hostView visibilityHidden:(BOOL)visibility contentStackView:(ACRContentStackView *)contentStackView
{
    ACRSeparator *separtor = [_fillerSpaceManager getSeparatorForOwnerView:hostView];
    if (separtor && (separtor.isHidden != visibility)) {
        separtor.hidden = visibility;
        if (visibility) {
            [contentStackView decreaseIntrinsicContentSize:separtor];
        } else {
            [contentStackView increaseIntrinsicContentSize:separtor];
        }
    }
}

/// change the visibility of the padding of a host view to `visibility`
/// `visibility` `YES` indicates that the padding will be hidden
- (void)changeVisibilityOfPadding:(UIView *)hostView visibilityHidden:(BOOL)visibility
{
    for (NSValue *value in [_fillerSpaceManager getFillerSpaceView:hostView]) {
        UIView *padding = value.nonretainedObjectValue;
        if (padding.isHidden != visibility) {
            padding.hidden = visibility;
        }
    }
}

/// change the visibility of the padding(s) and separator of a host view to `visibility`
/// `visibility` `YES` indicates that the padding will be hidden
- (void)changeVisiblityOfAssociatedViews:(UIView *)hostView
                         visibilityValue:(BOOL)visibility
                        contentStackView:(ACRContentStackView *)contentStackView
{
    if (!hostView) {
        return;
    }

    [self changeVisibilityOfPadding:hostView visibilityHidden:visibility];
    [self changeVisiblityOfSeparator:hostView visibilityHidden:visibility contentStackView:contentStackView];
}

/// hide `viewToBeHidden`. `hostView` is a superview of type ColumnView or ColumnSetView
- (void)hideView:(UIView *)viewToBeHidden hostView:(ACRContentStackView *)hostView
{
    if (!hostView || !hostView.subviews || !viewToBeHidden || !_fillerSpaceManager) {
        return;
    }

    NSArray<UIView *> *subviews = [hostView getContentStackSubviews];
    if (!subviews) {
        return;
    }

    NSUInteger index = [subviews indexOfObject:viewToBeHidden];
    if (index == NSNotFound) {
        return;
    }

    BOOL isHead = [self amIHead:index];
    [self removeVisibleViewAtIndex:index];

    // setting hidden view to hidden again is a programming error
    // as it requires to have equal or more times of the opposite value to be set
    // in order to reverse it
    if (!viewToBeHidden.isHidden) {
        viewToBeHidden.hidden = YES;
        // decrease the intrinsic content size by the intrinsic content size of
        // `viewToBeHidden` otherwise, viewTobeHidden's size will be included
        [hostView decreaseIntrinsicContentSize:viewToBeHidden];
        [self changeVisiblityOfAssociatedViews:viewToBeHidden visibilityValue:YES contentStackView:hostView];
    }

    // if `viewToBeHidden` is a head, get new head if any, and hide its separator
    if (isHead) {
        NSUInteger headIndex = [self getHeadIndexOfVisibleViews];
        if (headIndex != NSNotFound && headIndex < subviews.count) {
            UIView *head = subviews[headIndex];
            [self changeVisiblityOfSeparator:head visibilityHidden:YES contentStackView:hostView];
        }
    }
}

/// Remove stale zero-width constraints that were set when this view was initially
/// hidden (isVisible: false). These prevent the view from getting proper layout
/// space in the UIStackView after toggle visibility unhides it.
- (void)removeStaleZeroWidthConstraints:(UIView *)viewToBeUnhidden
                               hostView:(ACRContentStackView *)hostView
                               subviews:(NSArray<UIView *> *)subviews
{
    if (!viewToBeUnhidden) {
        return;
    }
    NSMutableArray *staleConstraints = [NSMutableArray array];
    for (NSLayoutConstraint *c in viewToBeUnhidden.constraints) {
        if (c.firstAttribute == NSLayoutAttributeWidth &&
            c.secondItem == nil &&
            c.constant < 1.0) {
            [staleConstraints addObject:c];
        }
    }
    for (NSLayoutConstraint *c in staleConstraints) {
        [viewToBeUnhidden removeConstraint:c];
    }

    // If stale constraints were removed, copy the width from a visible sibling
    // that is about to hide (they're swapping visibility). This ensures the
    // newly-visible column gets the full available width.
    if (staleConstraints.count > 0 && hostView) {
        for (UIView *sibling in subviews) {
            if (sibling != viewToBeUnhidden &&
                !sibling.isHidden &&
                sibling.frame.size.width > 10 &&
                [sibling isKindOfClass:[viewToBeUnhidden class]]) {
                CGFloat siblingWidth = sibling.frame.size.width;
                NSLayoutConstraint *widthC = [NSLayoutConstraint
                    constraintWithItem:viewToBeUnhidden
                    attribute:NSLayoutAttributeWidth
                    relatedBy:NSLayoutRelationEqual
                    toItem:nil
                    attribute:NSLayoutAttributeNotAnAttribute
                    multiplier:1.0
                    constant:siblingWidth];
                widthC.priority = UILayoutPriorityRequired - 1; // 999
                [viewToBeUnhidden addConstraint:widthC];
                break;
            }
        }
    }
}

/// unhide `viewToBeUnhidden`. `hostView` is a superview of type ColumnView or ColumnSetView
- (void)unhideView:(UIView *)viewToBeUnhidden hostView:(ACRContentStackView *)hostView
{
    if (!hostView || !viewToBeUnhidden || !_fillerSpaceManager) {
        return;
    }

    NSArray<UIView *> *subviews = [hostView getContentStackSubviews];
    if (!subviews) {
        return;
    }

    NSUInteger index = [subviews indexOfObject:viewToBeUnhidden];
    if (index == NSNotFound) {
        return;
    }

    NSUInteger headIndex = [self getHeadIndexOfVisibleViews];
    [self addVisibleView:index];
    // check if the unhidden view will become a head
    if ([self amIHead:index]) {
        // only enable filler view associated with the `viewTobeUnhidden`
        [self changeVisibilityOfPadding:viewToBeUnhidden visibilityHidden:NO];
        if (viewToBeUnhidden.isHidden) {
            [self removeStaleZeroWidthConstraints:viewToBeUnhidden hostView:hostView subviews:subviews];
            viewToBeUnhidden.hidden = NO;
            [hostView increaseIntrinsicContentSize:viewToBeUnhidden];
        }

        // previous head view's separator becomes visible
        if (headIndex != NSNotFound && headIndex < subviews.count) {
            UIView *prevHeadView = subviews[headIndex];
            [self changeVisiblityOfSeparator:prevHeadView visibilityHidden:NO contentStackView:hostView];
        }
    } else {
        if (viewToBeUnhidden.isHidden) {
            [self removeStaleZeroWidthConstraints:viewToBeUnhidden hostView:hostView subviews:subviews];
            viewToBeUnhidden.hidden = NO;
            [hostView increaseIntrinsicContentSize:viewToBeUnhidden];
        }
        [self changeVisiblityOfAssociatedViews:viewToBeUnhidden visibilityValue:NO contentStackView:hostView];
    }
}

- (void)updatePaddingVisibility
{
    [_fillerSpaceManager deactivateConstraintsForPadding];
    [_fillerSpaceManager activateConstraintsForPadding];
}
@end
