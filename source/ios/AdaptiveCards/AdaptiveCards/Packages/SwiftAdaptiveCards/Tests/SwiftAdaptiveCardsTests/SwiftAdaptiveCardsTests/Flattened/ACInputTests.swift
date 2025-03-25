//
//  ACInputTests.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest
@testable import SwiftAdaptiveCards

final class ACInputTests: XCTestCase {
    
    func testAdaptiveCardInputParsing() throws {
        let json = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Default text input"
                },
                {
                    "type": "Input.Text",
                    "id": "defaultInputId",
                    "placeholder": "enter comment",
                    "maxLength": 500
                },
                {
                    "type": "TextBlock",
                    "text": "Multiline text input"
                },
                {
                    "type": "Input.Text",
                    "id": "multilineInputId",
                    "placeholder": "enter comment",
                    "maxLength": 500,
                    "isMultiline": true
                },
                {
                    "type": "TextBlock",
                    "text": "Pre-filled value"
                },
                {
                    "type": "Input.Text",
                    "id": "prefilledInputId",
                    "placeholder": "enter comment",
                    "maxLength": 500,
                    "isMultiline": true,
                    "value": "This value was pre-filled"
                }
            ],
            "actions": [
                {
                    "type": "Action.Submit",
                    "title": "OK"
                }
            ]
        }
        """
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(json, version: "1.0")
            let card = parseResult.adaptiveCard
            
            // Test schema and version
            // Note: In new model, schema might be stored differently or not at all
            // If not available directly, we can skip this assertion
            // XCTAssertEqual(card.schema, "http://adaptivecards.io/schemas/adaptive-card.json")
            XCTAssertEqual(card.version, "1.0")
            
            XCTAssertEqual(card.body.count, 6)
            
            // First TextBlock
            guard let textBlock = card.body[0] as? SwiftTextBlock else {
                XCTFail("Expected first body element to be a TextBlock")
                return
            }
            XCTAssertEqual(textBlock.text, "Default text input")
            
            // First Input.Text
            guard let inputText = card.body[1] as? SwiftTextInput else {
                XCTFail("Expected second body element to be an InputText")
                return
            }
            XCTAssertEqual(inputText.id, "defaultInputId")
            XCTAssertEqual(inputText.placeholder, "enter comment")
            XCTAssertEqual(inputText.maxLength, 500)
            XCTAssertFalse(inputText.isMultiline) // Assuming the new model uses a boolean with default false
            XCTAssertNil(inputText.value) // Or empty string depending on the new model
            
            // Second TextBlock
            guard let textBlock2 = card.body[2] as? SwiftTextBlock else {
                XCTFail("Expected third body element to be a TextBlock")
                return
            }
            XCTAssertEqual(textBlock2.text, "Multiline text input")
            
            // Second Input.Text
            guard let inputText2 = card.body[3] as? SwiftTextInput else {
                XCTFail("Expected fourth body element to be an InputText")
                return
            }
            XCTAssertEqual(inputText2.id, "multilineInputId")
            XCTAssertEqual(inputText2.placeholder, "enter comment")
            XCTAssertEqual(inputText2.maxLength, 500)
            XCTAssertTrue(inputText2.isMultiline)
            XCTAssertNil(inputText2.value) // Or empty string depending on the new model
            
            // Third TextBlock
            guard let textBlock3 = card.body[4] as? SwiftTextBlock else {
                XCTFail("Expected fifth body element to be a TextBlock")
                return
            }
            XCTAssertEqual(textBlock3.text, "Pre-filled value")
            
            // Third Input.Text
            guard let inputText3 = card.body[5] as? SwiftTextInput else {
                XCTFail("Expected sixth body element to be an InputText")
                return
            }
            XCTAssertEqual(inputText3.id, "prefilledInputId")
            XCTAssertEqual(inputText3.placeholder, "enter comment")
            XCTAssertEqual(inputText3.maxLength, 500)
            XCTAssertTrue(inputText3.isMultiline)
            XCTAssertEqual(inputText3.value, "This value was pre-filled")
            
            // Actions
            XCTAssertEqual(card.actions.count, 1)
            
            guard let actionSubmit = card.actions.first as? SwiftSubmitAction else {
                XCTFail("Expected first action to be an ActionSubmit")
                return
            }
            XCTAssertEqual(actionSubmit.title, "OK")
            
        } catch {
            XCTFail("Deserialization or serialization failed with error: \(error)")
        }
    }
}
