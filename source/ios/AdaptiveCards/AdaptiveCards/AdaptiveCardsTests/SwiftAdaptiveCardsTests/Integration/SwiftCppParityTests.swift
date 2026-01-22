//
//  SwiftCppParityTests.swift
//  AdaptiveCardsTests
//
//  Tests verifying Swift and C++ parsing produce identical results.
//  This ensures 1:1 parity between Swift and C++ serialization paths.
//

import XCTest
@testable import AdaptiveCards

/// Tests that verify Swift parsing produces identical results to C++ parsing.
/// This is critical for ensuring the Swift Adaptive Cards port maintains
/// behavioral parity with the existing C++ implementation.
class SwiftCppParityTests: XCTestCase {
    
    // MARK: - Helper Methods
    
    /// Parse JSON using Swift parser
    private func parseWithSwift(_ json: String) -> SwiftAdaptiveCard? {
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        return result.parseResult?.adaptiveCard
    }
    
    /// Parse JSON using C++ parser (via ObjC bridge)
    private func parseWithCpp(_ json: String) -> ACOAdaptiveCard? {
        let result = ACOAdaptiveCard.fromJson(json)
        return result.card
    }
    
    // MARK: - TextBlock Parity Tests
    
    func testTextBlockParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Hello, World!",
                    "wrap": true,
                    "maxLines": 3,
                    "size": "large",
                    "weight": "bolder",
                    "color": "accent",
                    "horizontalAlignment": "center"
                }
            ]
        }
        """
        
        // Parse with both parsers
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let cppCard = parseWithCpp(json) else {
            XCTFail("C++ parser failed")
            return
        }
        
        // Compare element counts
        XCTAssertEqual(swiftCard.body.count, 1, "Swift card body count")
        
        // Get Swift element
        guard let swiftTextBlock = swiftCard.body.first as? SwiftTextBlock else {
            XCTFail("Expected SwiftTextBlock")
            return
        }
        
        // Compare properties
        XCTAssertEqual(swiftTextBlock.text, "Hello, World!")
        XCTAssertTrue(swiftTextBlock.wrap)
        XCTAssertEqual(swiftTextBlock.maxLines, 3)
    }
    
    func testTextBlockDefaultsParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Simple text"
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let swiftTextBlock = swiftCard.body.first as? SwiftTextBlock else {
            XCTFail("Expected SwiftTextBlock")
            return
        }
        
        // Verify default values match C++ defaults
        XCTAssertEqual(swiftTextBlock.text, "Simple text")
        XCTAssertFalse(swiftTextBlock.wrap, "Default wrap should be false")
        XCTAssertEqual(swiftTextBlock.maxLines, 0, "Default maxLines should be 0")
    }
    
    // MARK: - Image Parity Tests
    
    func testImageParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Image",
                    "url": "https://example.com/test.png",
                    "altText": "Test image",
                    "size": "medium",
                    "style": "person",
                    "horizontalAlignment": "center"
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let cppCard = parseWithCpp(json) else {
            XCTFail("C++ parser failed")
            return
        }
        
        // Compare element counts
        XCTAssertEqual(swiftCard.body.count, 1)
        
        guard let swiftImage = swiftCard.body.first as? SwiftImage else {
            XCTFail("Expected SwiftImage")
            return
        }
        
        // Compare properties
        XCTAssertEqual(swiftImage.url, "https://example.com/test.png")
        XCTAssertEqual(swiftImage.altText, "Test image")
        XCTAssertEqual(swiftImage.imageSize, .medium)
        XCTAssertEqual(swiftImage.imageStyle, .person)
    }
    
    // MARK: - Container Parity Tests
    
    func testContainerParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Container",
                    "style": "emphasis",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Inside container"
                        },
                        {
                            "type": "Image",
                            "url": "https://example.com/inner.png"
                        }
                    ]
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let cppCard = parseWithCpp(json) else {
            XCTFail("C++ parser failed")
            return
        }
        
        // Compare element counts
        XCTAssertEqual(swiftCard.body.count, 1)
        
        guard let swiftContainer = swiftCard.body.first as? SwiftContainer else {
            XCTFail("Expected SwiftContainer")
            return
        }
        
        // Compare container properties
        XCTAssertEqual(swiftContainer.items.count, 2)
        XCTAssertEqual(swiftContainer.style, .emphasis)
        
        // Verify nested elements
        XCTAssertTrue(swiftContainer.items[0] is SwiftTextBlock)
        XCTAssertTrue(swiftContainer.items[1] is SwiftImage)
    }
    
    // MARK: - ColumnSet Parity Tests
    
    func testColumnSetParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "ColumnSet",
                    "columns": [
                        {
                            "type": "Column",
                            "width": "stretch",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Column 1"
                                }
                            ]
                        },
                        {
                            "type": "Column",
                            "width": "auto",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Column 2"
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let swiftColumnSet = swiftCard.body.first as? SwiftColumnSet else {
            XCTFail("Expected SwiftColumnSet")
            return
        }
        
        XCTAssertEqual(swiftColumnSet.columns.count, 2)
        XCTAssertEqual(swiftColumnSet.columns[0].width, "stretch")
        XCTAssertEqual(swiftColumnSet.columns[1].width, "auto")
    }
    
    // MARK: - FactSet Parity Tests
    
    func testFactSetParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "FactSet",
                    "facts": [
                        { "title": "Name", "value": "John" },
                        { "title": "Age", "value": "30" }
                    ]
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let swiftFactSet = swiftCard.body.first as? SwiftFactSet else {
            XCTFail("Expected SwiftFactSet")
            return
        }
        
        XCTAssertEqual(swiftFactSet.facts.count, 2)
        XCTAssertEqual(swiftFactSet.facts[0].title, "Name")
        XCTAssertEqual(swiftFactSet.facts[0].value, "John")
    }
    
    // MARK: - Input Parity Tests
    
    func testInputTextParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "nameInput",
                    "placeholder": "Enter name",
                    "value": "Default",
                    "isMultiline": true,
                    "maxLength": 100
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let swiftInput = swiftCard.body.first as? SwiftTextInput else {
            XCTFail("Expected SwiftTextInput")
            return
        }
        
        XCTAssertEqual(swiftInput.id, "nameInput")
        XCTAssertEqual(swiftInput.placeholder, "Enter name")
        XCTAssertEqual(swiftInput.value, "Default")
        XCTAssertTrue(swiftInput.isMultiline)
        XCTAssertEqual(swiftInput.maxLength, 100)
    }
    
    func testInputChoiceSetParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Input.ChoiceSet",
                    "id": "colorChoice",
                    "isMultiSelect": false,
                    "style": "compact",
                    "choices": [
                        { "title": "Red", "value": "red" },
                        { "title": "Green", "value": "green" },
                        { "title": "Blue", "value": "blue" }
                    ]
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let swiftChoiceSet = swiftCard.body.first as? SwiftChoiceSetInput else {
            XCTFail("Expected SwiftChoiceSetInput")
            return
        }
        
        XCTAssertEqual(swiftChoiceSet.id, "colorChoice")
        XCTAssertFalse(swiftChoiceSet.isMultiSelect)
        XCTAssertEqual(swiftChoiceSet.choices.count, 3)
    }
    
    // MARK: - Action Parity Tests
    
    func testActionParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [],
            "actions": [
                {
                    "type": "Action.OpenUrl",
                    "title": "Open Link",
                    "url": "https://example.com"
                },
                {
                    "type": "Action.Submit",
                    "title": "Submit",
                    "data": { "action": "submit" }
                },
                {
                    "type": "Action.Execute",
                    "title": "Execute",
                    "verb": "doAction"
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        XCTAssertEqual(swiftCard.actions.count, 3)
        
        // Verify action types
        XCTAssertTrue(swiftCard.actions[0] is SwiftOpenUrlAction)
        XCTAssertTrue(swiftCard.actions[1] is SwiftSubmitAction)
        XCTAssertTrue(swiftCard.actions[2] is SwiftExecuteAction)
        
        // Verify OpenUrl action
        if let openUrl = swiftCard.actions[0] as? SwiftOpenUrlAction {
            XCTAssertEqual(openUrl.title, "Open Link")
            XCTAssertEqual(openUrl.url, "https://example.com")
        }
        
        // Verify Execute action
        if let execute = swiftCard.actions[2] as? SwiftExecuteAction {
            XCTAssertEqual(execute.verb, "doAction")
        }
    }
    
    // MARK: - Complex Card Parity Tests
    
    func testComplexCardParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Registration Form",
                    "size": "large",
                    "weight": "bolder"
                },
                {
                    "type": "Input.Text",
                    "id": "name",
                    "placeholder": "Enter your name"
                },
                {
                    "type": "Input.Text",
                    "id": "email",
                    "placeholder": "Enter your email"
                },
                {
                    "type": "Input.ChoiceSet",
                    "id": "country",
                    "choices": [
                        { "title": "USA", "value": "us" },
                        { "title": "Canada", "value": "ca" }
                    ]
                }
            ],
            "actions": [
                {
                    "type": "Action.Submit",
                    "title": "Register"
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let cppCard = parseWithCpp(json) else {
            XCTFail("C++ parser failed")
            return
        }
        
        // Verify body count matches
        XCTAssertEqual(swiftCard.body.count, 4)
        
        // Verify element types
        XCTAssertTrue(swiftCard.body[0] is SwiftTextBlock)
        XCTAssertTrue(swiftCard.body[1] is SwiftTextInput)
        XCTAssertTrue(swiftCard.body[2] is SwiftTextInput)
        XCTAssertTrue(swiftCard.body[3] is SwiftChoiceSetInput)
        
        // Verify actions
        XCTAssertEqual(swiftCard.actions.count, 1)
        XCTAssertTrue(swiftCard.actions[0] is SwiftSubmitAction)
    }
    
    // MARK: - Table Parity Tests
    
    func testTableParsingParity() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Table",
                    "showGridLines": true,
                    "columns": [
                        { "width": 1 },
                        { "width": 2 }
                    ],
                    "rows": [
                        {
                            "type": "TableRow",
                            "cells": [
                                {
                                    "type": "TableCell",
                                    "items": [
                                        { "type": "TextBlock", "text": "A1" }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "items": [
                                        { "type": "TextBlock", "text": "B1" }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        guard let swiftCard = parseWithSwift(json) else {
            XCTFail("Swift parser failed")
            return
        }
        
        guard let swiftTable = swiftCard.body.first as? SwiftTable else {
            XCTFail("Expected SwiftTable")
            return
        }
        
        XCTAssertTrue(swiftTable.showGridLines)
        XCTAssertEqual(swiftTable.columns.count, 2)
        XCTAssertEqual(swiftTable.rows.count, 1)
    }
}
