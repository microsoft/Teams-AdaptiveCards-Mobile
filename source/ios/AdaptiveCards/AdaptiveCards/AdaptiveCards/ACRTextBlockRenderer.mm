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
#import "UtiliOS.h"
#import "ARCGridViewLayout.h"
#import <AdaptiveCards/AdaptiveCards-Swift.h>
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

@end
