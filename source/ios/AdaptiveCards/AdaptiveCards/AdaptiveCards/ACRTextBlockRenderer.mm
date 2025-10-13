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

#if __has_include(<AdaptiveCards/AdaptiveCards-Swift.h>)
#define CHAIN_OF_THOUGHT_AVAILABLE 1
#import <AdaptiveCards/AdaptiveCards-Swift.h>
#else
#define CHAIN_OF_THOUGHT_AVAILABLE 0
#endif

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

    // Check if this is Chain of Thought content
    NSString *textContent = [NSString stringWithCString:txtBlck->GetText().c_str() encoding:NSUTF8StringEncoding];
    
#if CHAIN_OF_THOUGHT_AVAILABLE
    // Check for Chain of Thought integration
    if ([ChainOfThoughtViewFactory isChainOfThoughtContent:textContent]) {
        UIView *chainOfThoughtView = [ChainOfThoughtViewFactory createChainOfThoughtViewFromTextContent:textContent];
        if (chainOfThoughtView) {
            // Set up the view for layout with proper priority settings
            chainOfThoughtView.translatesAutoresizingMaskIntoConstraints = NO;
            
            // Ensure proper content priorities for dynamic sizing
            [chainOfThoughtView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            [chainOfThoughtView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            
            // Prevent clipping by ensuring clipsToBounds is disabled up the chain
            chainOfThoughtView.clipsToBounds = NO;
            
            // Add the Chain of Thought view instead of the regular text block  
            NSString *areaName = stringForCString(elem->GetAreaGridName());
            [viewGroup addArrangedSubview:chainOfThoughtView withAreaName:areaName];
            
            // If we have a hosting view, attach it to the root view controller
            if ([chainOfThoughtView isKindOfClass:[ChainOfThoughtHostingView class]]) {
                UIViewController *rootViewController = traverseResponderChainForUIViewController(rootView);
                if (rootViewController) {
                    ChainOfThoughtHostingView *hostingView = (ChainOfThoughtHostingView *)chainOfThoughtView;
                    [hostingView attachToParentViewController:rootViewController];
                }
            }
            
            return chainOfThoughtView;
        }
    }
    
    // Check for Streaming integration
    if ([StreamingViewFactory isStreamingContent:textContent]) {
        UIView *streamingView = [StreamingViewFactory createStreamingViewFromTextContent:textContent];
        if (streamingView) {
            // Set up the view for layout with proper priority settings
            streamingView.translatesAutoresizingMaskIntoConstraints = NO;
            
            // Ensure proper content priorities for dynamic sizing
            [streamingView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            [streamingView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            
            // Prevent clipping by ensuring clipsToBounds is disabled up the chain
            streamingView.clipsToBounds = NO;
            
            // Add the Streaming view instead of the regular text block  
            NSString *areaName = stringForCString(elem->GetAreaGridName());
            [viewGroup addArrangedSubview:streamingView withAreaName:areaName];
            
            return streamingView;
        }
    }
    
    // Check for OpenAI App integration
    if ([OpenAIAppViewFactory isOpenAIAppContent:textContent]) {
        [ACDiagnosticLogger logMessage:@"Detected OpenAI App content in TextBlock" category:@"OpenAIApp"];
        
        UIView *openAIAppView = [OpenAIAppViewFactory createOpenAIAppViewFromTextContent:textContent];
        if (openAIAppView) {
            [ACDiagnosticLogger logMessage:@"Successfully created OpenAI App view, adding to view hierarchy" category:@"Rendering"];
            
            // Set up the view for layout with proper priority settings
            openAIAppView.translatesAutoresizingMaskIntoConstraints = NO;
            
            // Ensure proper content priorities for dynamic sizing
            [openAIAppView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            [openAIAppView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            
            // Prevent clipping by ensuring clipsToBounds is disabled up the chain
            openAIAppView.clipsToBounds = NO;
            
            // Add the OpenAI App view instead of the regular text block  
            NSString *areaName = stringForCString(elem->GetAreaGridName());
            [viewGroup addArrangedSubview:openAIAppView withAreaName:areaName];
            
            [ACDiagnosticLogger logMessage:@"OpenAI App view added to card successfully" category:@"Success"];
            return openAIAppView;
        } else {
            [ACDiagnosticLogger logMessage:@"Failed to create OpenAI App view from content" category:@"Error"];
        }
    }
#endif

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

@end
