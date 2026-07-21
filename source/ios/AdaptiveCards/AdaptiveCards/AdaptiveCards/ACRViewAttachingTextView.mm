//
//  ACRViewAttachingTextView.mm
//  AdaptiveCards
//
//  Created by Gaurav Keshre on 24/10/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "ACRViewAttachingTextView.h"
#import "ACRViewAttachingTextViewBehavior.h"
#import "ACRViewAttachingTextViewBehavior.h"
#import "ACRViewTextAttachment.h"

@interface ACRViewAttachingTextView ()
@property (nonatomic, strong) ACRViewAttachingTextViewBehavior *attachmentBehavior;
@property (nonatomic, strong, nullable) NSArray *acrCachedAccessibilityElements;
@property (nonatomic, assign) BOOL acrAccessibilityNeedsRebuild;
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    id attribute = [self attribute:NSAttachmentAttributeName atPoint:point withEvent:event];
    if (attribute && [attribute isKindOfClass:ACRViewTextAttachment.class]) {
        ACRViewTextAttachment *attachmentAttr = (ACRViewTextAttachment *)attribute;
        return [attachmentAttr.viewProvider instantiateViewForAttachment:attachmentAttr inBehavior:self.attachmentBehavior];
    }
    if ([self attribute:NSLinkAttributeName atPoint:point withEvent:event] != nil) {
        return self;
    }
    return nil;
}

- (void)commonInit {
    // Connect the attachment behavior
    self.attachmentBehavior = [[ACRViewAttachingTextViewBehavior alloc] init];
    self.attachmentBehavior.textView = self;
    self.layoutManager.delegate = self.attachmentBehavior;
    self.textStorage.delegate = self.attachmentBehavior;

    // When embedded citation views are added/removed or repositioned, the accessibility
    // container must rebuild so VoiceOver / Full Keyboard Access / Voice Control can reach them.
    __weak __typeof(self) weakSelf = self;
    self.attachmentBehavior.attachmentsDidChangeHandler = ^{
        [weakSelf acr_setNeedsAccessibilityElementsRebuild];
    };
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    
    // Text container insets are used to convert coordinates between the text container and text view,
    // so a change to these insets must trigger a layout update
    [self.attachmentBehavior layoutAttachedSubviews];
}

#pragma mark - Accessibility container for embedded citation views

// When the text view embeds interactive citation views (ACRViewTextAttachment), UIKit would otherwise
// present the whole text view as a single accessibility leaf (ACRUILabel sets isAccessibilityElement = YES),
// hiding the embedded buttons from VoiceOver, Full Keyboard Access, and Voice Control "Show Numbers".
// When attachments are present we act as an accessibility container that vends, in reading order, virtual
// static-text elements for the surrounding text interleaved with the real citation subviews. When no
// attachments are present, behavior is unchanged (defers to ACRUILabel's single-element path).

- (BOOL)acr_hasEmbeddedAttachments {
    return [self.attachmentBehavior orderedAttachments].count > 0;
}

- (void)acr_setNeedsAccessibilityElementsRebuild {
    self.acrAccessibilityNeedsRebuild = YES;
    self.acrCachedAccessibilityElements = nil;
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (BOOL)isAccessibilityElement {
    if ([self acr_hasEmbeddedAttachments]) {
        return NO;
    }
    return [super isAccessibilityElement];
}

- (nullable NSArray *)accessibilityElements {
    if (![self acr_hasEmbeddedAttachments]) {
        return [super accessibilityElements];
    }
    if (self.acrAccessibilityNeedsRebuild || self.acrCachedAccessibilityElements == nil) {
        self.acrCachedAccessibilityElements = [self acr_buildAccessibilityElements];
        self.acrAccessibilityNeedsRebuild = NO;
    }
    return self.acrCachedAccessibilityElements;
}

- (NSArray *)acr_buildAccessibilityElements {
    NSArray<NSDictionary *> *attachments = [self.attachmentBehavior orderedAttachments];
    if (attachments.count == 0) {
        return @[];
    }

    NSAttributedString *attributed = self.textStorage;
    NSUInteger length = attributed.length;
    NSMutableArray *elements = [NSMutableArray array];
    NSUInteger cursor = 0;
    BOOL isHeader = (self.accessibilityTraits & UIAccessibilityTraitHeader) != 0;

    for (NSDictionary *entry in attachments) {
        UIView *view = entry[@"view"];
        NSRange attachmentRange = [entry[@"range"] rangeValue];

        // Emit the text that precedes this citation.
        if (attachmentRange.location > cursor) {
            NSRange textRange = NSMakeRange(cursor, attachmentRange.location - cursor);
            [self acr_appendTextElementsForRange:textRange isHeader:isHeader into:elements];
        }

        // Emit the citation view itself with explicit link semantics.
        [self acr_configureCitationView:view];
        [elements addObject:view];

        cursor = NSMaxRange(attachmentRange);
    }

    // Emit any trailing text after the last citation.
    if (cursor < length) {
        [self acr_appendTextElementsForRange:NSMakeRange(cursor, length - cursor) isHeader:isHeader into:elements];
    }

    return [elements copy];
}

- (void)acr_appendTextElementsForRange:(NSRange)range isHeader:(BOOL)isHeader into:(NSMutableArray *)elements {
    NSAttributedString *attributed = self.textStorage;
    if (range.length == 0 || NSMaxRange(range) > attributed.length) {
        return;
    }

    // Split the run on link boundaries so links keep their own element + activation routing.
    [attributed enumerateAttribute:NSLinkAttributeName
                           inRange:range
                           options:0
                        usingBlock:^(id linkValue, NSRange subRange, BOOL *stop) {
        NSString *raw = [attributed attributedSubstringFromRange:subRange].string;
        NSString *trimmed = [raw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmed.length == 0) {
            return;
        }

        CGRect frame = [self acr_boundingRectForCharacterRange:subRange];
        if (CGRectIsEmpty(frame)) {
            return; // range not laid out (clipped / truncated) — do not vend an offscreen element
        }

        UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        element.accessibilityLabel = raw;
        element.accessibilityFrameInContainerSpace = frame;

        UIAccessibilityTraits traits = UIAccessibilityTraitStaticText;
        if (linkValue != nil) {
            traits = UIAccessibilityTraitLink;
            CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
            element.accessibilityActivationPoint = [self convertPoint:center toView:nil];
        }
        if (isHeader) {
            traits |= UIAccessibilityTraitHeader;
        }
        element.accessibilityTraits = traits;
        [elements addObject:element];
    }];
}

- (void)acr_configureCitationView:(UIView *)view {
    // Citations are links. Native controls remain activatable; we surface link semantics explicitly
    // (a citation pill is a UIButton, so we promote it from "button" to "link" for assistive tech).
    view.isAccessibilityElement = YES;
    UIAccessibilityTraits traits = view.accessibilityTraits;
    traits |= UIAccessibilityTraitLink;
    traits &= ~UIAccessibilityTraitButton;
    view.accessibilityTraits = traits;
}

- (CGRect)acr_boundingRectForCharacterRange:(NSRange)range {
    NSLayoutManager *layoutManager = self.layoutManager;
    NSRange glyphRange = [layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    __block CGRect result = CGRectNull;
    [layoutManager enumerateEnclosingRectsForGlyphRange:glyphRange
                               withinSelectedGlyphRange:NSMakeRange(NSNotFound, 0)
                                        inTextContainer:self.textContainer
                                             usingBlock:^(CGRect rect, BOOL *stop) {
        result = CGRectIsNull(result) ? rect : CGRectUnion(result, rect);
    }];
    if (CGRectIsNull(result)) {
        return CGRectZero;
    }
    // Convert text-container coordinates to the text view's coordinate space.
    result.origin.x += self.textContainerInset.left;
    result.origin.y += self.textContainerInset.top;
    return result;
}

@end
