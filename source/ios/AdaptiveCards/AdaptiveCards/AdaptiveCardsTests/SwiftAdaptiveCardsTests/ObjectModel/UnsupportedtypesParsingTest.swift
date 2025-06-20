//
//  UnsupportedtypesParsingTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
import AdaptiveCards

class UnknownElementParsing: XCTestCase {
    
    func testCanGetCustomJsonPayload() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Random",
                    "payload": "You can even draw attention to certain text with color"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let element = parseResult.adaptiveCard.body.first else {
            XCTFail("No element found in adaptive card body")
            return
        }
        
        XCTAssertEqual(element.typeString, "Random")
        
        guard let delegate = element as? SwiftUnknownElement else {
            XCTFail("Element is not an UnknownElement")
            return
        }
        
        let value = delegate.additionalProperties ?? [:]
        let jsonString = try SwiftParseUtil.jsonToString(value)
        let expected = "{\"payload\":\"You can even draw attention to certain text with color\",\"type\":\"Random\"}\n"
        XCTAssertEqual(expected, jsonString)
    }
    
    func testCanGetCustomJsonPayloadWithKnownElementFollowing() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Unknown",
                    "payload": "You can even draw attention to certain text with color"
                },
                {
                    "type": "TextBlock",
                    "text": "You can even draw attention to certain text with color",
                    "wrap": true,
                    "color": "attention",
                    "unknown": "testing unknown"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let element = parseResult.adaptiveCard.body.first else {
            XCTFail("No element found in adaptive card body")
            return
        }
        
        guard let delegate = element as? SwiftUnknownElement else {
            XCTFail("Element is not an UnknownElement")
            return
        }
        
        let value = delegate.additionalProperties ?? [:]
        let jsonString = try SwiftParseUtil.jsonToString(value)
        let expected = "{\"payload\":\"You can even draw attention to certain text with color\",\"type\":\"Unknown\"}\n"
        XCTAssertEqual(expected, jsonString)
    }
    
    func testCanGetJsonPayloadOfArrayType() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "RadioButton",
                    "payload": [
                        {
                            "testloadone": "You can even draw attention to certain text with color"
                        },
                        {
                            "testloadtwo": "You can even draw attention to certain text with markdown"
                        }
                    ]
                },
                {
                    "type": "TextBlock",
                    "text": "You can even draw attention to certain text with color",
                    "wrap": true,
                    "color": "attention",
                    "unknown": "testing unknown"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let element = parseResult.adaptiveCard.body.first else {
            XCTFail("No element found in adaptive card body")
            return
        }
        
        XCTAssertEqual(element.typeString, "RadioButton")
        
        guard let delegate = element as? SwiftUnknownElement else {
            XCTFail("Element is not an UnknownElement")
            return
        }
        
        let value = delegate.additionalProperties ?? [:]
        let jsonString = try SwiftParseUtil.jsonToString(value)
        let expected = "{\"payload\":[{\"testloadone\":\"You can even draw attention to certain text with color\"},{\"testloadtwo\":\"You can even draw attention to certain text with markdown\"}],\"type\":\"RadioButton\"}\n"
        XCTAssertEqual(expected, jsonString)
    }
    
    func testCanHandleCustomAction() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "You can even draw attention to certain text with color",
                    "wrap": true,
                    "color": "attention"
                }
            ],
            "actions": [
                {
                    "type": "Alert",
                    "title": "Submit",
                    "data": {
                        "id": "1234567890"
                    }
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let actionElement = parseResult.adaptiveCard.actions.first else {
            XCTFail("No action found in adaptive card")
            return
        }
        
        XCTAssertEqual(actionElement.typeString, "Alert")
        
        guard let delegate = actionElement as? SwiftUnknownAction else {
            XCTFail("Action element is not an UnknownAction")
            return
        }
        
        let value = delegate.additionalProperties ?? [:]
        let jsonString = try SwiftParseUtil.jsonToString(value)
        let expected = "{\"data\":{\"id\":\"1234567890\"},\"title\":\"Submit\",\"type\":\"Alert\"}\n"
        XCTAssertEqual(expected, jsonString)
    }
    
    func testRoundTripTestForCustomAction() throws {
        let testJsonString = """
        {
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "You can even draw attention to certain text with color",
                    "wrap": true,
                    "color": "Attention"
                }
            ],
            "actions": [
                {
                    "type": "Alert",
                    "title": "Submit",
                    "data": {
                        "id": "1234567890"
                    }
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let expectedValue = SwiftParseUtil.getJsonValue(from: testJsonString)
        let expectedString = try SwiftParseUtil.jsonToString(expectedValue)
        let serializedCard = try parseResult.adaptiveCard.serializeToJsonValue()
        let serializedCardAsString = try SwiftParseUtil.jsonToString(serializedCard)
        
        XCTAssertEqual(expectedString, serializedCardAsString)
        // Helper function for safer dictionary comparison
        func compareJsonDictionaries(_ dict1: [String: Any], _ dict2: [String: Any]) -> Bool {
            guard let str1 = try? SwiftParseUtil.jsonToString(dict1),
                  let str2 = try? SwiftParseUtil.jsonToString(dict2) else {
                return false
            }
            return str1 == str2
        }
        
        // Use the safer comparison
        guard let expected = expectedValue as? [String: Any],
              let actual = serializedCard as? [String: Any] else {
            XCTFail("Failed to cast values to dictionaries")
            return
        }
        
        XCTAssertTrue(compareJsonDictionaries(expected, actual))
    }
}
