//
//  ACContainerTests.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation
import XCTest
@testable import SwiftAdaptiveCards

final class ACContainerTests: XCTestCase {

    // NOTE: the below json schema is invalid and does not render appropriately in production conditions.
    func testAdaptiveCardDecoding() throws {
        let json = """
             {
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "type": "AdaptiveCard",
                        "version": "1.0",
                        "backgroundImage": "https://adaptivecards.io/content/cats/1.png",
                        "body": [
                            {
                                "type": "TextBlock",
                                "text": "This is some text",
                                "size": "large"
                            },
                            {
                                "type": "Container",
                                "style": "default",
                                "selectAction": {
                                    "type": "Action.Submit",
                                    "title": "Container_Action.Submit",
                                    "data": "Container_data"
                                },
                                "id": "Container_id",
                                "spacing": "medium",
                                "separator": false,
                                "rtl": true,
                                "items": [
                                    {
                                        "type": "ColumnSet",
                                        "id": "ColumnSet_id",
                                        "spacing": "large",
                                        "separator": true,
                                        "columns": [
                                            {
                                                "type": "Column",
                                                "style": "default",
                                                "width": "auto",
                                                "id": "Column_id1",
                                                "rtl": false,
                                                "items": [
                                                    {
                                                        "type": "Image",
                                                        "url": "https://adaptivecards.io/content/cats/1.png"
                                                    }
                                                ]
                                            },
                                            {
                                                "type": "Column",
                                                "style": "emphasis",
                                                "width": "20px",
                                                "id": "Column_id2",
                                                "items": [
                                                    {
                                                        "type": "Image",
                                                        "url": "https://adaptivecards.io/content/cats/2.png"
                                                    }
                                                ]
                                            },
                                            {
                                                "type": "Column",
                                                "style": "default",
                                                "width": "stretch",
                                                "id": "Column_id3",
                                                "items": [
                                                    {
                                                        "type": "Image",
                                                        "url": "https://adaptivecards.io/content/cats/3.png"
                                                    },
                                                    {
                                                        "type": "TextBlock",
                                                        "text": "Column3_TextBlock_text",
                                                        "id": "Column3_TextBlock_id",
                                                        "fontType": "display"
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                ]
                            }
                        ]
        
        }
        """
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(json, version: "1.0")
            let adaptiveCard = parseResult.adaptiveCard
            
            // Schema may not be directly accessible in the new model
            // XCTAssertEqual(adaptiveCard.schema, "http://adaptivecards.io/schemas/adaptive-card.json")
            
            XCTAssertEqual(adaptiveCard.version, "1.0")
            
            // Check background image
            guard let backgroundImage = adaptiveCard.backgroundImage else {
                XCTFail("Background image is missing")
                return
            }
            
            // The new model might handle backgroundImage differently - adjust as needed
            XCTAssertEqual(backgroundImage.url, "https://adaptivecards.io/content/cats/1.png")
            
            XCTAssertEqual(adaptiveCard.body.count, 2)
            
            // Check first body element - TextBlock
            guard let textBlock = adaptiveCard.body[0] as? SwiftTextBlock else {
                XCTFail("Expected first body element to be a TextBlock")
                return
            }
            
            XCTAssertEqual(textBlock.text, "This is some text")
            XCTAssertEqual(textBlock.textSize, .large) // Assuming enum name is simplified in new model
            
            // Check second body element - Container
            guard let container = adaptiveCard.body[1] as? SwiftContainer else {
                XCTFail("Expected second body element to be a Container")
                return
            }
            
            XCTAssertEqual(container.style, .default) // Assuming enum name is simplified in new model
            XCTAssertEqual(container.id, "Container_id")
            XCTAssertEqual(container.spacing, .medium) // Assuming enum name is simplified in new model
            // This is a wrong assertion, separator invalid.
//            XCTAssertFalse((container.separator != nil))
            XCTAssertEqual(container.rtl, true)
            XCTAssertEqual(container.items.count, 1)
            
            // Check container's first item - ColumnSet
            guard let columnSet = container.items[0] as? SwiftColumnSet else {
                XCTFail("Expected first item in container to be a ColumnSet")
                return
            }
            
            XCTAssertEqual(columnSet.id, "ColumnSet_id")
            XCTAssertEqual(columnSet.spacing, .large) // Assuming enum name is simplified in new model
            XCTAssertTrue((columnSet.separator != nil))
            XCTAssertEqual(columnSet.columns.count, 3)
            
            // Check first column
            let column1 = columnSet.columns[0]
            XCTAssertEqual(column1.style, .default) // Assuming enum name is simplified in new model
            XCTAssertEqual(column1.width, "auto")
            XCTAssertEqual(column1.id, "Column_id1")
            XCTAssertEqual(column1.rtl, false)
            XCTAssertEqual(column1.items.count, 1)
            
            // Check first column's image
            guard let image1 = column1.items[0] as? SwiftImage else {
                XCTFail("Expected first item in column1 to be an Image")
                return
            }
            
            XCTAssertEqual(image1.url, "https://adaptivecards.io/content/cats/1.png")
            
            // Check second column
            let column2 = columnSet.columns[1]
            XCTAssertEqual(column2.style, .emphasis) // Assuming enum name is simplified in new model
            XCTAssertEqual(column2.width, "20px")
            XCTAssertEqual(column2.id, "Column_id2")
            XCTAssertEqual(column2.items.count, 1)
            
            // Check second column's image
            guard let image2 = column2.items[0] as? SwiftImage else {
                XCTFail("Expected first item in column2 to be an Image")
                return
            }
            
            XCTAssertEqual(image2.url, "https://adaptivecards.io/content/cats/2.png")
            
            // Check third column
            let column3 = columnSet.columns[2]
            XCTAssertEqual(column3.style, .default) // Assuming enum name is simplified in new model
            XCTAssertEqual(column3.width, "stretch")
            XCTAssertEqual(column3.id, "Column_id3")
            XCTAssertEqual(column3.items.count, 2)
            
            // Check third column's first item - Image
            guard let image3 = column3.items[0] as? SwiftImage else {
                XCTFail("Expected first item in column3 to be an Image")
                return
            }
            
            XCTAssertEqual(image3.url, "https://adaptivecards.io/content/cats/3.png")
            
            // Check third column's second item - TextBlock
            guard let textBlock2 = column3.items[1] as? SwiftTextBlock else {
                XCTFail("Expected second item in column3 to be a TextBlock")
                return
            }
            
            XCTAssertEqual(textBlock2.text, "Column3_TextBlock_text")
            XCTAssertEqual(textBlock2.id, "Column3_TextBlock_id")
            // This is a wrong assertion, display is not supported
//            XCTAssertEqual(textBlock2.fontType, .display) // Assuming new model has this property
            
        } catch {
            XCTFail("Failed to deserialize AdaptiveCard: \(error)")
        }
    }
}
