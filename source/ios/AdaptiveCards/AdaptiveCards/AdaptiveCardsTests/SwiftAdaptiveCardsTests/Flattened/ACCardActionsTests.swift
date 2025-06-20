//
//  ACCardActionsTests.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest
import AdaptiveCards

final class ACCardActionTests: XCTestCase {
    
    func testAdaptiveCardActionsParsing() throws {
        let json = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "iconInlineActionId",
                    "label": "Text input with an inline action",
                    "inlineAction": {
                        "type": "Action.Submit",
                        "iconUrl": "https://adaptivecards.io/content/send.png",
                        "tooltip": "Send"
                    }
                },
                {
                    "type": "Input.Text",
                    "label": "Text input with an inline action with no icon",
                    "id": "textInlineActionId",
                    "inlineAction": {
                        "type": "Action.OpenUrl",
                        "title": "Reply",
                        "tooltip": "Reply to this message",
                        "url": "https://adaptivecards.io"
                    }
                }
            ]
        }
        """
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(json, version: "1.5")
            let card = parseResult.adaptiveCard
            
            XCTAssertEqual(card.version, "1.5")
            XCTAssertEqual(card.body.count, 2)
            
            // Test first input element
            guard let inputText1 = card.body[0] as? SwiftTextInput else {
                XCTFail("Expected first body element to be an InputText")
                return
            }
            
            XCTAssertEqual(inputText1.id, "iconInlineActionId")
            XCTAssertEqual(inputText1.label, "Text input with an inline action")
            // Test second input element
            guard let inputText2 = card.body[1] as? SwiftTextInput else {
                XCTFail("Expected second body element to be an InputText")
                return
            }
            
            XCTAssertEqual(inputText2.id, "textInlineActionId")
            XCTAssertEqual(inputText2.label, "Text input with an inline action with no icon")
        } catch {
            XCTFail("Failed to deserialize AdaptiveCard: \(error)")
        }
    }
}
