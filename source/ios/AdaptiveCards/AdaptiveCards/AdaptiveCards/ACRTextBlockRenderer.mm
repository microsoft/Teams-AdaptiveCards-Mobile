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
#import "ACRViewTextAttachment.h"
#import "ACRViewAttachingTextView.h"

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
    
    ACRViewAttachingTextView *lab = [[ACRViewAttachingTextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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
        
        content = [self processCitationsInStringWithButtons:content.string];
        
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
- (void)handleExpressionEvaluationForTextBlock:(ACRViewAttachingTextView *)label
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
                            label:(ACRViewAttachingTextView *)label
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

- (UIButton *)createButtonWithTitle:(NSString *)title size:(CGSize)size {

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderWidth = 1.0;
    button.layer.cornerRadius = 4.0;
    button.layer.borderColor = [UIColor darkGrayColor].CGColor;
    button.layer.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1].CGColor;
    button.layer.backgroundColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1].CGColor;
    // Set button title font to regular size 14
    button.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    
    // Ensure button can receive touches
    button.userInteractionEnabled = YES;
    
    // Add target for button tap
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (ACRViewTextAttachment *)createCitationButtonAttachmentWithText:(NSString *)text {
    CGSize size = CGSizeMake(17, 17);
    // Create a UIButton with citation styling
    UIButton *citationButton = [self createButtonWithTitle:text size: size];
    // Create the ACRViewTextAttachment with the button
    ACRViewTextAttachment *attachment = [[ACRViewTextAttachment alloc] initWithView:citationButton size:size];
    
    return attachment;
}

- (NSMutableAttributedString *)processCitationsInStringWithButtons:(NSString *)input {
    NSMutableAttributedString *attributed =
        [[NSMutableAttributedString alloc] initWithString:input];

    NSError *error = nil;
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]\\(cite:(.*?)\\)"
                                                  options:0
                                                    error:&error];

    NSArray<NSTextCheckingResult *> *matches =
        [regex matchesInString:input options:0 range:NSMakeRange(0, input.length)];

    NSAttributedString *spacer = [[NSAttributedString alloc] initWithString:@" "];

    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        if (match.numberOfRanges == 3) {
            NSString *displayText = [input substringWithRange:[match rangeAtIndex:1]];
//            NSString *citeValue   = [input substringWithRange:[match rangeAtIndex:2]];

            // Use the new button-based attachment instead of the image-based one
            ACRViewTextAttachment *attachment = [self createCitationButtonAttachmentWithText:displayText];
            NSMutableAttributedString *attachmentString = [NSMutableAttributedString attributedStringWithAttachment:attachment];
            [attachmentString appendAttributedString:spacer];

            // Replace the [10](cite:1) text with button (don't append, just replace)
            NSRange fullMatchRange = match.range;
            [attributed replaceCharactersInRange:fullMatchRange withAttributedString:attachmentString];
        }
    }
    return attributed;
}

- (void)buttonTapped:(id)sender {
    UIButton *button = nil;
    NSString *buttonText = @"Unknown";
    
    if ([sender isKindOfClass:[UIButton class]]) {
        button = (UIButton *)sender;
        buttonText = button.titleLabel.text ?: @"No Title";
    } else if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        if ([gesture.view isKindOfClass:[UIButton class]]) {
            button = (UIButton *)gesture.view;
            buttonText = button.titleLabel.text ?: @"No Title";
        }
    }
    
    // Handle button tap - you can access the button's properties here
    NSLog(@"Citation button tapped: %@", buttonText);
    
    // Show alert with citation information
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Citation Tapped"
                                                                   message:[NSString stringWithFormat:@"Citation button '%@' was tapped!", buttonText]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" 
                                                       style:UIAlertActionStyleDefault 
                                                     handler:nil];
    [alert addAction:okAction];
    
    // Get the top-most view controller to present the alert
    UIViewController *topViewController = [self topMostViewController];
    if (topViewController) {
        [topViewController presentViewController:alert animated:YES completion:nil];
    }
}

- (UIViewController *)topMostViewController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end
