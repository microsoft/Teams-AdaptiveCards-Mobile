//
//  FallBackTests.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Rahul Pinjani on 9/19/24.
//

import Foundation
import XCTest
import AdaptiveCards

class ACFallbackTests: XCTestCase {

    func testElementFallbackSerialization() {
        let cardStr = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type" : "AdaptiveCard",
            "version" : "1.2",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Primary TextBlock",
                    "fallback": {
                        "type": "TextBlock",
                        "text": "Fallback TextBlock"
                    }
                }
            ]
        }
        """

        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(cardStr, version: "1.2")
            let card = parseResult.adaptiveCard
            
            XCTAssertEqual(card.body.count, 1)
            
            guard let textBlock = card.body.first as? SwiftTextBlock else {
                XCTFail("Body element is not a TextBlock")
                return
            }
            
            XCTAssertEqual(textBlock.text, "Primary TextBlock")
            
            guard let fallbackContent = textBlock.fallbackContent as? SwiftTextBlock else {
                XCTFail("Fallback is not a TextBlock")
                return
            }
            
            XCTAssertEqual(fallbackContent.text, "Fallback TextBlock")
            
        } catch {
            XCTFail("Failed to decode AdaptiveCard: \(error)")
        }
    }

    func testComplexFallbackSerialization() {
        let cardStr = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type" : "AdaptiveCard",
            "version" : "1.2",
            "body": [
                {
                    "type": "ColumnSet",
                    "id": "A",
                    "columns": [
                        {
                            "type": "Column",
                            "id": "B",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "id": "C",
                                    "text": "C TextBlock",
                                    "fallback": {
                                        "type": "Container",
                                        "id": "E",
                                        "items": [
                                            {
                                                "type": "Image",
                                                "id": "I",
                                                "url": "http://adaptivecards.io/content/cats/2.png"
                                            },
                                            {
                                                "type": "TextBlock",
                                                "id": "J",
                                                "text": "C ColumnSet fallback textblock"
                                            }
                                        ]
                                    }
                                }
                            ]
                        }
                    ]
                },
                {
                    "type": "TextBlock",
                    "id": "F",
                    "text": "F TextBlock"
                }
            ]
        }
        """

        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(cardStr, version: "1.2")
            let card = parseResult.adaptiveCard
            
            XCTAssertEqual(card.body.count, 2)
            
            // Test the ColumnSet structure
            guard let columnSet = card.body.first as? SwiftColumnSet else {
                XCTFail("First body element is not a ColumnSet")
                return
            }
            
            XCTAssertEqual(columnSet.id, "A")
            XCTAssertEqual(columnSet.columns.count, 1)
            
            guard let column = columnSet.columns.first else {
                XCTFail("Column is missing")
                return
            }
            
            XCTAssertEqual(column.id, "B")
            XCTAssertEqual(column.items.count, 1)
            
            guard let textBlock = column.items.first as? SwiftTextBlock else {
                XCTFail("First item in column is not a TextBlock")
                return
            }
            
            XCTAssertEqual(textBlock.id, "C")
            XCTAssertEqual(textBlock.text, "C TextBlock")
            
            guard let fallbackContainer = textBlock.fallbackContent as? SwiftContainer else {
                XCTFail("Fallback is not a Container")
                return
            }
            
            XCTAssertEqual(fallbackContainer.id, "E")
            XCTAssertEqual(fallbackContainer.items.count, 2)
            
            guard let image = fallbackContainer.items.first as? SwiftImage else {
                XCTFail("First item in fallback container is not an Image")
                return
            }
            
            XCTAssertEqual(image.id, "I")
            XCTAssertEqual(image.url, "http://adaptivecards.io/content/cats/2.png")
            
            guard let fallbackTextBlock = fallbackContainer.items.last as? SwiftTextBlock else {
                XCTFail("Second item in fallback container is not a TextBlock")
                return
            }
            
            XCTAssertEqual(fallbackTextBlock.id, "J")
            XCTAssertEqual(fallbackTextBlock.text, "C ColumnSet fallback textblock")
            
            // Test the second TextBlock
            guard let lastTextBlock = card.body.last as? SwiftTextBlock else {
                XCTFail("Second body element is not a TextBlock")
                return
            }
            
            XCTAssertEqual(lastTextBlock.id, "F")
            XCTAssertEqual(lastTextBlock.text, "F TextBlock")
            
        } catch {
            XCTFail("Failed to decode AdaptiveCard: \(error)")
        }
    }
}
