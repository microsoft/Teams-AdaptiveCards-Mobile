import Foundation

/// Protocol for parsing Adaptive Card elements.
protocol SwiftBaseCardElementParser {
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> SwiftAdaptiveCardElementProtocol
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> SwiftAdaptiveCardElementProtocol
}

/// Wrapper for a BaseCardElementParser.
struct SwiftBaseCardElementParserWrapper: SwiftBaseCardElementParser {
    private let parser: SwiftBaseCardElementParser
    var actualParser: SwiftBaseCardElementParser { return parser }
    
    init(parser: SwiftBaseCardElementParser) {
        self.parser = parser
    }
    
    func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> SwiftAdaptiveCardElementProtocol {
        let idProperty = value["id"] as? String ?? ""
        let internalId = SwiftInternalId.next()
        context.pushElement(idJsonProperty: idProperty, internalId: internalId)
        let element = try parser.deserialize(context: context, value: value)
        context.popElement()
        return element
    }
    
    func deserialize(fromString context: SwiftParseContext, value: String) throws -> SwiftAdaptiveCardElementProtocol {
        guard let jsonData = value.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let jsonDict = jsonObject as? [String: Any] else {
            throw AdaptiveCardParseError.invalidJson
        }
        return try deserialize(context: context, value: jsonDict)
    }
}

/// Manages the registration of element parsers.
struct SwiftElementParserRegistration {
    private var knownElements: Set<String> = []
    private var cardElementParsers: [String: SwiftBaseCardElementParser] = [:]

    init() {
        knownElements = [
            "ActionSet", "ChoiceSetInput", "Column", "ColumnSet", "CompoundButton",
            "Container", "DateInput", "FactSet", "Image", "Icon", "ImageSet",
            "Media", "NumberInput", "RatingInput", "RatingLabel", "RichTextBlock",
            "Table", "TextBlock", "TextInput", "TimeInput", "ToggleInput", "Unknown"
        ]

        cardElementParsers = [
            "ActionSet": SwiftActionSetParser(),
            "ChoiceSetInput": SwiftChoiceSetInputParser(),
            "Column": SwiftColumnParser(),
            "ColumnSet": SwiftColumnSetParser(),
            "Container": SwiftContainerParser(),
            "DateInput": SwiftDateInputParser(),
            "FactSet": SwiftFactSetParser(),
            "Image": SwiftImageParser(),
            "Icon": SwiftIconParser(),
            "ImageSet": SwiftImageSetParser(),
            "Media": SwiftMediaParser(),
            "NumberInput": SwiftNumberInputParser(),
            "RatingInput": SwiftRatingInputParser(),
            "RatingLabel": SwiftRatingLabelParser(),
            "RichTextBlock": SwiftRichTextBlockParser(),
            "Table": SwiftTableParser(),
            "TextBlock": SwiftTextBlockParser(),
            "TextInput": SwiftTextInputParser(),
            "TimeInput": SwiftTimeInputParser(),
            "ToggleInput": SwiftToggleInputParser(),
            "CompoundButton": SwiftCompoundButtonParser(),
            "Unknown": SwiftUnknownElementParser()
        ]
    }

    mutating func addParser(for elementType: String, parser: SwiftBaseCardElementParser) throws {
        guard !knownElements.contains(elementType) else {
            throw AdaptiveCardParseError.unsupportedParserOverride
        }
        cardElementParsers[elementType] = parser
    }

    mutating func removeParser(for elementType: String) throws {
        guard !knownElements.contains(elementType) else {
            throw AdaptiveCardParseError.unsupportedParserOverride
        }
        cardElementParsers.removeValue(forKey: elementType)
    }

    func getParser(for elementType: String) -> SwiftBaseCardElementParser? {
        guard let parser = cardElementParsers[elementType] else { return nil }
        return SwiftBaseCardElementParserWrapper(parser: parser)
    }
}

/// Error types for parsing Adaptive Cards.
enum AdaptiveCardParseError: Error {
    case invalidJson
    case renderFailed
    case requiredPropertyMissing
    case invalidPropertyValue
    case unsupportedParserOverride
    case idCollision
    case invalidType
    case customError
    case serializationFailed
}
