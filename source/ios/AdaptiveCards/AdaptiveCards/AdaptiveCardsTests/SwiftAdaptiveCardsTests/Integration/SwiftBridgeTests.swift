//
//  SwiftBridgeTests.swift
//  AdaptiveCardsTests
//
//  Created by Claude on 1/22/26.
//  Copyright © 2026 Microsoft. All rights reserved.
//

import XCTest
import AdaptiveCards

/// Integration tests for SwiftElementPropertyAccessor bridge methods.
/// These tests verify that the Swift bridge correctly extracts properties
/// from parsed Adaptive Card elements.
class SwiftBridgeTests: XCTestCase {

    // MARK: - TextBlock Tests

    func testGetTextBlockText() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Hello, World!",
                    "wrap": true,
                    "maxLines": 2
                }
            ]
        }
        """

        let result = SwiftAdaptiveCardParser.parse(payload: json)
        XCTAssertNil(result.errors, "Parsing should succeed without errors")

        guard let parseResult = result.parseResult else {
            XCTFail("Parse result should not be nil")
            return
        }

        let card = parseResult.adaptiveCard
        XCTAssertEqual(card.body.count, 1, "Card should have 1 body element")

        let textBlock = card.body[0]
        let text = SwiftElementPropertyAccessor.getTextBlockText(textBlock)
        XCTAssertEqual(text, "Hello, World!", "TextBlock text should match")

        let wrap = SwiftElementPropertyAccessor.getTextBlockWrap(textBlock)
        XCTAssertTrue(wrap, "TextBlock wrap should be true")

        let maxLines = SwiftElementPropertyAccessor.getTextBlockMaxLines(textBlock)
        XCTAssertEqual(maxLines, 2, "TextBlock maxLines should be 2")
    }

    // MARK: - Image Tests

    func testGetImageUrl() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Image",
                    "url": "https://example.com/image.png",
                    "altText": "Example image",
                    "size": "medium"
                }
            ]
        }
        """

        let result = SwiftAdaptiveCardParser.parse(payload: json)
        XCTAssertNil(result.errors, "Parsing should succeed without errors")

        guard let parseResult = result.parseResult else {
            XCTFail("Parse result should not be nil")
            return
        }

        let card = parseResult.adaptiveCard
        XCTAssertEqual(card.body.count, 1, "Card should have 1 body element")

        let image = card.body[0]
        let url = SwiftElementPropertyAccessor.getImageUrl(image)
        XCTAssertEqual(url, "https://example.com/image.png", "Image URL should match")

        let altText = SwiftElementPropertyAccessor.getImageAltText(image)
        XCTAssertEqual(altText, "Example image", "Image altText should match")

        let size = SwiftElementPropertyAccessor.getImageSize(image)
        XCTAssertEqual(size, 4, "Image size should be 4 (medium)")
    }

    // MARK: - Container Tests

    func testGetContainerItems() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "Container",
                    "style": "emphasis",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Item 1"
                        },
                        {
                            "type": "TextBlock",
                            "text": "Item 2"
                        }
                    ]
                }
            ]
        }
        """

        let result = SwiftAdaptiveCardParser.parse(payload: json)
        XCTAssertNil(result.errors, "Parsing should succeed without errors")

        guard let parseResult = result.parseResult else {
            XCTFail("Parse result should not be nil")
            return
        }

        let card = parseResult.adaptiveCard
        XCTAssertEqual(card.body.count, 1, "Card should have 1 body element")

        let container = card.body[0]
        let items = SwiftElementPropertyAccessor.getContainerItems(container)
        XCTAssertEqual(items.count, 2, "Container should have 2 items")

        // Verify first item text
        let firstItemText = SwiftElementPropertyAccessor.getTextBlockText(items[0])
        XCTAssertEqual(firstItemText, "Item 1", "First item text should match")

        // Verify second item text
        let secondItemText = SwiftElementPropertyAccessor.getTextBlockText(items[1])
        XCTAssertEqual(secondItemText, "Item 2", "Second item text should match")

        // Verify container style
        let style = SwiftElementPropertyAccessor.getContainerStyle(container)
        XCTAssertEqual(style, 2, "Container style should be 2 (emphasis)")
    }

    // MARK: - FactSet Tests

    func testGetFactSetFacts() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.6",
            "body": [
                {
                    "type": "FactSet",
                    "facts": [
                        {
                            "title": "Name",
                            "value": "John Doe"
                        },
                        {
                            "title": "Age",
                            "value": "30"
                        },
                        {
                            "title": "Location",
                            "value": "Seattle"
                        }
                    ]
                }
            ]
        }
        """

        let result = SwiftAdaptiveCardParser.parse(payload: json)
        XCTAssertNil(result.errors, "Parsing should succeed without errors")

        guard let parseResult = result.parseResult else {
            XCTFail("Parse result should not be nil")
            return
        }

        let card = parseResult.adaptiveCard
        XCTAssertEqual(card.body.count, 1, "Card should have 1 body element")

        let factSet = card.body[0]
        let facts = SwiftElementPropertyAccessor.getFactSetFacts(factSet)
        XCTAssertEqual(facts.count, 3, "FactSet should have 3 facts")

        // Verify first fact
        let firstTitle = SwiftElementPropertyAccessor.getFactTitle(facts[0])
        let firstValue = SwiftElementPropertyAccessor.getFactValue(facts[0])
        XCTAssertEqual(firstTitle, "Name", "First fact title should match")
        XCTAssertEqual(firstValue, "John Doe", "First fact value should match")

        // Verify second fact
        let secondTitle = SwiftElementPropertyAccessor.getFactTitle(facts[1])
        let secondValue = SwiftElementPropertyAccessor.getFactValue(facts[1])
        XCTAssertEqual(secondTitle, "Age", "Second fact title should match")
        XCTAssertEqual(secondValue, "30", "Second fact value should match")

        // Verify third fact
        let thirdTitle = SwiftElementPropertyAccessor.getFactTitle(facts[2])
        let thirdValue = SwiftElementPropertyAccessor.getFactValue(facts[2])
        XCTAssertEqual(thirdTitle, "Location", "Third fact title should match")
        XCTAssertEqual(thirdValue, "Seattle", "Third fact value should match")
    }
}
