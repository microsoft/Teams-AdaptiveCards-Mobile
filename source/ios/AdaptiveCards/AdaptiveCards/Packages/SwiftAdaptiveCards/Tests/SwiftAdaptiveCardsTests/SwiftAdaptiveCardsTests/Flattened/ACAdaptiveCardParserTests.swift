//
//  ACAdaptiveCardParserTests.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation
import XCTest
@testable import SwiftAdaptiveCards

class ACAdaptiveCardParserTests: XCTestCase {
    func testParseAdaptiveCard() throws {
        let json = """
            {
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "type": "AdaptiveCard",
                "version": "1.0",
                "backgroundImage": "https://adaptivecards.io/content/cats/1.png",
                "refresh": {
                    "action": {
                        "type": "Action.Execute",
                        "id": "refresh_action_id",
                        "verb": "refresh_action_verb"
                    },
                    "userIds": [
                        "refresh_userIds_0"
                    ]
                },
                "authentication": {
                    "text": "authentication_text",
                    "connectionName": "authentication_connectionName",
                    "tokenExchangeResource": {
                        "id": "authentication_tokenExchangeResource_id",
                        "uri": "authentication_tokenExchangeResource_uri",
                        "providerId": "authentication_tokenExchangeResource_providerId"
                    },
                    "buttons": [
                        {
                            "type": "authentication_buttons_0_type",
                            "title": "authentication_buttons_0_title"
                        }
                    ]
                },
                "fallbackText": "fallbackText",
                "speak": "speak",
                "lang": "en",
                "rtl": false,
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "TextBlock_text",
                        "color": "default",
                        "horizontalAlignment": "left",
                        "isSubtle": false,
                        "italic": true,
                        "maxLines": 1,
                        "size": "default",
                        "weight": "default",
                        "wrap": false,
                        "id": "TextBlock_id",
                        "spacing": "default",
                        "separator": false,
                        "strikethrough": true,
                        "style": "Heading"
                    }
                ],
                "actions": [
                    {
                        "type": "Action.Submit",
                        "title": "Action.Submit",
                        "id": "Action.Submit_id",
                        "tooltip": "tooltip",
                        "isEnabled": true,
                        "data": {
                            "submitValue": true
                        }
                    }
                ]
            }
            """
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(json, version: "1.0")
            let card = parseResult.adaptiveCard
            
            XCTAssertEqual(card.version, "1.0")
            
            // Check background image
            guard let backgroundImage = card.backgroundImage else {
                XCTFail("Background image is missing")
                return
            }
            XCTAssertEqual(backgroundImage.url, "https://adaptivecards.io/content/cats/1.png")
            
            // Check refresh properties
            guard let refresh = card.refresh else {
                XCTFail("Refresh property is missing")
                return
            }
            
            // In the new model, the action might be a typed action rather than an enum
            guard let executeAction = refresh.action as? SwiftExecuteAction else {
                XCTFail("Expected refresh action to be an ExecuteAction")
                return
            }
            
            // Some commented assertions in the original that may need updating
            XCTAssertEqual(executeAction.verb, "refresh_action_verb")
            XCTAssertEqual(refresh.userIds.first, "refresh_userIds_0")
            
            // Check authentication properties
            guard let authentication = card.authentication else {
                XCTFail("Authentication property is missing")
                return
            }
            
            XCTAssertEqual(authentication.text, "authentication_text")
            XCTAssertEqual(authentication.connectionName, "authentication_connectionName")
            
            let tokenResource = authentication.tokenExchangeResource
            XCTAssertEqual(tokenResource?.id, "authentication_tokenExchangeResource_id")
            XCTAssertEqual(tokenResource?.uri, "authentication_tokenExchangeResource_uri")
            XCTAssertEqual(tokenResource?.providerId, "authentication_tokenExchangeResource_providerId")
            
            guard let firstButton = authentication.buttons.first else {
                XCTFail("Authentication buttons are missing")
                return
            }
            
            XCTAssertEqual(firstButton.type, "authentication_buttons_0_type")
            XCTAssertEqual(firstButton.title, "authentication_buttons_0_title")
            
            // Check other card properties
            XCTAssertEqual(card.fallbackText, "fallbackText")
            XCTAssertEqual(card.speak, "speak")
            XCTAssertEqual(card.language, "en") // Assuming 'lang' is now 'language'
            XCTAssertEqual(card.rtl, false)
        } catch {
            XCTFail("Failed to deserialize AdaptiveCard: \(error)")
        }
    }
}
