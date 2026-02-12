//
//  SwiftRenderingFlagTests.swift
//  AdaptiveCardsTests
//
//  Tests for the Swift rendering flag and bridge routing.
//  Verifies that the ECS flag properly controls rendering path selection.
//

import XCTest
@testable import AdaptiveCards

/// Tests for Swift rendering flag functionality.
/// Verifies that the feature flag properly controls Swift vs C++ rendering paths.
class SwiftRenderingFlagTests: XCTestCase {
    
    // MARK: - Flag State Tests
    
    func testSwiftParserCanBeEnabled() {
        // Store original state
        let originalState = SwiftAdaptiveCardParser.isSwiftParserEnabled()
        
        // Enable Swift parser
        SwiftAdaptiveCardParser.setSwiftParserEnabled(true)
        XCTAssertTrue(SwiftAdaptiveCardParser.isSwiftParserEnabled(), 
                     "Swift parser should be enabled after setting to true")
        
        // Disable Swift parser
        SwiftAdaptiveCardParser.setSwiftParserEnabled(false)
        XCTAssertFalse(SwiftAdaptiveCardParser.isSwiftParserEnabled(), 
                      "Swift parser should be disabled after setting to false")
        
        // Restore original state
        SwiftAdaptiveCardParser.setSwiftParserEnabled(originalState)
    }
    
    // MARK: - SwiftElementPropertyAccessor Tests
    
    func testPropertyAccessorWithSwiftTextBlock() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "TextBlock",
                    "text": "Test Text",
                    "wrap": true,
                    "maxLines": 5
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let textBlock = card.body.first else {
            XCTFail("Expected body element")
            return
        }
        
        // Test accessor methods
        let text = SwiftElementPropertyAccessor.getTextBlockText(textBlock)
        XCTAssertEqual(text, "Test Text")
        
        let wrap = SwiftElementPropertyAccessor.getTextBlockWrap(textBlock)
        XCTAssertTrue(wrap)
        
        let maxLines = SwiftElementPropertyAccessor.getTextBlockMaxLines(textBlock)
        XCTAssertEqual(maxLines, 5)
    }
    
    func testPropertyAccessorWithSwiftImage() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Image",
                    "url": "https://example.com/image.png",
                    "altText": "Test Image"
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let image = card.body.first else {
            XCTFail("Expected body element")
            return
        }
        
        let url = SwiftElementPropertyAccessor.getImageUrl(image)
        XCTAssertEqual(url, "https://example.com/image.png")
        
        let altText = SwiftElementPropertyAccessor.getImageAltText(image)
        XCTAssertEqual(altText, "Test Image")
    }
    
    func testPropertyAccessorWithSwiftContainer() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Container",
                    "style": "emphasis",
                    "items": [
                        { "type": "TextBlock", "text": "Item 1" },
                        { "type": "TextBlock", "text": "Item 2" }
                    ]
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let container = card.body.first else {
            XCTFail("Expected body element")
            return
        }
        
        let items = SwiftElementPropertyAccessor.getContainerItems(container)
        XCTAssertEqual(items.count, 2)
        
        let style = SwiftElementPropertyAccessor.getContainerStyle(container)
        XCTAssertEqual(style, 2) // emphasis = 2
    }
    
    func testPropertyAccessorWithSwiftFactSet() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "FactSet",
                    "facts": [
                        { "title": "Key", "value": "Value" }
                    ]
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let factSet = card.body.first else {
            XCTFail("Expected body element")
            return
        }
        
        let facts = SwiftElementPropertyAccessor.getFactSetFacts(factSet)
        XCTAssertEqual(facts.count, 1)
        
        if let firstFact = facts.first {
            let title = SwiftElementPropertyAccessor.getFactTitle(firstFact)
            XCTAssertEqual(title, "Key")
            
            let value = SwiftElementPropertyAccessor.getFactValue(firstFact)
            XCTAssertEqual(value, "Value")
        }
    }
    
    // MARK: - Input Property Accessor Tests
    
    func testPropertyAccessorWithSwiftTextInput() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Input.Text",
                    "id": "testInput",
                    "placeholder": "Enter text",
                    "value": "Default",
                    "isMultiline": true
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let input = card.body.first else {
            XCTFail("Expected body element")
            return
        }
        
        let placeholder = SwiftElementPropertyAccessor.getTextInputPlaceholder(input)
        XCTAssertEqual(placeholder, "Enter text")
        
        let value = SwiftElementPropertyAccessor.getTextInputValue(input)
        XCTAssertEqual(value, "Default")
        
        let isMultiline = SwiftElementPropertyAccessor.getTextInputIsMultiline(input)
        XCTAssertTrue(isMultiline)
    }
    
    // MARK: - Action Property Accessor Tests
    
    func testPropertyAccessorWithSwiftOpenUrlAction() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [],
            "actions": [
                {
                    "type": "Action.OpenUrl",
                    "title": "Open",
                    "url": "https://example.com"
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let action = card.actions.first else {
            XCTFail("Expected action")
            return
        }
        
        let url = SwiftElementPropertyAccessor.getOpenUrlActionUrl(action)
        XCTAssertEqual(url, "https://example.com")
    }
    
    func testPropertyAccessorWithSwiftExecuteAction() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [],
            "actions": [
                {
                    "type": "Action.Execute",
                    "title": "Execute",
                    "verb": "doAction"
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let action = card.actions.first else {
            XCTFail("Expected action")
            return
        }
        
        let verb = SwiftElementPropertyAccessor.getExecuteActionVerb(action)
        XCTAssertEqual(verb, "doAction")
    }
    
    // MARK: - ColumnSet Property Accessor Tests
    
    func testPropertyAccessorWithSwiftColumnSet() throws {
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
                                { "type": "TextBlock", "text": "Col 1" }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let columnSet = card.body.first else {
            XCTFail("Expected body element")
            return
        }
        
        let columns = SwiftElementPropertyAccessor.getColumnSetColumns(columnSet)
        XCTAssertEqual(columns.count, 1)
        
        if let firstColumn = columns.first {
            let width = SwiftElementPropertyAccessor.getColumnWidth(firstColumn)
            XCTAssertEqual(width, "stretch")
            
            let items = SwiftElementPropertyAccessor.getColumnItems(firstColumn)
            XCTAssertEqual(items.count, 1)
        }
    }
    
    // MARK: - Table Property Accessor Tests
    
    func testPropertyAccessorWithSwiftTable() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                {
                    "type": "Table",
                    "showGridLines": true,
                    "columns": [{ "width": 1 }],
                    "rows": [
                        {
                            "type": "TableRow",
                            "cells": [
                                {
                                    "type": "TableCell",
                                    "items": [
                                        { "type": "TextBlock", "text": "Cell" }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        guard let table = card.body.first else {
            XCTFail("Expected body element")
            return
        }
        
        let columns = SwiftElementPropertyAccessor.getTableColumns(table)
        XCTAssertEqual(columns.count, 1)
        
        let rows = SwiftElementPropertyAccessor.getTableRows(table)
        XCTAssertEqual(rows.count, 1)
        
        let showGridLines = SwiftElementPropertyAccessor.getTableShowGridLines(table)
        XCTAssertTrue(showGridLines)
    }
    
    // MARK: - Type Detection Tests
    
    func testElementTypeDetection() throws {
        let json = """
        {
            "type": "AdaptiveCard",
            "version": "1.5",
            "body": [
                { "type": "TextBlock", "text": "Text" },
                { "type": "Image", "url": "https://example.com/img.png" },
                { "type": "Container", "items": [] }
            ]
        }
        """
        
        let result = SwiftAdaptiveCardParser.parse(payload: json)
        guard let card = result.parseResult?.adaptiveCard else {
            XCTFail("Failed to parse card")
            return
        }
        
        XCTAssertEqual(card.body.count, 3)
        
        // Test type strings
        let textBlockType = SwiftElementPropertyAccessor.getTypeString(from: card.body[0])
        XCTAssertEqual(textBlockType, "TextBlock")
        
        let imageType = SwiftElementPropertyAccessor.getTypeString(from: card.body[1])
        XCTAssertEqual(imageType, "Image")
        
        let containerType = SwiftElementPropertyAccessor.getTypeString(from: card.body[2])
        XCTAssertEqual(containerType, "Container")
    }
}
