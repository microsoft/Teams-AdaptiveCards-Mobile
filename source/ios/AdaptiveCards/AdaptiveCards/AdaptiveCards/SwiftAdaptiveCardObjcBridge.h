//
//  SwiftAdaptiveCardParserBridge.h
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 2/4/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SwiftAdaptiveCardParseResult;

NS_ASSUME_NONNULL_BEGIN

@interface SwiftAdaptiveCardObjcBridge : NSObject

#pragma mark - Core Parser Methods

+ (BOOL)canUseSwift;
+ (BOOL)useSwiftForRendering;
+ (NSMutableArray *_Nullable)getWarningsFromParseResult:(id _Nullable )parseResult useSwift:(BOOL)useSwift;

+ (BOOL)isSwiftParserEnabled;
+ (void)setSwiftParserEnabled:(BOOL)enabled;
+ (SwiftAdaptiveCardParseResult * _Nonnull)parseWithPayload:(NSString *_Nonnull)payload;
+ (BOOL)isParseResultSuccessful:(SwiftAdaptiveCardParseResult *_Nonnull)result;

#pragma mark - Element Type Bridge

/// Returns the element type string from either a Swift or C++ element
+ (NSString *)getElementTypeStringFromElement:(id)element useSwift:(BOOL)useSwift;

#pragma mark - TextBlock Property Bridge

/// Get text from a TextBlock element
+ (NSString *)getTextBlockText:(id)element useSwift:(BOOL)useSwift;

/// Get wrap setting from a TextBlock element
+ (BOOL)getTextBlockWrap:(id)element useSwift:(BOOL)useSwift;

/// Get maxLines from a TextBlock element
+ (NSUInteger)getTextBlockMaxLines:(id)element useSwift:(BOOL)useSwift;

/// Get horizontal alignment from a TextBlock element (returns enum raw value)
+ (NSInteger)getTextBlockHorizontalAlignment:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Image Property Bridge

/// Get URL from an Image element
+ (NSString *)getImageUrl:(id)element useSwift:(BOOL)useSwift;

/// Get alt text from an Image element
+ (NSString *)getImageAltText:(id)element useSwift:(BOOL)useSwift;

/// Get image size from an Image element (returns enum raw value)
+ (NSInteger)getImageSize:(id)element useSwift:(BOOL)useSwift;

#pragma mark - FactSet Property Bridge

/// Get facts array from a FactSet element
+ (NSArray *)getFactSetFacts:(id)element useSwift:(BOOL)useSwift;

/// Get title from a Fact element
+ (NSString *)getFactTitle:(id)element useSwift:(BOOL)useSwift;

/// Get value from a Fact element
+ (NSString *)getFactValue:(id)element useSwift:(BOOL)useSwift;

#pragma mark - ImageSet Property Bridge

/// Get images array from an ImageSet element
+ (NSArray *)getImageSetImages:(id)element useSwift:(BOOL)useSwift;

/// Get image size from an ImageSet element (returns enum raw value)
+ (NSInteger)getImageSetImageSize:(id)element useSwift:(BOOL)useSwift;

#pragma mark - ActionSet Property Bridge

/// Get actions array from an ActionSet element
+ (NSArray *)getActionSetActions:(id)element useSwift:(BOOL)useSwift;

/// Get orientation from an ActionSet element (returns enum raw value)
+ (NSInteger)getActionSetOrientation:(id)element useSwift:(BOOL)useSwift;

#pragma mark - ColumnSet Property Bridge

/// Get columns array from a ColumnSet element
+ (NSArray *)getColumnSetColumns:(id)element useSwift:(BOOL)useSwift;

/// Get width from a Column element (returns string like "auto", "stretch", or pixel/weight value)
+ (NSString *)getColumnWidth:(id)element useSwift:(BOOL)useSwift;

/// Get items array from a Column element
+ (NSArray *)getColumnItems:(id)element useSwift:(BOOL)useSwift;

/// Get vertical content alignment from a Column element (returns enum raw value)
+ (NSInteger)getColumnVerticalContentAlignment:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Table Property Bridge

/// Get columns array from a Table element
+ (NSArray *)getTableColumns:(id)element useSwift:(BOOL)useSwift;

/// Get rows array from a Table element
+ (NSArray *)getTableRows:(id)element useSwift:(BOOL)useSwift;

/// Get showGridLines from a Table element
+ (BOOL)getTableShowGridLines:(id)element useSwift:(BOOL)useSwift;

/// Get cells array from a TableRow element
+ (NSArray *)getTableRowCells:(id)element useSwift:(BOOL)useSwift;

/// Get items array from a TableCell element
+ (NSArray *)getTableCellItems:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Action Property Bridge

/// Get URL from an OpenUrlAction
+ (NSString *)getOpenUrlActionUrl:(id)element useSwift:(BOOL)useSwift;

/// Get data from a SubmitAction (nullable)
+ (id _Nullable)getSubmitActionData:(id)element useSwift:(BOOL)useSwift;

/// Get verb from an ExecuteAction
+ (NSString *)getExecuteActionVerb:(id)element useSwift:(BOOL)useSwift;

/// Get card from a ShowCardAction (nullable)
+ (id _Nullable)getShowCardActionCard:(id)element useSwift:(BOOL)useSwift;

/// Get targets array from a ToggleVisibilityAction
+ (NSArray *)getToggleVisibilityTargets:(id)element useSwift:(BOOL)useSwift;

/// Get title from a PopoverAction
+ (NSString *)getPopoverActionTitle:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Input Property Bridge

/// Get placeholder from a TextInput element
+ (NSString *)getTextInputPlaceholder:(id)element useSwift:(BOOL)useSwift;

/// Get value from a TextInput element
+ (NSString *)getTextInputValue:(id)element useSwift:(BOOL)useSwift;

/// Get isMultiline from a TextInput element
+ (BOOL)getTextInputIsMultiline:(id)element useSwift:(BOOL)useSwift;

/// Get value from a NumberInput element
+ (double)getNumberInputValue:(id)element useSwift:(BOOL)useSwift;

/// Get value from a DateInput element
+ (NSString *)getDateInputValue:(id)element useSwift:(BOOL)useSwift;

/// Get value from a TimeInput element
+ (NSString *)getTimeInputValue:(id)element useSwift:(BOOL)useSwift;

/// Get title from a ToggleInput element
+ (NSString *)getToggleInputTitle:(id)element useSwift:(BOOL)useSwift;

/// Get choices array from a ChoiceSetInput element
+ (NSArray *)getChoiceSetInputChoices:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Container Property Bridge

/// Get items array from a Container element
+ (NSArray *)getContainerItems:(id)element useSwift:(BOOL)useSwift;

/// Get style from a Container element (returns enum raw value)
+ (NSInteger)getContainerStyle:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Carousel Property Bridge

/// Get pages array from a Carousel element
+ (NSArray *)getCarouselPages:(id)element useSwift:(BOOL)useSwift;

/// Get items array from a CarouselPage element
+ (NSArray *)getCarouselPageItems:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Badge Property Bridge

/// Get text from a Badge element
+ (NSString *)getBadgeText:(id)element useSwift:(BOOL)useSwift;

/// Get style from a Badge element (returns enum raw value)
+ (NSInteger)getBadgeStyle:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Progress Property Bridge

/// Get value from a ProgressBar element
+ (double)getProgressBarValue:(id)element useSwift:(BOOL)useSwift;

/// Get label from a ProgressRing element
+ (NSString *)getProgressRingLabel:(id)element useSwift:(BOOL)useSwift;

#pragma mark - RatingInput Property Bridge

/// Get value from a RatingInput element
+ (double)getRatingInputValue:(id)element useSwift:(BOOL)useSwift;

/// Get max from a RatingInput element
+ (double)getRatingInputMax:(id)element useSwift:(BOOL)useSwift;

/// Get horizontal alignment from a RatingInput element (returns enum raw value)
+ (NSInteger)getRatingInputHorizontalAlignment:(id)element useSwift:(BOOL)useSwift;

/// Get size from a RatingInput element (returns enum raw value)
+ (NSInteger)getRatingInputSize:(id)element useSwift:(BOOL)useSwift;

/// Get color from a RatingInput element (returns enum raw value)
+ (NSInteger)getRatingInputColor:(id)element useSwift:(BOOL)useSwift;

#pragma mark - RatingLabel Property Bridge

/// Get value from a RatingLabel element
+ (double)getRatingLabelValue:(id)element useSwift:(BOOL)useSwift;

/// Get max from a RatingLabel element
+ (double)getRatingLabelMax:(id)element useSwift:(BOOL)useSwift;

/// Get count from a RatingLabel element (nullable)
+ (NSNumber *_Nullable)getRatingLabelCount:(id)element useSwift:(BOOL)useSwift;

/// Get horizontal alignment from a RatingLabel element (returns enum raw value)
+ (NSInteger)getRatingLabelHorizontalAlignment:(id)element useSwift:(BOOL)useSwift;

/// Get size from a RatingLabel element (returns enum raw value)
+ (NSInteger)getRatingLabelSize:(id)element useSwift:(BOOL)useSwift;

/// Get color from a RatingLabel element (returns enum raw value)
+ (NSInteger)getRatingLabelColor:(id)element useSwift:(BOOL)useSwift;

/// Get style from a RatingLabel element (returns enum raw value)
+ (NSInteger)getRatingLabelStyle:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Icon Property Bridge

/// Get name from an Icon element
+ (NSString *)getIconName:(id)element useSwift:(BOOL)useSwift;

/// Get foreground color from an Icon element (returns enum raw value)
+ (NSInteger)getIconForegroundColor:(id)element useSwift:(BOOL)useSwift;

/// Get size from an Icon element (returns enum raw value)
+ (NSInteger)getIconSize:(id)element useSwift:(BOOL)useSwift;

/// Get style from an Icon element (returns enum raw value)
+ (NSInteger)getIconStyle:(id)element useSwift:(BOOL)useSwift;

/// Get select action from an Icon element (nullable)
+ (id _Nullable)getIconSelectAction:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Media Property Bridge

/// Get poster from a Media element
+ (NSString *)getMediaPoster:(id)element useSwift:(BOOL)useSwift;

/// Get alt text from a Media element
+ (NSString *)getMediaAltText:(id)element useSwift:(BOOL)useSwift;

/// Get sources array from a Media element
+ (NSArray *)getMediaSources:(id)element useSwift:(BOOL)useSwift;

/// Get caption sources array from a Media element
+ (NSArray *)getMediaCaptionSources:(id)element useSwift:(BOOL)useSwift;

/// Get URL from a MediaSource element
+ (NSString *)getMediaSourceUrl:(id)element useSwift:(BOOL)useSwift;

/// Get MIME type from a MediaSource element
+ (NSString *)getMediaSourceMimeType:(id)element useSwift:(BOOL)useSwift;

#pragma mark - CompoundButton Property Bridge

/// Get badge from a CompoundButton element
+ (NSString *)getCompoundButtonBadge:(id)element useSwift:(BOOL)useSwift;

/// Get title from a CompoundButton element
+ (NSString *)getCompoundButtonTitle:(id)element useSwift:(BOOL)useSwift;

/// Get description from a CompoundButton element
+ (NSString *)getCompoundButtonDescription:(id)element useSwift:(BOOL)useSwift;

/// Get icon from a CompoundButton element (nullable)
+ (id _Nullable)getCompoundButtonIcon:(id)element useSwift:(BOOL)useSwift;

/// Get select action from a CompoundButton element (nullable)
+ (id _Nullable)getCompoundButtonSelectAction:(id)element useSwift:(BOOL)useSwift;

#pragma mark - RichTextBlock Property Bridge

/// Get horizontal alignment from a RichTextBlock element (returns enum raw value)
+ (NSInteger)getRichTextBlockHorizontalAlignment:(id)element useSwift:(BOOL)useSwift;

/// Get inlines array from a RichTextBlock element
+ (NSArray *)getRichTextBlockInlines:(id)element useSwift:(BOOL)useSwift;

#pragma mark - TextRun Property Bridge

/// Get text from a TextRun element
+ (NSString *)getTextRunText:(id)element useSwift:(BOOL)useSwift;

/// Get text size from a TextRun element (returns enum raw value)
+ (NSInteger)getTextRunTextSize:(id)element useSwift:(BOOL)useSwift;

/// Get text weight from a TextRun element (returns enum raw value)
+ (NSInteger)getTextRunTextWeight:(id)element useSwift:(BOOL)useSwift;

/// Get text color from a TextRun element (returns enum raw value)
+ (NSInteger)getTextRunTextColor:(id)element useSwift:(BOOL)useSwift;

/// Get isSubtle from a TextRun element (nullable)
+ (NSNumber *_Nullable)getTextRunIsSubtle:(id)element useSwift:(BOOL)useSwift;

/// Get italic from a TextRun element
+ (BOOL)getTextRunItalic:(id)element useSwift:(BOOL)useSwift;

/// Get strikethrough from a TextRun element
+ (BOOL)getTextRunStrikethrough:(id)element useSwift:(BOOL)useSwift;

/// Get highlight from a TextRun element
+ (BOOL)getTextRunHighlight:(id)element useSwift:(BOOL)useSwift;

/// Get underline from a TextRun element
+ (BOOL)getTextRunUnderline:(id)element useSwift:(BOOL)useSwift;

/// Get select action from a TextRun element (nullable)
+ (id _Nullable)getTextRunSelectAction:(id)element useSwift:(BOOL)useSwift;

#pragma mark - Unknown Element/Action Property Bridge

/// Get type string from an UnknownAction element
+ (NSString *)getUnknownActionTypeString:(id)element useSwift:(BOOL)useSwift;

/// Get type string from an UnknownElement
+ (NSString *)getUnknownElementTypeString:(id)element useSwift:(BOOL)useSwift;

/// Get additional properties from an UnknownElement as JSON string
+ (NSString *)getUnknownElementAdditionalPropertiesJson:(id)element useSwift:(BOOL)useSwift;

@end

NS_ASSUME_NONNULL_END
