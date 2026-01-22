//
//  SwiftAdaptiveCardParserBridge.m
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 2/4/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import "SwiftAdaptiveCardObjcBridge.h"

#import "ACRRegistration.h"
#import "SharedAdaptiveCard.h"
#import "ParseResult.h"
#import "ACOAdaptiveCardParseResult.h"
#import "ACRParseWarningPrivate.h"
#import "UtiliOS.h"
#import "TextBlock.h"
#import "Image.h"

#if __has_include(<AdaptiveCards/AdaptiveCards-Swift.h>)
#define SWIFT_ADAPTIVE_CARDS_AVAILABLE 1
#import <AdaptiveCards/AdaptiveCards-Swift.h>
#else
#define SWIFT_ADAPTIVE_CARDS_AVAILABLE 0
#endif

using namespace AdaptiveCards;

@implementation SwiftAdaptiveCardObjcBridge

+ (BOOL)canUseSwift {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
    return YES;
#endif
    return NO;
}

+ (BOOL)useSwiftForRendering {
    id<ACRIFeatureFlagResolver> resolver = [[ACRRegistration getInstance] getFeatureFlagResolver];
    if (resolver) {
        return [resolver boolForFlag:@"isSwiftAdaptiveCardsEnabled"];
    }
    return NO;
}

+ (NSMutableArray * _Nullable)getWarningsFromParseResult:(id _Nullable)parseResult useSwift:(BOOL)useSwift {
    NSMutableArray *acrParseWarnings = [[NSMutableArray alloc] init];
    if (useSwift && [self canUseSwift]) {
        // Swift implementation
       SwiftAdaptiveCardParseResult *swiftResult = (SwiftAdaptiveCardParseResult *)parseResult;
       NSArray *swiftWarnings = [swiftResult warnings];
       if (swiftWarnings) {
           acrParseWarnings = [NSMutableArray arrayWithArray:swiftWarnings];
       }
    } else {
        // For C++ implementation, check the type of parseResult
        if ([parseResult isKindOfClass:[NSValue class]]) {
            // If it's an NSValue (which can store C++ pointers), extract the pointer
            std::shared_ptr<ParseResult> *cppResultPtr = (std::shared_ptr<ParseResult> *)[parseResult pointerValue];
            std::vector<std::shared_ptr<AdaptiveCardParseWarning>> parseWarnings = (*cppResultPtr)->GetWarnings();
            for (const auto &warning : parseWarnings) {
                ACRParseWarning *acrParseWarning = [[ACRParseWarning alloc] initWithParseWarning:warning];
                [acrParseWarnings addObject:acrParseWarning];
            }
        } else {
            NSLog(@"Error retrieving parsed result");
        }
    }
    return acrParseWarnings;
}

+ (BOOL)isSwiftParserEnabled {
    if ([self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftAdaptiveCardParser isSwiftParserEnabled];
#endif
    }
    return NO;
}

+ (void)setSwiftParserEnabled:(BOOL)enabled {
    if ([self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        [SwiftAdaptiveCardParser setSwiftParserEnabled:enabled];
#endif
    }
}

+ (SwiftAdaptiveCardParseResult * _Nonnull)parseWithPayload:(NSString *_Nonnull)payload {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
    if ([self canUseSwift]) {
        return [SwiftAdaptiveCardParser parseWithPayload:payload];
    }
#endif
    // If Swift is not available, we need to return something
    // This should ideally never happen if canUseSwift is checked properly
    // but we need to satisfy the nonnull contract
    return (SwiftAdaptiveCardParseResult *)[[NSObject alloc] init];
}

+ (BOOL)isParseResultSuccessful:(SwiftAdaptiveCardParseResult *_Nonnull)result {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
    // Check if there are any errors
    return (result.errors == nil || result.errors.count == 0);
#endif
    return NO;
}

#pragma mark - Element Type Bridge

+ (NSString *)getElementTypeStringFromElement:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTypeStringFrom:element];
#endif
    } else {
        // For C++ elements passed as NSValue containing shared_ptr
        if ([element isKindOfClass:[NSValue class]]) {
            std::shared_ptr<BaseCardElement> *elemPtr = (std::shared_ptr<BaseCardElement> *)[element pointerValue];
            if (elemPtr && *elemPtr) {
                std::string typeStr = (*elemPtr)->GetElementTypeString();
                return [NSString stringWithUTF8String:typeStr.c_str()];
            }
        }
    }
    return @"Unknown";
}

#pragma mark - TextBlock Property Bridge

+ (NSString *)getTextBlockText:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextBlockText:element];
#endif
    } else {
        // For C++ elements passed as NSValue containing shared_ptr
        if ([element isKindOfClass:[NSValue class]]) {
            std::shared_ptr<BaseCardElement> *elemPtr = (std::shared_ptr<BaseCardElement> *)[element pointerValue];
            if (elemPtr && *elemPtr) {
                std::shared_ptr<TextBlock> textBlock = std::dynamic_pointer_cast<TextBlock>(*elemPtr);
                if (textBlock) {
                    return [NSString stringWithUTF8String:textBlock->GetText().c_str()];
                }
            }
        }
    }
    return @"";
}

+ (BOOL)getTextBlockWrap:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextBlockWrap:element];
#endif
    } else {
        if ([element isKindOfClass:[NSValue class]]) {
            std::shared_ptr<BaseCardElement> *elemPtr = (std::shared_ptr<BaseCardElement> *)[element pointerValue];
            if (elemPtr && *elemPtr) {
                std::shared_ptr<TextBlock> textBlock = std::dynamic_pointer_cast<TextBlock>(*elemPtr);
                if (textBlock) {
                    return textBlock->GetWrap();
                }
            }
        }
    }
    return NO;
}

+ (NSUInteger)getTextBlockMaxLines:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextBlockMaxLines:element];
#endif
    } else {
        if ([element isKindOfClass:[NSValue class]]) {
            std::shared_ptr<BaseCardElement> *elemPtr = (std::shared_ptr<BaseCardElement> *)[element pointerValue];
            if (elemPtr && *elemPtr) {
                std::shared_ptr<TextBlock> textBlock = std::dynamic_pointer_cast<TextBlock>(*elemPtr);
                if (textBlock) {
                    return textBlock->GetMaxLines();
                }
            }
        }
    }
    return 0;
}

+ (NSInteger)getTextBlockHorizontalAlignment:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextBlockHorizontalAlignment:element];
#endif
    } else {
        if ([element isKindOfClass:[NSValue class]]) {
            std::shared_ptr<BaseCardElement> *elemPtr = (std::shared_ptr<BaseCardElement> *)[element pointerValue];
            if (elemPtr && *elemPtr) {
                std::shared_ptr<TextBlock> textBlock = std::dynamic_pointer_cast<TextBlock>(*elemPtr);
                if (textBlock) {
                    auto alignment = textBlock->GetHorizontalAlignment();
                    if (alignment.has_value()) {
                        return static_cast<NSInteger>(alignment.value());
                    }
                }
            }
        }
    }
    return 0;
}

#pragma mark - Image Property Bridge

+ (NSString *)getImageUrl:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getImageUrl:element];
#endif
    } else {
        if ([element isKindOfClass:[NSValue class]]) {
            std::shared_ptr<BaseCardElement> *elemPtr = (std::shared_ptr<BaseCardElement> *)[element pointerValue];
            if (elemPtr && *elemPtr) {
                std::shared_ptr<Image> image = std::dynamic_pointer_cast<Image>(*elemPtr);
                if (image) {
                    return [NSString stringWithUTF8String:image->GetUrl().c_str()];
                }
            }
        }
    }
    return @"";
}

+ (NSString *)getImageAltText:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getImageAltText:element];
#endif
    } else {
        if ([element isKindOfClass:[NSValue class]]) {
            std::shared_ptr<BaseCardElement> *elemPtr = (std::shared_ptr<BaseCardElement> *)[element pointerValue];
            if (elemPtr && *elemPtr) {
                std::shared_ptr<Image> image = std::dynamic_pointer_cast<Image>(*elemPtr);
                if (image) {
                    return [NSString stringWithUTF8String:image->GetAltText().c_str()];
                }
            }
        }
    }
    return @"";
}

+ (NSInteger)getImageSize:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getImageSize:element];
#endif
    } else {
        if ([element isKindOfClass:[NSValue class]]) {
            std::shared_ptr<BaseCardElement> *elemPtr = (std::shared_ptr<BaseCardElement> *)[element pointerValue];
            if (elemPtr && *elemPtr) {
                std::shared_ptr<Image> image = std::dynamic_pointer_cast<Image>(*elemPtr);
                if (image) {
                    return static_cast<NSInteger>(image->GetImageSize());
                }
            }
        }
    }
    return 0;
}

#pragma mark - FactSet Property Bridge

+ (NSArray *)getFactSetFacts:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getFactSetFacts:element];
#endif
    }
    return @[];
}

+ (NSString *)getFactTitle:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getFactTitle:element];
#endif
    }
    return @"";
}

+ (NSString *)getFactValue:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getFactValue:element];
#endif
    }
    return @"";
}

#pragma mark - ImageSet Property Bridge

+ (NSArray *)getImageSetImages:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getImageSetImages:element];
#endif
    }
    return @[];
}

+ (NSInteger)getImageSetImageSize:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getImageSetImageSize:element];
#endif
    }
    return 0;
}

#pragma mark - ActionSet Property Bridge

+ (NSArray *)getActionSetActions:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getActionSetActions:element];
#endif
    }
    return @[];
}

+ (NSInteger)getActionSetOrientation:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getActionSetOrientation:element];
#endif
    }
    return 0;
}

#pragma mark - ColumnSet Property Bridge

+ (NSArray *)getColumnSetColumns:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getColumnSetColumns:element];
#endif
    }
    return @[];
}

+ (NSString *)getColumnWidth:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getColumnWidth:element];
#endif
    }
    return @"";
}

+ (NSArray *)getColumnItems:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getColumnItems:element];
#endif
    }
    return @[];
}

+ (NSInteger)getColumnVerticalContentAlignment:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getColumnVerticalContentAlignment:element];
#endif
    }
    return 0;
}

#pragma mark - Table Property Bridge

+ (NSArray *)getTableColumns:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTableColumns:element];
#endif
    }
    return @[];
}

+ (NSArray *)getTableRows:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTableRows:element];
#endif
    }
    return @[];
}

+ (BOOL)getTableShowGridLines:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTableShowGridLines:element];
#endif
    }
    return NO;
}

+ (NSArray *)getTableRowCells:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTableRowCells:element];
#endif
    }
    return @[];
}

+ (NSArray *)getTableCellItems:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTableCellItems:element];
#endif
    }
    return @[];
}

#pragma mark - Action Property Bridge

+ (NSString *)getOpenUrlActionUrl:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getOpenUrlActionUrl:element];
#endif
    }
    return @"";
}

+ (id _Nullable)getSubmitActionData:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getSubmitActionData:element];
#endif
    }
    return nil;
}

+ (NSString *)getExecuteActionVerb:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getExecuteActionVerb:element];
#endif
    }
    return @"";
}

+ (id _Nullable)getShowCardActionCard:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getShowCardActionCard:element];
#endif
    }
    return nil;
}

+ (NSArray *)getToggleVisibilityTargets:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getToggleVisibilityTargets:element];
#endif
    }
    return @[];
}

#pragma mark - Input Property Bridge

+ (NSString *)getTextInputPlaceholder:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextInputPlaceholder:element];
#endif
    }
    return @"";
}

+ (NSString *)getTextInputValue:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextInputValue:element];
#endif
    }
    return @"";
}

+ (BOOL)getTextInputIsMultiline:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextInputIsMultiline:element];
#endif
    }
    return NO;
}

+ (double)getNumberInputValue:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getNumberInputValue:element];
#endif
    }
    return 0.0;
}

+ (NSString *)getDateInputValue:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getDateInputValue:element];
#endif
    }
    return @"";
}

+ (NSString *)getTimeInputValue:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTimeInputValue:element];
#endif
    }
    return @"";
}

+ (NSString *)getToggleInputTitle:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getToggleInputTitle:element];
#endif
    }
    return @"";
}

+ (NSArray *)getChoiceSetInputChoices:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getChoiceSetInputChoices:element];
#endif
    }
    return @[];
}

#pragma mark - Container Property Bridge

+ (NSArray *)getContainerItems:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getContainerItems:element];
#endif
    }
    return @[];
}

+ (NSInteger)getContainerStyle:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getContainerStyle:element];
#endif
    }
    return 0;
}

#pragma mark - Carousel Property Bridge

+ (NSArray *)getCarouselPages:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getCarouselPages:element];
#endif
    }
    return @[];
}

+ (NSArray *)getCarouselPageItems:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getCarouselPageItems:element];
#endif
    }
    return @[];
}

#pragma mark - Badge Property Bridge

+ (NSString *)getBadgeText:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getBadgeText:element];
#endif
    }
    return @"";
}

+ (NSInteger)getBadgeStyle:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getBadgeStyle:element];
#endif
    }
    return 0;
}

#pragma mark - Progress Property Bridge

+ (double)getProgressBarValue:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getProgressBarValue:element];
#endif
    }
    return 0.0;
}

+ (NSString *)getProgressRingLabel:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getProgressRingLabel:element];
#endif
    }
    return @"";
}

#pragma mark - RatingInput Property Bridge

+ (double)getRatingInputValue:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingInputValue:element];
#endif
    }
    return 0.0;
}

+ (double)getRatingInputMax:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingInputMax:element];
#endif
    }
    return 5.0;
}

+ (NSInteger)getRatingInputHorizontalAlignment:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingInputHorizontalAlignment:element];
#endif
    }
    return 0;
}

+ (NSInteger)getRatingInputSize:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingInputSize:element];
#endif
    }
    return 0;
}

+ (NSInteger)getRatingInputColor:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingInputColor:element];
#endif
    }
    return 0;
}

#pragma mark - RatingLabel Property Bridge

+ (double)getRatingLabelValue:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingLabelValue:element];
#endif
    }
    return 0.0;
}

+ (double)getRatingLabelMax:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingLabelMax:element];
#endif
    }
    return 5.0;
}

+ (NSNumber *_Nullable)getRatingLabelCount:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingLabelCount:element];
#endif
    }
    return nil;
}

+ (NSInteger)getRatingLabelHorizontalAlignment:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingLabelHorizontalAlignment:element];
#endif
    }
    return 0;
}

+ (NSInteger)getRatingLabelSize:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingLabelSize:element];
#endif
    }
    return 0;
}

+ (NSInteger)getRatingLabelColor:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingLabelColor:element];
#endif
    }
    return 0;
}

+ (NSInteger)getRatingLabelStyle:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRatingLabelStyle:element];
#endif
    }
    return 0;
}

#pragma mark - Icon Property Bridge

+ (NSString *)getIconName:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getIconName:element];
#endif
    }
    return @"";
}

+ (NSInteger)getIconForegroundColor:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getIconForegroundColor:element];
#endif
    }
    return 0;
}

+ (NSInteger)getIconSize:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getIconSize:element];
#endif
    }
    return 3; // Default to standard
}

+ (NSInteger)getIconStyle:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getIconStyle:element];
#endif
    }
    return 0;
}

+ (id _Nullable)getIconSelectAction:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getIconSelectAction:element];
#endif
    }
    return nil;
}

#pragma mark - Media Property Bridge

+ (NSString *)getMediaPoster:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getMediaPoster:element];
#endif
    }
    return @"";
}

+ (NSString *)getMediaAltText:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getMediaAltText:element];
#endif
    }
    return @"";
}

+ (NSArray *)getMediaSources:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getMediaSources:element];
#endif
    }
    return @[];
}

+ (NSArray *)getMediaCaptionSources:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getMediaCaptionSources:element];
#endif
    }
    return @[];
}

+ (NSString *)getMediaSourceUrl:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getMediaSourceUrl:element];
#endif
    }
    return @"";
}

+ (NSString *)getMediaSourceMimeType:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getMediaSourceMimeType:element];
#endif
    }
    return @"";
}

#pragma mark - CompoundButton Property Bridge

+ (NSString *)getCompoundButtonBadge:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getCompoundButtonBadge:element];
#endif
    }
    return @"";
}

+ (NSString *)getCompoundButtonTitle:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getCompoundButtonTitle:element];
#endif
    }
    return @"";
}

+ (NSString *)getCompoundButtonDescription:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getCompoundButtonDescription:element];
#endif
    }
    return @"";
}

+ (id _Nullable)getCompoundButtonIcon:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getCompoundButtonIcon:element];
#endif
    }
    return nil;
}

+ (id _Nullable)getCompoundButtonSelectAction:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getCompoundButtonSelectAction:element];
#endif
    }
    return nil;
}

#pragma mark - RichTextBlock Property Bridge

+ (NSInteger)getRichTextBlockHorizontalAlignment:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRichTextBlockHorizontalAlignment:element];
#endif
    }
    return 0;
}

+ (NSArray *)getRichTextBlockInlines:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getRichTextBlockInlines:element];
#endif
    }
    return @[];
}

#pragma mark - TextRun Property Bridge

+ (NSString *)getTextRunText:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunText:element];
#endif
    }
    return @"";
}

+ (NSInteger)getTextRunTextSize:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunTextSize:element];
#endif
    }
    return 0;
}

+ (NSInteger)getTextRunTextWeight:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunTextWeight:element];
#endif
    }
    return 0;
}

+ (NSInteger)getTextRunTextColor:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunTextColor:element];
#endif
    }
    return 0;
}

+ (NSNumber *_Nullable)getTextRunIsSubtle:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunIsSubtle:element];
#endif
    }
    return nil;
}

+ (BOOL)getTextRunItalic:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunItalic:element];
#endif
    }
    return NO;
}

+ (BOOL)getTextRunStrikethrough:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunStrikethrough:element];
#endif
    }
    return NO;
}

+ (BOOL)getTextRunHighlight:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunHighlight:element];
#endif
    }
    return NO;
}

+ (BOOL)getTextRunUnderline:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunUnderline:element];
#endif
    }
    return NO;
}

+ (id _Nullable)getTextRunSelectAction:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getTextRunSelectAction:element];
#endif
    }
    return nil;
}

#pragma mark - Unknown Element/Action Property Bridge

+ (NSString *)getUnknownActionTypeString:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getUnknownActionTypeString:element];
#endif
    }
    return @"";
}

+ (NSString *)getUnknownElementTypeString:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getUnknownElementTypeString:element];
#endif
    }
    return @"";
}

+ (NSString *)getUnknownElementAdditionalPropertiesJson:(id)element useSwift:(BOOL)useSwift {
    if (useSwift && [self canUseSwift]) {
#if SWIFT_ADAPTIVE_CARDS_AVAILABLE
        return [SwiftElementPropertyAccessor getUnknownElementAdditionalPropertiesJson:element];
#endif
    }
    return @"";
}

@end
