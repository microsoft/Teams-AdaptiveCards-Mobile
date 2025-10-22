//
//  ACRTextBlockRenderer
//  ACRTextBlockRenderer.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRTextBlockRenderer.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRContentHoldingUIView.h"
#import "ACRRegistration.h"
#import "ACRUILabel.h"
#import "ACRView.h"
#import "DateTimePreparsedToken.h"
#import "DateTimePreparser.h"
#import "HostConfig.h"
#import "MarkDownParser.h"
#import "TextBlock.h"
#import "TextInput.h"
#import "UtiliOS.h"
#import "ARCGridViewLayout.h"
#import "TSExpressionObjCBridge.h"

@implementation ACRTextBlockRenderer

NSString * const DYNAMIC_TEXT_PROP = @"text.dynamic";

+ (ACRTextBlockRenderer *)getInstance
{
    static ACRTextBlockRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRTextBlock;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
          rootView:(ACRView *)rootView
            inputs:(NSMutableArray *)inputs
   baseCardElement:(ACOBaseCardElement *)acoElem
        hostConfig:(ACOHostConfig *)acoConfig
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<TextBlock> txtBlck = std::dynamic_pointer_cast<TextBlock>(elem);
    
    if (txtBlck->GetText().empty()) {
        return nil;
    }
    
    ACRUILabel *lab = [[ACRUILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    lab.backgroundColor = [UIColor clearColor];
    
    lab.style = [viewGroup style];
    NSMutableAttributedString *content = nil;
    if (rootView) {
        NSMutableDictionary *textMap = [rootView getTextMap];
        NSNumber *number = [NSNumber numberWithUnsignedLongLong:(unsigned long long)txtBlck.get()];
        NSString *key = [number stringValue];
        NSDictionary *data = nil;
        NSData *htmlData = nil;
        NSDictionary *options = nil;
        NSDictionary *descriptor = nil;
        NSString *text = nil;
        
        if (![textMap objectForKey:key] || rootView.context.isFirstRowAsHeaders) {
            RichTextElementProperties textProp;
            TexStylesToRichTextElementProperties(txtBlck, [acoConfig getHostConfig]->GetTextStyles().columnHeader, textProp);
            buildIntermediateResultForText(rootView, acoConfig, textProp, key);
        }
        
        data = textMap[key];
        htmlData = data[@"html"];
        options = data[@"options"];
        descriptor = data[@"descriptor"];
        text = data[@"nonhtml"];
        
        // Initializing NSMutableAttributedString for HTML rendering is very slow
        if (htmlData) {
            content = [[NSMutableAttributedString alloc] initWithData:htmlData options:options documentAttributes:nil error:nil];
            // Drop newline char
            [content deleteCharactersInRange:NSMakeRange([content length] - 1, 1)];
            
            UpdateFontWithDynamicType(content);
            
            lab.selectable = YES;
            lab.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
            lab.userInteractionEnabled = YES;
        } else {
            // if html rendering is skipped, remove p tags from both ends (<p>, </p>)
            content = [[NSMutableAttributedString alloc] initWithString:text attributes:descriptor];
        }
        lab.selectable = YES;
        lab.userInteractionEnabled = YES;
        
        content = [self processCitationsInString:content.string];
        [self setupTapOnLabel:lab];
        
        lab.textContainer.lineFragmentPadding = 0;
        lab.textContainerInset = UIEdgeInsetsZero;
        lab.layoutManager.usesFontLeading = false;
        
        // Set paragraph style such as line break mode and alignment
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = [ACOHostConfig getTextBlockAlignment:txtBlck->GetHorizontalAlignment().value_or(HorizontalAlignment::Left) context:rootView.context];
        
        auto sharedStyle = txtBlck->GetStyle();
        auto backUpColor = sharedStyle.has_value() ? txtBlck->GetTextColor().value_or(config->GetTextStyles().heading.color) : txtBlck->GetTextColor().value_or(ForegroundColor::Default);
        auto backUpIsSubtle = sharedStyle.has_value() ? txtBlck->GetIsSubtle().value_or(config->GetTextStyles().heading.isSubtle) : txtBlck->GetIsSubtle().value_or(false);
        
        // Obtain text color to apply to the attributed string
        ACRContainerStyle style = lab.style;
        auto foregroundColor = [acoConfig getTextBlockColor:style textColor:backUpColor subtleOption:backUpIsSubtle];
        
        // Add paragraph style, text color, text weight as attributes to a NSMutableAttributedString, content.
        
        [content addAttributes:@{
            NSParagraphStyleAttributeName : paragraphStyle,
            NSForegroundColorAttributeName : foregroundColor,
        }
                         range:NSMakeRange(0, content.length)];
        
        if (!txtBlck->GetLabelFor().empty() && TextInput().getIsRequired(txtBlck->GetLabelFor()))
        {
            RichTextElementProperties redStarProperties;
            redStarProperties.SetTextColor(ForegroundColor::Attention);
            NSAttributedString *redStar = initAttributedText(acoConfig, " *", redStarProperties, [viewGroup style]);
            [content appendAttributedString:redStar];
        }
        
        lab.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        lab.attributedText = content;
        lab.accessibilityLabel = content.string;
        // if accessibility label is the same as accessibility value, clear accessibility value
        // this prevents the same content from being repeated twice in voiceover
        if (lab.accessibilityValue != nil && [lab.accessibilityValue isEqualToString:lab.accessibilityLabel]) {
            lab.accessibilityValue = @"";
        }
        if ([content.string stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].length == 0) {
            lab.accessibilityValue = @"";
            lab.isAccessibilityElement = NO;
        }
    }
    
    lab.translatesAutoresizingMaskIntoConstraints = NO;
    
    lab.textContainer.maximumNumberOfLines = int(txtBlck->GetMaxLines());
    if (!lab.textContainer.maximumNumberOfLines && !txtBlck->GetWrap()) {
        lab.textContainer.maximumNumberOfLines = 1;
    }
    
    if (txtBlck->GetStyle() == TextStyle::Heading || rootView.context.isFirstRowAsHeaders) {
        lab.accessibilityTraits |= UIAccessibilityTraitHeader;
    }
    
    lab.editable = NO;
    
    [lab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    if (txtBlck->GetHeight() == HeightType::Auto) {
        [lab setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    } else {
        [lab setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    }
    
    configRtl(lab, rootView.context);
    
    //  Expression evaluation for dynamic text property
    if ([TSExpressionObjCBridge isExpressionEvalEnabled])
    {
        [self handleExpressionEvaluationForTextBlock:lab rootView:rootView baseCardElement:acoElem];
    }
    
    NSString *areaName = stringForCString(elem->GetAreaGridName());
    [viewGroup addArrangedSubview:lab withAreaName:areaName];
    
    return lab;
}


#pragma mark - Expression Evaluation Helper
- (void)handleExpressionEvaluationForTextBlock:(ACRUILabel *)label
                                      rootView:(ACRView *)rootView
                               baseCardElement:(ACOBaseCardElement *)acoElem
{
    NSData *jsonData = [acoElem additionalProperty];
    NSError *jsonError = nil;
    NSDictionary *additionalProperties = nil;
    if (jsonData)
    {
        additionalProperties = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
        if (additionalProperties && [additionalProperties isKindOfClass:[NSDictionary class]])
        {
            NSString *titleDynamic = additionalProperties[DYNAMIC_TEXT_PROP];
            
            [self evaluateDynamicProperties:titleDynamic
                                      label:label];
        }
    }
}

- (void)evaluateDynamicProperties:(NSString * _Nullable)textDynamic
                            label:(ACRUILabel *)label
{
    if (textDynamic && [textDynamic length] > 0)
    {
        [self evaluateExpression:textDynamic completion:^(id value, NSError *error)
         {
            if ([value isKindOfClass:[NSString class]] && [((NSString *)value) length] > 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [label setText:value];
                });
            }
        }];
    }
}

/// Evaluates an expression string using the Swift ObjCExpressionEvaluator bridge.
/// Calls the completion block with success/failure and result/error.
- (void)evaluateExpression:(NSString *)expression completion:(void (^)(id _Nullable result, NSError * _Nullable error))completion
{
    [TSExpressionObjCBridge evaluateExpression:expression withData:nil completion:^(NSObject * _Nullable evalResult, NSError * _Nullable evalError)
     {
        if (completion)
        {
            completion(evalResult, evalError);
        }
    }];
}

#pragma mark - Citations Helper methods

- (NSTextAttachment *)createRoundedBoxAttachmentWithText:(NSString *)text backgroundColor:(UIColor *)bgColor
{
    UILabel *badge = [[UILabel alloc] init];
    badge.text = text;
    badge.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    badge.textColor = UIColor.whiteColor;
    badge.backgroundColor = bgColor;
    badge.textAlignment = NSTextAlignmentCenter;
    badge.layer.cornerRadius = 5.0;
    badge.layer.masksToBounds = YES;

    CGSize textSize = [badge.text sizeWithAttributes:@{NSFontAttributeName: badge.font}];
    CGFloat paddingX = 6.0;
    CGFloat paddingY = 2.0;
    badge.frame = CGRectMake(0, 0, textSize.width + paddingX * 2, textSize.height + paddingY * 2);

    UIGraphicsBeginImageContextWithOptions(badge.bounds.size, NO, 0.0);
    [badge.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *badgeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = badgeImage;
    attachment.bounds = CGRectMake(0, -2, badge.bounds.size.width, badge.bounds.size.height);
    
    return attachment;
}

- (NSMutableAttributedString *)processCitationsInString:(NSString *)input {
    NSMutableAttributedString *attributed =
        [[NSMutableAttributedString alloc] initWithString:input];

    NSError *error = nil;
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]\\(cite:(.*?)\\)"
                                                  options:0
                                                    error:&error];

    NSArray<NSTextCheckingResult *> *matches =
        [regex matchesInString:input options:0 range:NSMakeRange(0, input.length)];

    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        if (match.numberOfRanges == 3) {
            NSString *displayText = [input substringWithRange:[match rangeAtIndex:1]];
            NSString *citeValue   = [input substringWithRange:[match rangeAtIndex:2]];

            NSTextAttachment *attachment = [self createRoundedBoxAttachmentWithText:displayText backgroundColor:[UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1.0]];
            NSAttributedString *attachmentString =
                [NSAttributedString attributedStringWithAttachment:attachment];

            NSRange fullMatchRange = match.range;

            // Replace the [10](cite:1) text with badge
            [attributed replaceCharactersInRange:fullMatchRange
                             withAttributedString:attachmentString];

            // Add custom attributes to store citeValue and displayText
            NSRange replacedRange = NSMakeRange(fullMatchRange.location, 1);
            [attributed addAttribute:@"CiteValueAttribute"
                               value:citeValue
                               range:replacedRange];

            [attributed addAttribute:@"CiteDisplayTextAttribute"
                               value:displayText
                               range:replacedRange];
        }
    }
    return attributed;
}

- (void)highlightCitationInLabel:(ACRUILabel *)label atRange:(NSRange)range highlighted:(BOOL)highlighted {
    NSMutableAttributedString *attributed = [label.attributedText mutableCopy];
    NSTextAttachment *attachment = [attributed attribute:NSAttachmentAttributeName atIndex:range.location effectiveRange:nil];

    if ([attachment isKindOfClass:[NSTextAttachment class]]) {
        // Retrieve the original display text
        NSString *text = [attributed attribute:@"CiteDisplayTextAttribute" atIndex:range.location effectiveRange:nil];
        if (!text) return;

        UIColor *color = highlighted ? [UIColor redColor] : [UIColor colorWithRed:0.2 green:0.4 blue:0.9 alpha:1.0];
        NSTextAttachment *newAttachment = [self createRoundedBoxAttachmentWithText:text backgroundColor:color];

        NSAttributedString *newAttr = [NSAttributedString attributedStringWithAttachment:newAttachment];
        [attributed replaceCharactersInRange:range withAttributedString:newAttr];

        // Preserve attributes
        NSString *citeValue = [attributed attribute:@"CiteValueAttribute" atIndex:range.location effectiveRange:nil];
        [attributed addAttribute:@"CiteValueAttribute" value:citeValue range:NSMakeRange(range.location, 1)];
        [attributed addAttribute:@"CiteDisplayTextAttribute" value:text range:NSMakeRange(range.location, 1)];

        label.attributedText = attributed;
    }
}

- (void)setupTapOnLabel:(ACRUILabel *)label
{
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)];
    [label addGestureRecognizer:tap];
}

- (void)handleTapOnLabel:(UITapGestureRecognizer *)gesture
{
    UILabel *label = (UILabel *)gesture.view;
    CGPoint tapLocation = [gesture locationInView:label];
    
    // Setup text layout system
    NSTextStorage *textStorage =
    [[NSTextStorage alloc] initWithAttributedString:label.attributedText]; NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init]; NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:label.bounds.size]; textContainer.lineFragmentPadding = 0; textContainer.maximumNumberOfLines = label.numberOfLines; textContainer.lineBreakMode = label.lineBreakMode; [layoutManager addTextContainer:textContainer]; [textStorage addLayoutManager:layoutManager]; NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:tapLocation inTextContainer:textContainer fractionOfDistanceThroughGlyph:nil];
    // Check if this glyph has our custom attribute
    NSRange effectiveRange = NSMakeRange(0, 0); NSString *citeValue = [textStorage attribute:@"CiteValueAttribute" atIndex:glyphIndex effectiveRange:&effectiveRange]; if (citeValue) {
        // Highlight badge
        [self highlightCitationInLabel:(ACRUILabel *)label atRange:effectiveRange highlighted:YES]; dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self highlightCitationInLabel:(ACRUILabel *)label atRange:effectiveRange highlighted:NO]; });
        // Show alert
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:[NSString stringWithFormat:@"Citation tapped: %@", citeValue] preferredStyle:UIAlertControllerStyleAlert]; [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]]; UIViewController *root = UIApplication.sharedApplication.keyWindow.rootViewController; [root presentViewController:alert animated:YES completion:nil]; } }

@end
