//
//  ACElementTests.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest
@testable import AdaptiveCards

class ACElementTests: XCTestCase {
    
    func testShowCardSerialization() {
        let cardWithShowCard = """
               {
                   "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                   "type" : "AdaptiveCard",
                   "version" : "2.0",
                   "body" : [
                       {
                           "type": "TextBlock",
                           "text" : "This card's action will show another card"
                       }
                   ],
                   "actions": [
                       {
                           "type": "Action.ShowCard",
                           "title" : "Action.ShowCard",
                           "card" : {
                               "type": "AdaptiveCard",
                               "body" : [
                                   {
                                       "type": "TextBlock",
                                       "text" : "What do you think?"
                                   }
                               ],
                               "actions": [
                                   {
                                       "type": "Action.Submit",
                                       "title" : "Neat!"
                                   }
                               ]
                           }
                       }
                   ]
               }
               """
        
        do {
            let cardData = cardWithShowCard.data(using: .utf8)!
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(cardWithShowCard, version: "2.0")
            let card = parseResult.adaptiveCard
            let actions = card.actions
            // Check if first action is a ShowCard action
            guard !actions.isEmpty else {
                XCTFail("Card has no actions")
                return
            }
            
            let firstAction = actions[0]
            guard let showCardAction = firstAction as? SwiftShowCardAction else {
                XCTFail("First action is not a ShowCardAction")
                return
            }
            
            let showCard = showCardAction.card
            
            XCTAssertEqual(card.version, "2.0")
            XCTAssertEqual(showCard?.body.count, 1)
            
            // Check text block in show card
            guard let textBlockElement = showCard?.body.first as? SwiftTextBlock else {
                XCTFail("First body element is not a TextBlock")
                return
            }
            XCTAssertEqual(textBlockElement.text, "What do you think?")
            
            // Check actions in show card
            XCTAssertEqual(showCard?.actions.count, 1)
            guard let submitAction = showCard?.actions.first as? SwiftSubmitAction else {
                XCTFail("First action of show card is not a SubmitAction")
                return
            }
            XCTAssertEqual(submitAction.title, "Neat!")
            
        } catch {
            XCTFail("Deserialization or serialization failed with error: \(error)")
        }
    }
}
