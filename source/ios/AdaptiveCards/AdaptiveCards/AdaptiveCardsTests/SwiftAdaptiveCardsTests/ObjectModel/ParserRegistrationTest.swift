//
//  ParserRegistrationTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import AdaptiveCards

class ParserRegistrationTests: XCTestCase {
    
    // A custom type that implements both element and action behavior.
    // Now it subclasses BaseActionElement—which conforms to AdaptiveCardElementProtocol.
    class TestCustomElement: SwiftBaseActionElement {
        var customImage: String
        
        init(json: [String: Any]) {
            self.customImage = json["customProperty"] as? String ?? ""
            // Call BaseActionElement initializer with ActionType.custom.
            super.init(type: SwiftActionType.custom)
        }
        
        // Provide the required initializer.
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customImage = try container.decode(String.self, forKey: .customImage)
            try super.init(from: decoder)
        }
        
        private enum CodingKeys: String, CodingKey {
            case customImage
        }
    }
    
    // Define a custom element parser.
    class TestCustomElementParser: SwiftBaseCardElementParser {
        func deserialize(context: SwiftParseContext, value: [String: Any]) throws -> SwiftAdaptiveCardElementProtocol {
            return TestCustomElement(json: value)
        }
        
        func deserialize(fromString context: SwiftParseContext, value: String) throws -> SwiftAdaptiveCardElementProtocol {
            let jsonValue = SwiftParseUtil.getJsonValue(from: value)
            return try deserialize(context: context, value: jsonValue)
        }
    }
    
    // Define a custom action parser.
    class TestCustomActionParser: SwiftActionElementParser {
        func deserialize(context: SwiftParseContext, from json: [String: Any]) throws -> SwiftAdaptiveCardElementProtocol {
            return TestCustomElement(json: json)
        }
        
        func deserialize(fromString jsonString: String, context: SwiftParseContext) throws -> SwiftAdaptiveCardElementProtocol {
            let jsonValue = SwiftParseUtil.getJsonValue(from: jsonString)
            return try deserialize(context: context, from: jsonValue)
        }
    }
    
    func testParserRegistration() {
        var actionParser = ActionParserRegistration()
        var elementParser = SwiftElementParserRegistration()
        
        let elemType = "notRegisteredYet"
        // Make sure we don't already have this parser.
        XCTAssertNil(actionParser.getParser(for: elemType))
        
        let customActionParser = TestCustomActionParser()
        let customElementParser = TestCustomElementParser()
        
        // Make sure we can't override a known parser.
        XCTAssertThrowsError(try actionParser.addParser(for: SwiftActionType.openUrl.rawValue, parser: customActionParser))
        XCTAssertThrowsError(try elementParser.addParser(for: SwiftCardElementType.container.rawValue, parser: customElementParser))
        
        // Add our new parser.
        XCTAssertNoThrow(try actionParser.addParser(for: elemType, parser: customActionParser))
        if let actionParserWrapper = actionParser.getParser(for: elemType) as? SwiftActionElementParserWrapper {
            XCTAssertTrue(actionParserWrapper.actualParser as AnyObject === customActionParser as AnyObject)
        } else {
            XCTFail("Custom action parser not registered correctly")
        }
        
        XCTAssertNoThrow(try elementParser.addParser(for: elemType, parser: customElementParser))
        if let cardParserWrapper = elementParser.getParser(for: elemType) as? SwiftBaseCardElementParserWrapper {
            XCTAssertTrue(cardParserWrapper.actualParser as AnyObject === customElementParser as AnyObject)
        } else {
            XCTFail("Custom element parser not registered correctly")
        }
        
        // Overwrite our new parser.
        let customActionParser2 = TestCustomActionParser()
        XCTAssertNoThrow(try actionParser.addParser(for: elemType, parser: customActionParser2))
        if let actionParserWrapper = actionParser.getParser(for: elemType) as? SwiftActionElementParserWrapper {
            XCTAssertTrue(actionParserWrapper.actualParser as AnyObject === customActionParser2 as AnyObject)
        } else {
            XCTFail("Custom action parser was not overwritten correctly")
        }
        
        let customElementParser2 = TestCustomElementParser()
        XCTAssertNoThrow(try elementParser.addParser(for: elemType, parser: customElementParser2))
        if let cardParserWrapper = elementParser.getParser(for: elemType) as? SwiftBaseCardElementParserWrapper {
            XCTAssertTrue(cardParserWrapper.actualParser as AnyObject === customElementParser2 as AnyObject)
        } else {
            XCTFail("Custom element parser was not overwritten correctly")
        }
        
        // Remove custom parser twice. (Should not throw.)
        XCTAssertNoThrow(try actionParser.removeParser(for: elemType))
        XCTAssertNil(actionParser.getParser(for: elemType))
        XCTAssertNoThrow(try actionParser.removeParser(for: elemType))
        XCTAssertNil(actionParser.getParser(for: elemType))
        XCTAssertNoThrow(try elementParser.removeParser(for: elemType))
        XCTAssertNil(elementParser.getParser(for: elemType))
        XCTAssertNoThrow(try elementParser.removeParser(for: elemType))
        XCTAssertNil(elementParser.getParser(for: elemType))
        
        // Make sure we can't remove known parser.
        XCTAssertNotNil(actionParser.getParser(for: SwiftActionType.openUrl.rawValue))
        XCTAssertThrowsError(try actionParser.removeParser(for: SwiftActionType.openUrl.rawValue))
        XCTAssertNotNil(actionParser.getParser(for: SwiftActionType.openUrl.rawValue))
        XCTAssertNotNil(elementParser.getParser(for: SwiftCardElementType.container.rawValue))
        XCTAssertThrowsError(try elementParser.removeParser(for: SwiftCardElementType.container.rawValue))
        XCTAssertNotNil(elementParser.getParser(for: SwiftCardElementType.container.rawValue))
    }
}
