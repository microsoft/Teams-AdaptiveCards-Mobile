//
//  SwiftActionElementParser.swift
//  SwiftAdaptiveCards
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import Foundation

protocol SwiftActionElementParser {
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> SwiftAdaptiveCardElementProtocol
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> SwiftAdaptiveCardElementProtocol
}

final class SwiftActionElementParserWrapper: SwiftActionElementParser {
    private let parser: SwiftActionElementParser
    var actualParser: SwiftActionElementParser { return parser }
    
    init(parser: SwiftActionElementParser) {
        self.parser = parser
    }
    
    func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> SwiftAdaptiveCardElementProtocol {
        guard let idProperty = json["id"] as? String else {
            throw SwiftAdaptiveCardParseException(
                statusCode: .requiredPropertyMissing,
                message: "Missing id property")
        }
        context.pushElement(idJsonProperty: idProperty, internalId: SwiftInternalId.next())
        let element = try parser.deserialize(context: context, from: json)
        context.popElement()
        return element
    }
    
    func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> SwiftAdaptiveCardElementProtocol {
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw SwiftAdaptiveCardParseException(
                statusCode: .invalidJson,
                message: "Invalid JSON string")
        }
        return try deserialize(context: context, from: json)
    }
}

final class ActionParserRegistration {
    private var knownElements: Set<String> = []
    private var cardElementParsers: [String: SwiftActionElementParser] = [:]

    init() {
        let defaultParsers: [(String, SwiftActionElementParser)] = [
            (SwiftActionType.execute.rawValue, SwiftExecuteActionParser()),
            (SwiftActionType.openUrl.rawValue, OpenUrlActionParser()),
            (SwiftActionType.showCard.rawValue, SwiftShowCardActionParser()),
            (SwiftActionType.submit.rawValue, SubmitActionParser()),
            (SwiftActionType.toggleVisibility.rawValue, ToggleVisibilityActionParser()),
            (SwiftActionType.unknownAction.rawValue, UnknownActionParser())
        ]

        for (key, parser) in defaultParsers {
            knownElements.insert(key)
            cardElementParsers[key] = parser
        }
    }

    func addParser(for elementType: String, parser: SwiftActionElementParser) throws {
        guard !knownElements.contains(elementType) else {
            throw SwiftAdaptiveCardParseException(statusCode: .unsupportedParserOverride, message: "Overriding known action parsers is unsupported")
        }
        cardElementParsers[elementType] = parser
    }

    func removeParser(for elementType: String) throws {
        guard !knownElements.contains(elementType) else {
            throw SwiftAdaptiveCardParseException(statusCode: .unsupportedParserOverride, message: "Removing known action parsers is unsupported")
        }
        cardElementParsers.removeValue(forKey: elementType)
    }

    func getParser(for elementType: String) -> SwiftActionElementParser? {
        guard let parser = cardElementParsers[elementType] else {
            return nil
        }
        return SwiftActionElementParserWrapper(parser: parser)
    }
}
