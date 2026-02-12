//
//  SwiftAdaptiveCardBridge.swift
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 3/3/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

public protocol Convertible {
    associatedtype Target
    func convert() -> Target
}

extension Array where Element: Convertible {
    func convert() -> [Element.Target] {
        return self.map { $0.convert() }
    }
}

@objcMembers
public class SwiftAdaptiveCardParseResult: NSObject {
    public var parseResult: SwiftParseResult?
    public var errors: [NSError]?
    public var warnings: [ACRParseWarning]?
}

@objcMembers
public class SwiftAdaptiveCardParser: NSObject {
    public static let main = SwiftAdaptiveCardParser()
    
    private var swiftParserEnabled = false
    
    // Toggle by ECS flag
    public static func setSwiftParserEnabled(_ isEnabled: Bool) {
        main.swiftParserEnabled = isEnabled
    }
    
    public static func isSwiftParserEnabled() -> Bool {
        return main.swiftParserEnabled
    }
    
    public static func parse(payload: String) -> SwiftAdaptiveCardParseResult {
        let result = SwiftAdaptiveCardParseResult()
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(payload, version: "1.6")
            result.parseResult = parseResult
            result.warnings = parseResult.warnings.convert()
        } catch {
            // Capture the error instead of returning nil
            let nsError = error as NSError
            result.errors = [nsError]
            result.parseResult = nil
            result.warnings = []
        }
        
        return result
    }
}

// MARK: - ACRParseWarning
extension SwiftAdaptiveCardParseWarning: Convertible {
    public typealias Target = ACRParseWarning

    public func convert() -> ACRParseWarning {
        return .createWithStatusCode(getStatusCode().convert().rawValue, reason: getReason())
    }
}

extension SwiftWarningStatusCode: Convertible {
    public typealias Target = ACRWarningStatusCode

    public func convert() -> ACRWarningStatusCode {
        switch self {
        case .unknownElementType: .unknownElementType
        case .unknownActionElementType: .unknownActionElementType
        case .unknownPropertyOnElement: .unknownPropertyOnElement
        case .unknownEnumValue: .unknownEnumValue
        case .noRendererForType: .noRendererForType
        case .interactivityNotSupported: .interactivityNotSupported
        case .maxActionsExceeded: .maxActionsExceeded
        case .assetLoadFailed: .assetLoadFailed
        case .unsupportedSchemaVersion: .unsupportedSchemaVersion
        case .unsupportedMediaType: .unsupportedMediaType
        case .invalidMediaMix: .invalidMediaMix
        case .invalidColorFormat: .invalidColorFormat
        case .invalidDimensionSpecified: .invalidDimensionSpecified
        case .invalidLanguage: .invalidLanguage
        case .invalidValue: .invalidValue
        case .customWarning: .customWarning
        case .emptyLabelInRequiredInput: .unknownPropertyOnElement
        case .requiredPropertyMissing: .missingInputErrorMessage
        }
    }
}

// Swift subclass of ACRParseWarning
@objc public class ACRSwiftParseWarning: ACRParseWarning {
    // These properties will override the readonly properties from the parent
    private var _statusCode: ACRWarningStatusCode
    private var _reason: String
    
    @objc override public var statusCode: ACRWarningStatusCode {
        return _statusCode
    }
    
    @objc override public var reason: String {
        return _reason
    }
    
    @objc public init(statusCode: ACRWarningStatusCode, reason: String) {
        self._statusCode = statusCode
        self._reason = reason
        super.init()
    }
}

// Extension to add factory method to ACRParseWarning
@objc extension ACRParseWarning {
    // Factory method that creates and returns the Swift subclass
    @objc public class func createWithStatusCode(_ statusCode: UInt, reason: String) -> ACRParseWarning {
        return ACRSwiftParseWarning(
            statusCode: ACRWarningStatusCode(rawValue: statusCode) ?? .unknownElementType,
            reason: reason
        )
    }
}

// MARK: - Element Property Accessor

/// Provides ObjC-compatible accessor methods for Swift Adaptive Card elements.
/// This class bridges Swift element properties to ObjC callers.
@objcMembers
public class SwiftElementPropertyAccessor: NSObject {
    
    // MARK: - Element Type
    
    /// Get the type string from any Swift element
    @objc public static func getTypeString(from element: Any) -> String {
        if let baseElement = element as? SwiftBaseCardElement {
            return baseElement.typeString
        }
        return "Unknown"
    }
    
    // MARK: - TextBlock Properties
    
    /// Get text from a SwiftTextBlock
    @objc public static func getTextBlockText(_ element: Any) -> String {
        if let textBlock = element as? SwiftTextBlock {
            return textBlock.text
        }
        return ""
    }
    
    /// Get wrap setting from a SwiftTextBlock
    @objc public static func getTextBlockWrap(_ element: Any) -> Bool {
        if let textBlock = element as? SwiftTextBlock {
            return textBlock.wrap
        }
        return false
    }
    
    /// Get maxLines from a SwiftTextBlock
    @objc public static func getTextBlockMaxLines(_ element: Any) -> UInt {
        if let textBlock = element as? SwiftTextBlock {
            return textBlock.maxLines
        }
        return 0
    }
    
    /// Get horizontal alignment from a SwiftTextBlock as index
    /// Returns: 0=left, 1=center, 2=right (matches C++ enum order)
    @objc public static func getTextBlockHorizontalAlignment(_ element: Any) -> Int {
        if let textBlock = element as? SwiftTextBlock,
           let alignment = textBlock.horizontalAlignment {
            switch alignment {
            case .left: return 0
            case .center: return 1
            case .right: return 2
            }
        }
        return 0 // Default to left
    }
    
    // MARK: - Image Properties
    
    /// Get URL from a SwiftImage
    @objc public static func getImageUrl(_ element: Any) -> String {
        if let image = element as? SwiftImage {
            return image.url
        }
        return ""
    }
    
    /// Get alt text from a SwiftImage
    @objc public static func getImageAltText(_ element: Any) -> String {
        if let image = element as? SwiftImage {
            return image.altText
        }
        return ""
    }
    
    /// Get image size from a SwiftImage as index
    /// Returns: 0=none, 1=auto, 2=stretch, 3=small, 4=medium, 5=large (matches C++ enum order)
    @objc public static func getImageSize(_ element: Any) -> Int {
        if let image = element as? SwiftImage {
            switch image.imageSize {
            case .none: return 0
            case .auto: return 1
            case .stretch: return 2
            case .small: return 3
            case .medium: return 4
            case .large: return 5
            }
        }
        return 0 // Default to none
    }
    
    // MARK: - Container Properties
    
    /// Get items from a SwiftContainer
    @objc public static func getContainerItems(_ element: Any) -> [Any] {
        if let container = element as? SwiftContainer {
            return container.items
        }
        return []
    }
    
    /// Get style from a SwiftContainer as index
    /// Returns: 0=none, 1=default, 2=emphasis, 3=good, 4=attention, 5=warning, 6=accent
    @objc public static func getContainerStyle(_ element: Any) -> Int {
        if let container = element as? SwiftContainer {
            switch container.style {
            case .none: return 0
            case .`default`: return 1
            case .emphasis: return 2
            case .good: return 3
            case .attention: return 4
            case .warning: return 5
            case .accent: return 6
            }
        }
        return 1 // Default to "default" style
    }
    
    // MARK: - FactSet Properties

    @objc public static func getFactSetFacts(_ element: Any) -> [Any] {
        if let factSet = element as? SwiftFactSet {
            return factSet.facts
        }
        return []
    }

    // MARK: - Fact Properties

    @objc public static func getFactTitle(_ element: Any) -> String {
        if let fact = element as? SwiftFact {
            return fact.title
        }
        return ""
    }

    @objc public static func getFactValue(_ element: Any) -> String {
        if let fact = element as? SwiftFact {
            return fact.value
        }
        return ""
    }

    // MARK: - ImageSet Properties

    /// Get images array from a SwiftImageSet
    @objc public static func getImageSetImages(_ element: Any) -> [Any] {
        if let imageSet = element as? SwiftImageSet {
            return imageSet.images
        }
        return []
    }

    /// Get image size from a SwiftImageSet as index
    /// Returns: 0=none, 1=auto, 2=stretch, 3=small, 4=medium, 5=large
    @objc public static func getImageSetImageSize(_ element: Any) -> Int {
        if let imageSet = element as? SwiftImageSet {
            switch imageSet.imageSize {
            case .none: return 0
            case .auto: return 1
            case .stretch: return 2
            case .small: return 3
            case .medium: return 4
            case .large: return 5
            }
        }
        return 1 // Default to auto
    }
    
    // MARK: - ActionSet Properties
    
    /// Get actions array from a SwiftActionSet
    @objc public static func getActionSetActions(_ element: Any) -> [Any] {
        if let actionSet = element as? SwiftActionSet {
            return actionSet.actions
        }
        return []
    }
    
    /// Get orientation from a SwiftActionSet as index
    /// Returns: 0=horizontal, 1=vertical
    @objc public static func getActionSetOrientation(_ element: Any) -> Int {
        // ActionSet defaults to horizontal orientation (0)
        // Vertical would be 1 if the element had an orientation property
        if element is SwiftActionSet {
            return 0 // Default to horizontal
        }
        return 0
    }
    
    // MARK: - ColumnSet Properties
    
    /// Get columns array from a SwiftColumnSet
    @objc public static func getColumnSetColumns(_ element: Any) -> [Any] {
        if let columnSet = element as? SwiftColumnSet {
            return columnSet.columns
        }
        return []
    }
    
    // MARK: - Column Properties
    
    /// Get width string from a SwiftColumn
    @objc public static func getColumnWidth(_ element: Any) -> String {
        if let column = element as? SwiftColumn {
            return column.width
        }
        return "auto"
    }
    
    /// Get items array from a SwiftColumn
    @objc public static func getColumnItems(_ element: Any) -> [Any] {
        if let column = element as? SwiftColumn {
            return column.items
        }
        return []
    }
    
    /// Get vertical content alignment from a SwiftColumn as index
    /// Returns: 0=top, 1=center, 2=bottom
    @objc public static func getColumnVerticalContentAlignment(_ element: Any) -> Int {
        if let column = element as? SwiftColumn,
           let alignment = column.verticalContentAlignment {
            switch alignment {
            case .top: return 0
            case .center: return 1
            case .bottom: return 2
            }
        }
        return 0 // Default to top
    }
    
    // MARK: - Table Properties
    
    /// Get column definitions array from a SwiftTable
    @objc public static func getTableColumns(_ element: Any) -> [Any] {
        if let table = element as? SwiftTable {
            return table.columnDefinitions
        }
        return []
    }
    
    /// Get rows array from a SwiftTable
    @objc public static func getTableRows(_ element: Any) -> [Any] {
        if let table = element as? SwiftTable {
            return table.rows
        }
        return []
    }
    
    /// Get showGridLines from a SwiftTable
    @objc public static func getTableShowGridLines(_ element: Any) -> Bool {
        if let table = element as? SwiftTable {
            return table.showGridLines
        }
        return true
    }
    
    // MARK: - TableRow Properties
    
    /// Get cells array from a SwiftTableRow
    @objc public static func getTableRowCells(_ element: Any) -> [Any] {
        if let tableRow = element as? SwiftTableRow {
            return tableRow.cells
        }
        return []
    }
    
    // MARK: - TableCell Properties
    
    /// Get items array from a SwiftTableCell
    @objc public static func getTableCellItems(_ element: Any) -> [Any] {
        if let tableCell = element as? SwiftTableCell {
            return tableCell.items
        }
        return []
    }
    
    // MARK: - Action Element Properties
    
    /// Get URL from a SwiftOpenUrlAction
    @objc public static func getOpenUrlActionUrl(_ element: Any) -> String {
        if let action = element as? SwiftOpenUrlAction {
            return action.url
        }
        return ""
    }
    
    /// Get data from a SwiftSubmitAction
    @objc public static func getSubmitActionData(_ element: Any) -> Any? {
        if let action = element as? SwiftSubmitAction {
            return action.dataJson
        }
        return nil
    }
    
    /// Get verb from a SwiftExecuteAction
    @objc public static func getExecuteActionVerb(_ element: Any) -> String {
        if let action = element as? SwiftExecuteAction {
            return action.verb
        }
        return ""
    }
    
    /// Get card from a SwiftShowCardAction
    @objc public static func getShowCardActionCard(_ element: Any) -> Any? {
        if let action = element as? SwiftShowCardAction {
            return action.card
        }
        return nil
    }
    
    /// Get target elements array from a SwiftToggleVisibilityAction
    @objc public static func getToggleVisibilityTargets(_ element: Any) -> [Any] {
        if let action = element as? SwiftToggleVisibilityAction {
            return action.targetElements
        }
        return []
    }

    /// Get title from a SwiftBaseActionElement (including PopoverAction)
    @objc public static func getPopoverActionTitle(_ element: Any) -> String {
        if let action = element as? SwiftBaseActionElement {
            return action.title
        }
        return ""
    }
    
    // MARK: - Input Element Properties
    
    /// Get placeholder from a SwiftTextInput
    @objc public static func getTextInputPlaceholder(_ element: Any) -> String {
        if let textInput = element as? SwiftTextInput {
            return textInput.placeholder ?? ""
        }
        return ""
    }
    
    /// Get value from a SwiftTextInput
    @objc public static func getTextInputValue(_ element: Any) -> String {
        if let textInput = element as? SwiftTextInput {
            return textInput.value ?? ""
        }
        return ""
    }
    
    /// Get isMultiline from a SwiftTextInput
    @objc public static func getTextInputIsMultiline(_ element: Any) -> Bool {
        if let textInput = element as? SwiftTextInput {
            return textInput.isMultiline
        }
        return false
    }
    
    /// Get value from a SwiftNumberInput
    @objc public static func getNumberInputValue(_ element: Any) -> Double {
        if let numberInput = element as? SwiftNumberInput {
            return numberInput.value ?? 0.0
        }
        return 0.0
    }
    
    /// Get value from a SwiftDateInput
    @objc public static func getDateInputValue(_ element: Any) -> String {
        if let dateInput = element as? SwiftDateInput {
            return dateInput.value ?? ""
        }
        return ""
    }
    
    /// Get value from a SwiftTimeInput
    @objc public static func getTimeInputValue(_ element: Any) -> String {
        if let timeInput = element as? SwiftTimeInput {
            return timeInput.value ?? ""
        }
        return ""
    }
    
    /// Get title from a SwiftToggleInput
    @objc public static func getToggleInputTitle(_ element: Any) -> String {
        if let toggleInput = element as? SwiftToggleInput {
            return toggleInput.title ?? ""
        }
        return ""
    }
    
    /// Get choices array from a SwiftChoiceSetInput
    @objc public static func getChoiceSetInputChoices(_ element: Any) -> [Any] {
        if let choiceSetInput = element as? SwiftChoiceSetInput {
            return choiceSetInput.choices
        }
        return []
    }
    
    // MARK: - Carousel Properties
    
    /// Get pages array from a SwiftCarousel
    @objc public static func getCarouselPages(_ element: Any) -> [Any] {
        if let carousel = element as? SwiftCarousel {
            return carousel.pages
        }
        return []
    }
    
    /// Get items array from a SwiftCarouselPage
    @objc public static func getCarouselPageItems(_ element: Any) -> [Any] {
        if let carouselPage = element as? SwiftCarouselPage {
            return carouselPage.items
        }
        return []
    }
    
    // MARK: - Badge Properties
    
    /// Get text from a SwiftBadge
    @objc public static func getBadgeText(_ element: Any) -> String {
        if let badge = element as? SwiftBadge {
            return badge.text
        }
        return ""
    }
    
    /// Get style from a SwiftBadge as Int enum index
    @objc public static func getBadgeStyle(_ element: Any) -> Int {
        if let badge = element as? SwiftBadge {
            switch badge.badgeStyle {
            case .`default`: return 0
            case .accent: return 1
            case .good: return 2
            case .attention: return 3
            case .warning: return 4
            case .informative: return 5
            case .subtle: return 6
            }
        }
        return 0 // Default
    }
    
    // MARK: - Progress Properties
    
    /// Get value from a SwiftProgressBar
    @objc public static func getProgressBarValue(_ element: Any) -> Double {
        if let progressBar = element as? SwiftProgressBar {
            return progressBar.value ?? 0.0
        }
        return 0.0
    }
    
    /// Get label from a SwiftProgressRing
    @objc public static func getProgressRingLabel(_ element: Any) -> String {
        if let progressRing = element as? SwiftProgressRing {
            return progressRing.label
        }
        return ""
    }

    // MARK: - RatingInput Properties

    /// Get value from a SwiftRatingInput
    @objc public static func getRatingInputValue(_ element: Any) -> Double {
        if let ratingInput = element as? SwiftRatingInput {
            return ratingInput.value
        }
        return 0.0
    }

    /// Get max from a SwiftRatingInput
    @objc public static func getRatingInputMax(_ element: Any) -> Double {
        if let ratingInput = element as? SwiftRatingInput {
            return ratingInput.max
        }
        return 5.0
    }

    /// Get horizontal alignment from a SwiftRatingInput as index
    /// Returns: 0=left, 1=center, 2=right
    @objc public static func getRatingInputHorizontalAlignment(_ element: Any) -> Int {
        if let ratingInput = element as? SwiftRatingInput,
           let alignment = ratingInput.horizontalAlignment {
            switch alignment {
            case .left: return 0
            case .center: return 1
            case .right: return 2
            }
        }
        return 0 // Default to left
    }

    /// Get size from a SwiftRatingInput as index
    /// Returns: 0=medium, 1=large
    @objc public static func getRatingInputSize(_ element: Any) -> Int {
        if let ratingInput = element as? SwiftRatingInput {
            switch ratingInput.size {
            case .medium: return 0
            case .large: return 1
            }
        }
        return 0 // Default to medium
    }

    /// Get color from a SwiftRatingInput as index
    /// Returns: 0=neutral, 1=marigold
    @objc public static func getRatingInputColor(_ element: Any) -> Int {
        if let ratingInput = element as? SwiftRatingInput {
            switch ratingInput.color {
            case .neutral: return 0
            case .marigold: return 1
            }
        }
        return 0 // Default to neutral
    }

    // MARK: - RatingLabel Properties

    /// Get value from a SwiftRatingLabel
    @objc public static func getRatingLabelValue(_ element: Any) -> Double {
        if let ratingLabel = element as? SwiftRatingLabel {
            return ratingLabel.value
        }
        return 0.0
    }

    /// Get max from a SwiftRatingLabel
    @objc public static func getRatingLabelMax(_ element: Any) -> Double {
        if let ratingLabel = element as? SwiftRatingLabel {
            return ratingLabel.max
        }
        return 5.0
    }

    /// Get count from a SwiftRatingLabel (nil if not set)
    @objc public static func getRatingLabelCount(_ element: Any) -> NSNumber? {
        if let ratingLabel = element as? SwiftRatingLabel,
           let count = ratingLabel.count {
            return NSNumber(value: count)
        }
        return nil
    }

    /// Get horizontal alignment from a SwiftRatingLabel as index
    /// Returns: 0=left, 1=center, 2=right
    @objc public static func getRatingLabelHorizontalAlignment(_ element: Any) -> Int {
        if let ratingLabel = element as? SwiftRatingLabel,
           let alignment = ratingLabel.horizontalAlignment {
            switch alignment {
            case .left: return 0
            case .center: return 1
            case .right: return 2
            }
        }
        return 0 // Default to left
    }

    /// Get size from a SwiftRatingLabel as index
    /// Returns: 0=medium, 1=large
    @objc public static func getRatingLabelSize(_ element: Any) -> Int {
        if let ratingLabel = element as? SwiftRatingLabel {
            switch ratingLabel.size {
            case .medium: return 0
            case .large: return 1
            }
        }
        return 0 // Default to medium
    }

    /// Get color from a SwiftRatingLabel as index
    /// Returns: 0=neutral, 1=marigold
    @objc public static func getRatingLabelColor(_ element: Any) -> Int {
        if let ratingLabel = element as? SwiftRatingLabel {
            switch ratingLabel.color {
            case .neutral: return 0
            case .marigold: return 1
            }
        }
        return 0 // Default to neutral
    }

    /// Get style from a SwiftRatingLabel as index
    /// Returns: 0=default, 1=compact
    @objc public static func getRatingLabelStyle(_ element: Any) -> Int {
        if let ratingLabel = element as? SwiftRatingLabel {
            switch ratingLabel.style {
            case .default: return 0
            case .compact: return 1
            }
        }
        return 0 // Default
    }

    // MARK: - Icon Properties

    /// Get name from a SwiftIcon
    @objc public static func getIconName(_ element: Any) -> String {
        if let icon = element as? SwiftIcon {
            return icon.name ?? ""
        }
        return ""
    }

    /// Get foreground color from a SwiftIcon as index
    /// Returns: 0=default, 1=dark, 2=light, 3=accent, 4=good, 5=warning, 6=attention
    @objc public static func getIconForegroundColor(_ element: Any) -> Int {
        if let icon = element as? SwiftIcon {
            switch icon.foregroundColor {
            case .default: return 0
            case .dark: return 1
            case .light: return 2
            case .accent: return 3
            case .good: return 4
            case .warning: return 5
            case .attention: return 6
            }
        }
        return 0 // Default
    }

    /// Get size from a SwiftIcon as index
    /// Returns: 0=standard (xxSmall), 1=xSmall, 2=small, 3=medium, 4=large, 5=xLarge, 6=xxLarge
    @objc public static func getIconSize(_ element: Any) -> Int {
        if let icon = element as? SwiftIcon {
            switch icon.iconSize {
            case .xxSmall: return 0
            case .xSmall: return 1
            case .small: return 2
            case .standard: return 3
            case .medium: return 4
            case .large: return 5
            case .xLarge: return 6
            case .xxLarge: return 7
            }
        }
        return 3 // Default to standard
    }

    /// Get style from a SwiftIcon as index
    /// Returns: 0=regular, 1=filled
    @objc public static func getIconStyle(_ element: Any) -> Int {
        if let icon = element as? SwiftIcon {
            switch icon.iconStyle {
            case .regular: return 0
            case .filled: return 1
            }
        }
        return 0 // Default to regular
    }

    /// Get select action from a SwiftIcon
    @objc public static func getIconSelectAction(_ element: Any) -> Any? {
        if let icon = element as? SwiftIcon {
            return icon.selectAction
        }
        return nil
    }

    // MARK: - Media Properties

    /// Get poster from a SwiftMedia
    @objc public static func getMediaPoster(_ element: Any) -> String {
        if let media = element as? SwiftMedia {
            return media.poster ?? ""
        }
        return ""
    }

    /// Get alt text from a SwiftMedia
    @objc public static func getMediaAltText(_ element: Any) -> String {
        if let media = element as? SwiftMedia {
            return media.altText ?? ""
        }
        return ""
    }

    /// Get sources from a SwiftMedia
    @objc public static func getMediaSources(_ element: Any) -> [Any] {
        if let media = element as? SwiftMedia {
            return media.sources
        }
        return []
    }

    /// Get caption sources from a SwiftMedia
    @objc public static func getMediaCaptionSources(_ element: Any) -> [Any] {
        if let media = element as? SwiftMedia {
            return media.captionSources
        }
        return []
    }

    /// Get URL from a SwiftMediaSource
    @objc public static func getMediaSourceUrl(_ element: Any) -> String {
        if let mediaSource = element as? SwiftMediaSource {
            return mediaSource.url
        }
        return ""
    }

    /// Get MIME type from a SwiftMediaSource
    @objc public static func getMediaSourceMimeType(_ element: Any) -> String {
        if let mediaSource = element as? SwiftMediaSource {
            return mediaSource.mimeType ?? ""
        }
        return ""
    }

    // MARK: - CompoundButton Properties

    /// Get badge from a SwiftCompoundButton
    @objc public static func getCompoundButtonBadge(_ element: Any) -> String {
        if let compoundButton = element as? SwiftCompoundButton {
            return compoundButton.badge ?? ""
        }
        return ""
    }

    /// Get title from a SwiftCompoundButton
    @objc public static func getCompoundButtonTitle(_ element: Any) -> String {
        if let compoundButton = element as? SwiftCompoundButton {
            return compoundButton.title ?? ""
        }
        return ""
    }

    /// Get description from a SwiftCompoundButton
    @objc public static func getCompoundButtonDescription(_ element: Any) -> String {
        if let compoundButton = element as? SwiftCompoundButton {
            return compoundButton.buttonDescription ?? ""
        }
        return ""
    }

    /// Get icon info from a SwiftCompoundButton
    @objc public static func getCompoundButtonIcon(_ element: Any) -> Any? {
        if let compoundButton = element as? SwiftCompoundButton {
            return compoundButton.icon
        }
        return nil
    }

    /// Get select action from a SwiftCompoundButton
    @objc public static func getCompoundButtonSelectAction(_ element: Any) -> Any? {
        if let compoundButton = element as? SwiftCompoundButton {
            return compoundButton.selectAction
        }
        return nil
    }

    // MARK: - RichTextBlock Properties

    /// Get horizontal alignment from a SwiftRichTextBlock as index
    /// Returns: 0=left, 1=center, 2=right
    @objc public static func getRichTextBlockHorizontalAlignment(_ element: Any) -> Int {
        if let richTextBlock = element as? SwiftRichTextBlock,
           let alignment = richTextBlock.horizontalAlignment {
            switch alignment {
            case .left: return 0
            case .center: return 1
            case .right: return 2
            }
        }
        return 0 // Default to left
    }

    /// Get inlines from a SwiftRichTextBlock
    @objc public static func getRichTextBlockInlines(_ element: Any) -> [Any] {
        if let richTextBlock = element as? SwiftRichTextBlock {
            return richTextBlock.inlines
        }
        return []
    }

    // MARK: - TextRun Properties (for RichTextBlock inlines)

    /// Get text from a SwiftTextRun
    @objc public static func getTextRunText(_ element: Any) -> String {
        if let textRun = element as? SwiftTextRun {
            return textRun.text
        }
        return ""
    }

    /// Get text size from a SwiftTextRun as index
    /// Returns: 0=default, 1=small, 2=medium, 3=large, 4=extraLarge
    @objc public static func getTextRunTextSize(_ element: Any) -> Int {
        if let textRun = element as? SwiftTextRun,
           let size = textRun.textSize {
            switch size {
            case .defaultSize: return 0
            case .small: return 1
            case .medium: return 2
            case .large: return 3
            case .extraLarge: return 4
            }
        }
        return 0 // Default
    }

    /// Get text weight from a SwiftTextRun as index
    /// Returns: 0=default, 1=lighter, 2=bolder
    @objc public static func getTextRunTextWeight(_ element: Any) -> Int {
        if let textRun = element as? SwiftTextRun,
           let weight = textRun.textWeight {
            switch weight {
            case .defaultWeight: return 0
            case .lighter: return 1
            case .bolder: return 2
            }
        }
        return 0 // Default
    }

    /// Get text color from a SwiftTextRun as index
    /// Returns: 0=default, 1=dark, 2=light, 3=accent, 4=good, 5=warning, 6=attention
    @objc public static func getTextRunTextColor(_ element: Any) -> Int {
        if let textRun = element as? SwiftTextRun,
           let color = textRun.textColor {
            switch color {
            case .default: return 0
            case .dark: return 1
            case .light: return 2
            case .accent: return 3
            case .good: return 4
            case .warning: return 5
            case .attention: return 6
            }
        }
        return 0 // Default
    }

    /// Get isSubtle from a SwiftTextRun
    @objc public static func getTextRunIsSubtle(_ element: Any) -> NSNumber? {
        if let textRun = element as? SwiftTextRun,
           let isSubtle = textRun.isSubtle {
            return NSNumber(value: isSubtle)
        }
        return nil
    }

    /// Get italic from a SwiftTextRun
    @objc public static func getTextRunItalic(_ element: Any) -> Bool {
        if let textRun = element as? SwiftTextRun {
            return textRun.italic
        }
        return false
    }

    /// Get strikethrough from a SwiftTextRun
    @objc public static func getTextRunStrikethrough(_ element: Any) -> Bool {
        if let textRun = element as? SwiftTextRun {
            return textRun.strikethrough
        }
        return false
    }

    /// Get highlight from a SwiftTextRun
    @objc public static func getTextRunHighlight(_ element: Any) -> Bool {
        if let textRun = element as? SwiftTextRun {
            return textRun.highlight
        }
        return false
    }

    /// Get underline from a SwiftTextRun
    @objc public static func getTextRunUnderline(_ element: Any) -> Bool {
        if let textRun = element as? SwiftTextRun {
            return textRun.underline
        }
        return false
    }

    /// Get select action from a SwiftTextRun
    @objc public static func getTextRunSelectAction(_ element: Any) -> Any? {
        if let textRun = element as? SwiftTextRun {
            return textRun.selectAction
        }
        return nil
    }
    
    // MARK: - Unknown Element/Action Properties
    
    /// Get type string from a SwiftUnknownAction
    @objc public static func getUnknownActionTypeString(_ element: Any) -> String {
        if let unknownAction = element as? SwiftUnknownAction {
            return unknownAction.typeString
        }
        return ""
    }
    
    /// Get type string from a SwiftUnknownElement
    @objc public static func getUnknownElementTypeString(_ element: Any) -> String {
        if let unknownElement = element as? SwiftUnknownElement {
            return unknownElement.typeString
        }
        return ""
    }
    
    /// Get additional properties from a SwiftUnknownElement as JSON string
    @objc public static func getUnknownElementAdditionalPropertiesJson(_ element: Any) -> String {
        if let unknownElement = element as? SwiftUnknownElement,
           let props = unknownElement.additionalProperties {
            // Convert SwiftAnyCodable dictionary to regular dictionary and serialize to JSON
            let regularDict = props.mapValues { $0.value }
            if let jsonData = try? JSONSerialization.data(withJSONObject: regularDict, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return ""
    }
}
