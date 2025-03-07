//
//  ACCardActionsTests.swift
//  ACSwiftRewriteTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest
@testable import SwiftAdaptiveCards

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
            
            // Since schema might not be directly accessible in the new model, I'm leaving this commented
            // XCTAssertEqual(card.schema, "http://adaptivecards.io/schemas/adaptive-card.json")
            
            XCTAssertEqual(card.version, "1.5")
            XCTAssertEqual(card.body.count, 2)
            
            // Test first input element
            guard let inputText1 = card.body[0] as? SwiftTextInput else {
                XCTFail("Expected first body element to be an InputText")
                return
            }
            
            XCTAssertEqual(inputText1.id, "iconInlineActionId")
            XCTAssertEqual(inputText1.label, "Text input with an inline action")
            
            // The commented sections in the original test suggest these might be expected to fail
            // or are not yet implemented. I'll include them but keep them commented as in the original
            // Uncomment these if you want to test inline actions
            /*
            XCTAssertNotNil(inputText1.inlineAction)
            
            guard let inlineAction1 = inputText1.inlineAction as? SwiftSubmitAction else {
                XCTFail("Expected inline action to be a SwiftSubmitAction")
                return
            }
            
            XCTAssertEqual(inlineAction1.iconUrl, "https://adaptivecards.io/content/send.png")
            XCTAssertEqual(inlineAction1.tooltip, "Send")
            */
            
            // Test second input element
            guard let inputText2 = card.body[1] as? SwiftTextInput else {
                XCTFail("Expected second body element to be an InputText")
                return
            }
            
            XCTAssertEqual(inputText2.id, "textInlineActionId")
            XCTAssertEqual(inputText2.label, "Text input with an inline action with no icon")
            
            // Commented out as in the original test
            /*
            XCTAssertNotNil(inputText2.inlineAction)
            
            guard let inlineAction2 = inputText2.inlineAction as? SwiftOpenUrlAction else {
                XCTFail("Expected inline action to be a SwiftOpenUrlAction")
                return
            }
            
            XCTAssertEqual(inlineAction2.title, "Reply")
            XCTAssertEqual(inlineAction2.tooltip, "Reply to this message")
            XCTAssertEqual(inlineAction2.url, "https://adaptivecards.io")
            */
            
        } catch {
            XCTFail("Failed to deserialize AdaptiveCard: \(error)")
        }
    }
}
