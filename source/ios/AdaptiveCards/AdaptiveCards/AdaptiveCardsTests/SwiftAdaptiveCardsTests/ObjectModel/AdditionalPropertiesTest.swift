//
//  AdditionalPropertiesTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import AdaptiveCards

final class AdditionalPropertyTests: XCTestCase {
    
    func testCanGetAdditionalPropertiesAtCardLevel() throws {
        let testJsonString = """
        {"$schema":"http://adaptivecards.io/schemas/adaptive-card.json","type": "AdaptiveCard","version": "1.0","unknown": "testing unknown","body": [{"type": "TextBlock","text": "You can even draw attention to certain text with color","wrap": true,"color": "attention","unknown": "testing unknown"}]}
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        // Now AdaptiveCard has an additionalProperties property
        let value = parseResult.adaptiveCard.additionalProperties
        XCTAssertEqual(try SwiftParseUtil.jsonToString(value), "{\"unknown\":\"testing unknown\"}\n")
    }
    
    func testCanGetCorrectAdditionalPropertiesAtCardLevel() throws {
        let testJsonString = """
        {"type": "AdaptiveCard","$schema": "http://adaptivecards.io/schemas/adaptive-card.json","version": "1.0","unknown": "testing unknown","lang": "en","fallbackText": "test","speak": "test","minHeight": "1px","verticalContentAlignment": "Center","backgroundImage": {"url": "bing.com","fillMode": "RepeatHorizontally","horizontalAlignment": "Center","verticalAlignment": "Center"},"selectAction": {"type": "Action.OpenUrl","id": "hello","title": "world","url": "www.bing.com"},"body": [{"type": "TextBlock","text": "You can even draw attention to certain text with color"}],"actions": [{"type": "Action.Submit","MyAdditionalProperty": "Foo"}]}
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let value = parseResult.adaptiveCard.additionalProperties
        XCTAssertEqual(try SwiftParseUtil.jsonToString(value), "{\"unknown\":\"testing unknown\"}\n")
    }
    
    func testRoundtrippingWithAdditionalPropertiesAtCardLevel() throws {
        let testJsonString = """
        {"type": "AdaptiveCard","$schema": "http://adaptivecards.io/schemas/adaptive-card.json","version": "1.0","unknown": "testing unknown","lang": "en","fallbackText": "test","speak": "test","minHeight": "1px","verticalContentAlignment": "Center","backgroundImage": {"url": "bing.com","fillMode": "RepeatHorizontally","horizontalAlignment": "Center","verticalAlignment": "Center"},"body": [{"type": "TextBlock","text": "You can even draw attention to certain text with color"}],"actions": [{"type": "Action.Submit","MyAdditionalProperty": "Foo"}]}
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let outputCard = try parseResult.adaptiveCard.serialize()
        let expected = "{\"actions\":[{\"MyAdditionalProperty\":\"Foo\",\"type\":\"Action.Submit\"}],\"backgroundImage\":{\"fillMode\":\"repeatHorizontally\",\"horizontalAlignment\":\"center\",\"url\":\"bing.com\",\"verticalAlignment\":\"center\"},\"body\":[{\"text\":\"You can even draw attention to certain text with color\",\"type\":\"TextBlock\"}],\"fallbackText\":\"test\",\"lang\":\"en\",\"minHeight\":\"1px\",\"speak\":\"test\",\"type\":\"AdaptiveCard\",\"unknown\":\"testing unknown\",\"version\":\"1.0\",\"verticalContentAlignment\":\"Center\"}\n"
        XCTAssertEqual(outputCard, expected)
    }
    
    func testCanGetAdditionalPropertiesForElement() throws {
        let testJsonString = """
        {"$schema":"http://adaptivecards.io/schemas/adaptive-card.json","type": "AdaptiveCard","version": "1.0","body": [{"type": "TextBlock","text": "You can even draw attention to certain text with color","wrap": true,"color": "attention","unknown": "testing unknown"}]}
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let element = parseResult.adaptiveCard.body.first else {
            XCTFail("Expected a body element")
            return
        }
        // Assume BaseCardElement now has an optional additionalProperties property.
        let value = element.additionalProperties ?? [:]
        XCTAssertEqual(try SwiftParseUtil.jsonToString(value), "{\"unknown\":\"testing unknown\"}\n")
    }
    
    func testCanGetAdditionalPropertiesForAction() throws {
        let testJsonString = """
        {"$schema":"http://adaptivecards.io/schemas/adaptive-card.json","type": "AdaptiveCard","version": "1.0","body": [{"type": "TextBlock","text": "You can even draw attention to certain text with color"}],"actions": [{"type": "Action.Submit","MyAdditionalProperty": "Foo"}]}
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let action = parseResult.adaptiveCard.actions.first else {
            XCTFail("Expected an action element")
            return
        }
        // Assume BaseActionElement now has an optional additionalProperties property.
        let value = action.additionalProperties ?? [:]
        XCTAssertEqual(try SwiftParseUtil.jsonToString(value), "{\"MyAdditionalProperty\":\"Foo\"}\n")
    }
    
    func testCanGetAdditionalPropertiesForInline() throws {
        let testJsonString = """
        {"type":"TextRun","text":"Here is some text","MyAdditionalProperty": "Bar"}
        """
        // Adjusted call: since TextRun.deserialize(from:) expects a [String:Any] dictionary,
        // we remove the parseContext parameter.
        let jsonValue = SwiftParseUtil.getJsonValue(from: testJsonString)
        let textRun = try SwiftTextRun.deserialize(from: jsonValue)
        let value = textRun?.additionalProperties ?? [:]
        XCTAssertEqual(try SwiftParseUtil.jsonToString(value), "{\"MyAdditionalProperty\":\"Bar\"}\n")
    }
    
    func testUnknownElementRoundtripping() throws {
        let testJsonString = """
        {"$schema":"http://adaptivecards.io/schemas/adaptive-card.json","type": "AdaptiveCard","version": "1.0","body": [{"type": "TextBlock","text": "Standard textblock"}, {"type": "SomeRandomType","property": "value","someOtherProperty": "some other value"}]}
        """
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let outputCard = try parseResult.adaptiveCard.serialize()
        let expected = "{\"actions\":[],\"body\":[{\"text\":\"Standard textblock\",\"type\":\"TextBlock\"},{\"property\":\"value\",\"someOtherProperty\":\"some other value\",\"type\":\"SomeRandomType\"}],\"type\":\"AdaptiveCard\",\"version\":\"1.0\"}\n"
        XCTAssertEqual(outputCard, expected)
    }
}
