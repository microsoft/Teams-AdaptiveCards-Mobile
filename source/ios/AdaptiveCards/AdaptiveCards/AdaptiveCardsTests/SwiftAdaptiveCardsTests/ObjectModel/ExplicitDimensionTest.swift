//
//  ExplicitDimensionTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import AdaptiveCards

class ExplicitDimensionTest: XCTestCase {
    
    func testPositiveTest() throws {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "Image",
              "url": "Image",
              "width": "10px",
              "height": "50px"
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let image = card.body.first as? SwiftImage else {
            XCTFail("Image element not parsed")
            return
        }
        XCTAssertEqual(image.pixelWidth, 10)
        XCTAssertEqual(image.pixelHeight, 50)
    }
    
    func testPositiveTestWithOneDimensionOnly() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "Image",
              "url": "Image",
              "height": "10px"
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let image = card.body.first as? SwiftImage else {
            XCTFail("Image element not parsed")
            return
        }
        XCTAssertEqual(image.pixelHeight, 10)
        XCTAssertEqual(image.pixelWidth, 0)
    }
    
    func testMalformedUnitTest() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "Image",
              "url": "Image",
              "height": "10pic"
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let _ = card.body.first as? SwiftImage else {
            XCTFail("Image element not parsed")
            return
        }
        XCTAssertEqual(parseResult?.warnings.count, 1)
        if let warning = parseResult?.warnings.first {
            XCTAssertEqual(warning.statusCode, .invalidDimensionSpecified)
        }
    }
    
    func testMalformedUnitLengthTest() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "Image",
              "url": "Image",
              "height": "10px  "
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let _ = card.body.first as? SwiftImage else {
            XCTFail("Image element not parsed")
            return
        }
        XCTAssertEqual(parseResult?.warnings.count, 1)
        if let warning = parseResult?.warnings.first {
            XCTAssertEqual(warning.statusCode, .invalidDimensionSpecified)
        }
    }
    
    func testMalformedUnitTypeTest() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "Image",
              "url": "Image",
              "height": "10.0px"
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let image = card.body.first as? SwiftImage else {
            XCTFail("Image element not parsed")
            return
        }
        XCTAssertEqual(parseResult?.warnings.count, 0)
        XCTAssertEqual(image.pixelHeight, 10)
        XCTAssertEqual(image.pixelWidth, 0)
    }
    
    func testMalformedNegativeIntValueTest() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "Image",
              "url": "Image",
              "height": "-10px"
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let _ = card.body.first as? SwiftImage else {
            XCTFail("Image element not parsed")
            return
        }
        XCTAssertEqual(parseResult?.warnings.count, 1)
        if let warning = parseResult?.warnings.first {
            XCTAssertEqual(warning.statusCode, .invalidDimensionSpecified)
        }
    }
    
    func testMalformedDimensionValuesTest() {
        let payloads = [
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.0",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": ".20px",
                  "height": "50.1234.12px"
                }
              ]
            }
            """,
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.0",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": "20, 00px",
                  "height": "20,0.00   px"
                }
              ]
            }
            """,
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.0",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": "2000 px",
                  "height": "20a0px"
                }
              ]
            }
            """,
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.0",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": "20.a00px",
                  "height": "20.00"
                }
              ]
            }
            """,
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.0",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": " 20.00px",
                  "height": "2 0.00px"
                }
              ]
            }
            """,
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.0",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": "200px .00px",
                  "height": "2 0px00px"
                }
              ]
            }
            """,
            // Duplicate payload omitted in C++ test; next payload in this file:
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.1",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": "200.00 px",
                  "height": "200.0.px"
                }
              ]
            }
            """,
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.1",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": "20,000px",
                  "height": "20,000.0px"
                }
              ]
            }
            """,
            """
            {
              "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
              "type": "AdaptiveCard",
              "version": "1.1",
              "body": [
                {
                  "type": "Image",
                  "url": "http://adaptivecards.io/content/cats/1.png",
                  "width": "20.px",
                  "height": "050px"
                }
              ]
            }
            """
        ]
        
        for payload in payloads {
            let parseResult = try? SwiftAdaptiveCard.deserializeFromString(payload, version: "1.1")
            guard let card = parseResult?.adaptiveCard,
                  let image = card.body.first as? SwiftImage else {
                XCTFail("Image element not parsed")
                continue
            }
            XCTAssertEqual(parseResult?.warnings.count, 2)
            XCTAssertEqual(image.pixelHeight, 0)
            XCTAssertEqual(image.pixelWidth, 0)
        }
    }
    
    // MARK: - MinHeight Tests
    
    private func validateColumnSetMinHeight() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.2",
          "body": [
            {
              "type": "ColumnSet",
              "minHeight": "50px",
              "columns": [
                {
                  "type": "Column",
                  "minHeight": "75px",
                  "items": [
                    {
                      "type": "TextBlock",
                      "text": "Column 1"
                    }
                  ]
                }
              ]
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        guard let card = parseResult?.adaptiveCard,
              let columnSet = card.body.first as? SwiftColumnSet,
              let column = columnSet.columns.first else {
            XCTFail("ColumnSet/Column not parsed")
            return
        }
        XCTAssertEqual(columnSet.minHeight, 50)
        XCTAssertEqual(column.minHeight, 75)
    }
    
    private func validateContainerMinHeight() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.2",
          "body": [
            {
              "type": "Container",
              "minHeight": "100px",
              "items": [
                {
                  "type": "TextBlock",
                  "text": "This is some text"
                }
              ]
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        guard let card = parseResult?.adaptiveCard,
              let container = card.body.first as? SwiftContainer else {
            XCTFail("Container not parsed")
            return
        }
        XCTAssertEqual(container.minHeight, 100)
    }
    
    private func validateAdaptiveCardMinHeight() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.2",
          "minHeight": "100px",
          "body": [
            {
              "type": "TextBlock",
              "text": "This is some text"
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.2")
        guard let card = parseResult?.adaptiveCard else {
            XCTFail("AdaptiveCard not parsed")
            return
        }
        XCTAssertEqual(card.minHeight, 100)
    }
    
    func testMinHeightForAllElementsTest() {
        /*
         TODO
        validateColumnSetMinHeight()
        validateContainerMinHeight()
         */
        validateAdaptiveCardMinHeight()
    }
}

class ExplicitDimensionForColumnTest: XCTestCase {
    
    func testPositiveValueTest() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "ColumnSet",
              "columns": [
                {
                  "type": "Column",
                  "width": "auto",
                  "items": []
                }
              ]
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let columnSet = card.body.first as? SwiftColumnSet,
              let column = columnSet.columns.first else {
            XCTFail("ColumnSet/Column not parsed")
            return
        }
        XCTAssertEqual(column.width, "auto")
    }
    
    func testPositiveRelativeWidthTest() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "ColumnSet",
              "columns": [
                {
                  "type": "Column",
                  "width": "20",
                  "items": []
                }
              ]
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let columnSet = card.body.first as? SwiftColumnSet,
              let column = columnSet.columns.first else {
            XCTFail("ColumnSet/Column not parsed")
            return
        }
        XCTAssertEqual(column.width, "20")
        // For relative widths, pixelWidth should not match the literal relative value.
        XCTAssertNotEqual(column.pixelWidth, 20)
    }
    
    func testPositiveExplicitWidthTest() {
        let testJsonString = """
        {
          "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
          "type": "AdaptiveCard",
          "version": "1.0",
          "body": [
            {
              "type": "ColumnSet",
              "columns": [
                {
                  "type": "Column",
                  "width": "20px",
                  "items": []
                }
              ]
            }
          ]
        }
        """
        let parseResult = try? SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        guard let card = parseResult?.adaptiveCard,
              let columnSet = card.body.first as? SwiftColumnSet,
              let column = columnSet.columns.first else {
            XCTFail("ColumnSet/Column not parsed")
            return
        }
        XCTAssertEqual(column.width, "20px")
        XCTAssertEqual(column.pixelWidth, 20)
    }
}
