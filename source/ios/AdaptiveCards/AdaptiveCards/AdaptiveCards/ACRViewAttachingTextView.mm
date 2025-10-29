//
//  ACRViewAttachingTextView.mm
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 24/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRViewAttachingTextView.h"
#import "ACRViewAttachingTextViewBehavior.h"

@interface ACRViewAttachingTextView ()
@property (nonatomic, strong) ACRViewAttachingTextViewBehavior *attachmentBehavior;
@end

@implementation ACRViewAttachingTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // Connect the attachment behavior
    self.attachmentBehavior = [[ACRViewAttachingTextViewBehavior alloc] init];
    self.attachmentBehavior.textView = self;
    self.layoutManager.delegate = self.attachmentBehavior;
    self.textStorage.delegate = self.attachmentBehavior;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    
    // Text container insets are used to convert coordinates between the text container and text view,
    // so a change to these insets must trigger a layout update
    [self.attachmentBehavior layoutAttachedSubviews];
}

#pragma mark - Touch Event Forwarding

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // First check if any attached subview should handle the touch
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            CGPoint subviewPoint = [self convertPoint:point toView:subview];
            if ([subview pointInside:subviewPoint withEvent:event]) {
                return [subview hitTest:subviewPoint withEvent:event];
            }
        }
    }
    
    // Fall back to default behavior
    return nil;
}

@end
