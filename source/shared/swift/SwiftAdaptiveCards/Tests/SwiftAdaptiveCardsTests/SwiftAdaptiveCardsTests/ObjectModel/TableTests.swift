//
//  TableTests.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import SwiftAdaptiveCards

class TableTests: XCTestCase {
    
    func testTableCellParse() throws {
        let tableCellFragment = """
        {
            "type": "TableCell",
            "items": [
                {
                    "type": "TextBlock",
                    "text": "flim"
                },
                {
                    "type": "TextBlock",
                    "text": "iz-us"
                }
            ],
            "rtl": true
        }
        """

        let context = SwiftParseContext()
        // Use the throwing version that returns a TableCell.
        let tableCell = try SwiftTableCell.deserialize(from: tableCellFragment, context: context)
        
        // Ensure no additional properties exist.
        XCTAssertNil(tableCell.additionalProperties, "This TableCell shouldn't have any additionalProperties")
        
        // Ensure RTL is set.
        XCTAssertNotNil(tableCell.rtl)
        XCTAssertEqual(tableCell.rtl, true)
        
        // Ensure we get 2 items and that each item is a TextBlock.
        XCTAssertEqual(tableCell.items.count, 2, "This TableCell should have 2 items")
        for item in tableCell.items {
            // (If needed, qualify with the enum type:)
            XCTAssertEqual(item.elementTypeString, "TextBlock", "Each item in this cell should be a TextBlock")
        }
        
        // Ensure correct serialization.
        let serializedResult = try tableCell.serialize()
        let expected = "{\"items\":[{\"text\":\"flim\",\"type\":\"TextBlock\"},{\"text\":\"iz-us\",\"type\":\"TextBlock\"}],\"rtl\":true,\"type\":\"TableCell\"}\n"
        XCTAssertEqual(serializedResult, expected, "TableCell should roundtrip correctly")
    }

    func testTableEmptyParseTests() throws {
        let fragments = [
            "{\"type\":\"TableRow\"}\n",
            "{\"type\":\"Table\"}\n",
            "{\"items\":[],\"type\":\"TableCell\"}\n" // note: Container auto-emits items
        ]
        
        let context = SwiftParseContext()
        
        for fragment in fragments {
            // Assume ParseUtil.getJsonValue(from:) and BaseCardElement.parse(json:context:) exist.
            let jsonValue = SwiftParseUtil.getJsonValue(from: fragment)
            guard let element = SwiftBaseCardElement.parse(json: jsonValue, context: context) else {
                XCTFail("Failed to parse BaseCardElement")
                continue
            }
            let serializedObject = try element.serialize()
            XCTAssertEqual(serializedObject, fragment)
        }
    }
    
    func testTableRowParse() throws {
        let tableRowFragment = """
        {
            "type": "TableRow",
            "horizontalCellContentAlignment": "center",
            "verticalCellContentAlignment": "bottom",
            "style": "accent",
            "cells": [
                {
                    "type": "TableCell",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "the first"
                        },
                        {
                            "type": "TextBlock",
                            "text": "the first part deux"
                        }
                    ],
                    "rtl": true
                },
                {
                    "type": "TableCell",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "the second"
                        }
                    ],
                    "rtl": true
                }
            ]
        }
        """
        
        let context = SwiftParseContext()
        let tableRow = try SwiftTableRow.deserialize(from: tableRowFragment, context: context)
        
        XCTAssertNil(tableRow.additionalProperties, "This TableRow shouldn't have any additionalProperties")
        XCTAssertEqual(tableRow.cells.count, 2, "This TableRow should have 2 cells")
        XCTAssertEqual(tableRow.style, .accent)
        XCTAssertEqual(tableRow.horizontalCellContentAlignment, .center)
        XCTAssertEqual(tableRow.verticalCellContentAlignment, .bottom)
        
        let serializedResult = try tableRow.serialize()
        let expected = "{\"cells\":[{\"items\":[{\"text\":\"the first\",\"type\":\"TextBlock\"},{\"text\":\"the first part deux\",\"type\":\"TextBlock\"}],\"rtl\":true,\"type\":\"TableCell\"},{\"items\":[{\"text\":\"the second\",\"type\":\"TextBlock\"}],\"rtl\":true,\"type\":\"TableCell\"}],\"horizontalCellContentAlignment\":\"center\",\"style\":\"Accent\",\"type\":\"TableRow\",\"verticalCellContentAlignment\":\"Bottom\"}\n"
        XCTAssertEqual(serializedResult, expected)
    }
    
    func testTableElementsParserRegistration() throws {
        let context = SwiftParseContext()
        XCTAssertNotNil(context.elementParserRegistration?.getParser(for: "Table"), "Should be a registered parser for Table")
        XCTAssertNil(context.elementParserRegistration?.getParser(for: "TableRow"), "Should not be a registered parser for TableRow")
        XCTAssertNil(context.elementParserRegistration?.getParser(for: "TableCell"), "Should not be a registered parser for TableCell")
    }
    
    func testTableColumnDefinitionSimpleParse() throws {
        let columnDefinitionFragment = """
        {
            "horizontalCellContentAlignment": "center",
            "verticalCellContentAlignment": "bottom",
            "width": 1
        }
        """
        
        let context = SwiftParseContext()
        guard let columnDefinition = try? SwiftTableColumnDefinition.deserialize(context: context, from: columnDefinitionFragment) else {
            XCTFail("Failed to deserialize TableColumnDefinition")
            return
        }
        
        XCTAssertEqual(columnDefinition.width, 1)
        XCTAssertNil(columnDefinition.pixelWidth, "if we have a width, we shouldn't have a pixel width")
        XCTAssertEqual(columnDefinition.horizontalCellContentAlignment, .center)
        XCTAssertEqual(columnDefinition.verticalCellContentAlignment, .bottom)
        
        // Serialize and validate JSON content
        let serializedResult = try columnDefinition.serialize()
        
        // Parse both JSONs to compare content
        guard let resultData = serializedResult.data(using: .utf8),
              let resultJson = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any] else {
            XCTFail("Failed to parse serialized result")
            return
        }
        
        // Validate JSON structure and content
        XCTAssertEqual(resultJson["width"] as? Int, 1)
        XCTAssertEqual(resultJson["horizontalCellContentAlignment"] as? String, "center")
        XCTAssertEqual(resultJson["verticalCellContentAlignment"] as? String, "Bottom")
        
        // Verify no unexpected keys exist
        let expectedKeys = Set(["width", "horizontalCellContentAlignment", "verticalCellContentAlignment"])
        let actualKeys = Set(resultJson.keys)
        XCTAssertEqual(expectedKeys, actualKeys, "JSON should contain exactly the expected keys")
        // original - prob not necessary since vals matchup.
//        let expected = "{\"horizontalCellContentAlignment\":\"center\",\"verticalCellContentAlignment\":\"Bottom\",\"width\":1}\n"
    }
    
    func testTableColumnDefinitionPixelParse() throws {
        let columnDefinitionFragment = """
        {
            "horizontalCellContentAlignment": "right",
            "verticalCellContentAlignment": "center",
            "width": "100px"
        }
        """
        
        let context = SwiftParseContext()
        guard let columnDefinition = try? SwiftTableColumnDefinition.deserialize(context: context, from: columnDefinitionFragment) else {
            XCTFail("Failed to deserialize TableColumnDefinition")
            return
        }
        
        // Test the properties directly
        XCTAssertNil(columnDefinition.width, "if we have a pixel width, we shouldn't have a width")
        XCTAssertEqual(columnDefinition.pixelWidth, 100)
        XCTAssertEqual(columnDefinition.horizontalCellContentAlignment, .right)
        XCTAssertEqual(columnDefinition.verticalCellContentAlignment, .center)
        
        // Test serialization by parsing and validating the JSON content
        let serializedResult = try columnDefinition.serialize()
        
        guard let resultData = serializedResult.data(using: .utf8),
              let resultJson = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any] else {
            XCTFail("Failed to parse serialized result")
            return
        }
        
        // Validate JSON structure and content
        XCTAssertEqual(resultJson["width"] as? String, "100px", "Width should be serialized as '100px'")
        XCTAssertEqual(resultJson["horizontalCellContentAlignment"] as? String, "right")
        XCTAssertEqual(resultJson["verticalCellContentAlignment"] as? String, "Center", "Vertical alignment should be capitalized")
        
        // Verify no unexpected keys exist
        let expectedKeys = Set(["width", "horizontalCellContentAlignment", "verticalCellContentAlignment"])
        let actualKeys = Set(resultJson.keys)
        XCTAssertEqual(expectedKeys, actualKeys, "JSON should contain exactly the expected keys")
    }
    
    func testTableColumnDefinitionMissingUnitParse() throws {
        let columnDefinitionFragment = """
        {
            "width": "10"
        }
        """
        
        let context = SwiftParseContext()
        guard let columnDefinition = try? SwiftTableColumnDefinition.deserialize(context: context, from: columnDefinitionFragment) else {
            XCTFail("Failed to deserialize TableColumnDefinition")
            return
        }
        
        XCTAssertNil(columnDefinition.width, "A string width with no units should not result in width getting set")
        XCTAssertNil(columnDefinition.pixelWidth, "A string width with no units should not result in pixel width getting set")
        XCTAssertFalse(context.warnings.isEmpty, "Parsing a string with no units should yield warnings")
    }
    
    func testTableColumnDefinitionInvalidParse() throws {
        let columnDefinitionInvalidUnitFragment = """
        {
            "width": "10pixels"
        }
        """
        
        let context = SwiftParseContext()
        guard let columnDefinition = try? SwiftTableColumnDefinition.deserialize(context: context, from: columnDefinitionInvalidUnitFragment) else {
            XCTFail("Failed to deserialize TableColumnDefinition")
            return
        }
        
        XCTAssertNil(columnDefinition.width)
        XCTAssertFalse(context.warnings.isEmpty, "Parsing a string with no units should yield warnings")
    }
    
    func testTableFragmentParseValid() throws {
        let tableFragment = """
        {
            "type": "Table",
            "gridStyle": "accent",
            "firstRowAsHeaders": true,
            "columns": [
                {
                    "width": 1
                },
                {
                    "width": 1
                },
                {
                    "width": 3
                }
            ],
            "rows": [
                {
                    "type": "TableRow",
                    "cells": [
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Name",
                                    "wrap": true,
                                    "weight": "Bolder"
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Type",
                                    "wrap": true,
                                    "weight": "Bolder"
                                }
                            ]
                        },
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "Description",
                                    "wrap": true,
                                    "weight": "Bolder"
                                }
                            ]
                        }
                    ],
                    "style": "accent"
                }
            ]
        }
        """
        
        let context = SwiftParseContext()
        guard let jsonData = tableFragment.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            XCTFail("Failed to parse JSON")
            return
        }
        
        do {
            let tableParser = SwiftTableParser()
            // Let's see the actual error
            // Add debug logging
            print("JSON to parse: \(jsonDict)")
            if let typeString = jsonDict["type"] as? String {
                print("Type string from JSON: \(typeString)")
            }
            
            let tableAny: any SwiftAdaptiveCardElementProtocol
            do {
                tableAny = try tableParser.deserialize(context: context, value: jsonDict)
            } catch {
                XCTFail("Failed to deserialize Table with error: \(error)")
                print("Full error details: \(String(describing: error))")
                return
            }
            
            guard let table = tableAny as? SwiftTable else {
                XCTFail("Deserialized object is not a Table type, got: \(type(of: tableAny))")
                return
            }
            // Test basic table properties
            XCTAssertEqual(table.gridStyle, .accent)
            XCTAssertTrue(table.firstRowAsHeaders)
            XCTAssertNil(table.additionalProperties)
            
            // Test columns
            XCTAssertEqual(table.columns.count, 3, "Should have 3 columns")
            let expectedWidths = [1, 1, 3]
            for (index, column) in table.columns.enumerated() {
                XCTAssertNotNil(column.width, "Column \(index) should have width")
                XCTAssertNil(column.pixelWidth, "Column \(index) should not have pixel width")
                XCTAssertEqual(column.width, UInt(expectedWidths[index]), "Column \(index) should have width \(expectedWidths[index])")
            }
            
            // Test rows
            XCTAssertEqual(table.rows.count, 1, "Should have 1 row")
            if let firstRow = table.rows.first {
                XCTAssertEqual(firstRow.style, .accent)
                XCTAssertEqual(firstRow.cells.count, 3, "First row should have 3 cells")
                
                // Test cells in first row
                let expectedTexts = ["Name", "Type", "Description"]
                for (index, cell) in firstRow.cells.enumerated() {
                    XCTAssertEqual(cell.items.count, 1, "Cell \(index) should have 1 item")
                    if let textBlock = cell.items.first as? SwiftTextBlock {
                        XCTAssertEqual(textBlock.text, expectedTexts[index])
                        XCTAssertTrue(textBlock.wrap ?? false)
                        XCTAssertEqual(textBlock.textWeight, .bolder)
                    } else {
                        XCTFail("Cell \(index) should contain a TextBlock")
                    }
                }
            }
            
            // Test serialization structure (without exact string matching)
            let serializedResult = try table.serialize()
            guard let resultData = serializedResult.data(using: .utf8),
                  let resultJson = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any] else {
                XCTFail("Failed to parse serialized result")
                return
            }
            
            // Verify key structure
            XCTAssertNotNil(resultJson["columns"])
            XCTAssertNotNil(resultJson["rows"])
            XCTAssertEqual(resultJson["gridStyle"] as? String, "Accent")
            XCTAssertEqual(resultJson["type"] as? String, "Table")
            
        } catch {
            XCTFail("Deserialization failed with error: \(error)")
        }
    }
    
    func testTableCardParseValid() throws {
        let tableCard = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "Table",
                    "gridStyle": "accent",
                    "firstRowAsHeaders": true,
                    "columns": [
                        {
                            "width": 1
                        },
                        {
                            "width": 1
                        },
                        {
                            "width": 3
                        }
                    ],
                    "rows": [
                        {
                            "type": "TableRow",
                            "cells": [
                                {
                                    "type": "TableCell",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Name",
                                            "wrap": true,
                                            "weight": "Bolder"
                                        }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Type",
                                            "wrap": true,
                                            "weight": "Bolder"
                                        }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Description",
                                            "wrap": true,
                                            "weight": "Bolder"
                                        }
                                    ]
                                }
                            ],
                            "style": "accent"
                        },
                        {
                            "type": "TableRow",
                            "cells": [
                                {
                                    "type": "TableCell",
                                    "style": "good",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "columns",
                                            "wrap": true
                                        }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "style": "warning",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "some text",
                                            "wrap": true
                                        }
                                    ]
                                },
                                {
                                    "type": "TableCell",
                                    "style": "accent",
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "some text #2",
                                            "wrap": true
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
        
        // Deserialize and test type
        let result = try SwiftAdaptiveCard.deserializeFromString(tableCard, version: "1.5")
        let card = result.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 1)
        let bodyElem = body.first!
        XCTAssertEqual(bodyElem.elementTypeString, "Table")
        
        // Serialize and compare JSON objects instead of strings
        let serializedCard = try card.serialize()
        let expected = "{\"actions\":[],\"body\":[{\"columns\":[{\"width\":1},{\"width\":1},{\"width\":3}],\"gridStyle\":\"Accent\",\"rows\":[{\"cells\":[{\"items\":[{\"text\":\"Name\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"Type\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"},{\"items\":[{\"text\":\"Description\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"}],\"style\":\"Accent\",\"type\":\"TableRow\"},{\"cells\":[{\"items\":[{\"text\":\"columns\",\"type\":\"TextBlock\",\"wrap\":true}],\"style\":\"Good\",\"type\":\"TableCell\"},{\"items\":[{\"text\":\"some text\",\"type\":\"TextBlock\",\"wrap\":true}],\"style\":\"Warning\",\"type\":\"TableCell\"},{\"items\":[{\"text\":\"some text #2\",\"type\":\"TextBlock\",\"wrap\":true}],\"style\":\"Accent\",\"type\":\"TableCell\"}],\"type\":\"TableRow\"}],\"type\":\"Table\"}],\"type\":\"AdaptiveCard\",\"version\":\"1.5\"}\n"
        
        // Parse both JSON strings into dictionaries
        guard let serializedData = serializedCard.data(using: .utf8),
              let expectedData = expected.data(using: .utf8),
              let serializedJson = try? JSONSerialization.jsonObject(with: serializedData) as? [String: Any],
              let expectedJson = try? JSONSerialization.jsonObject(with: expectedData) as? [String: Any] else {
            XCTFail("Failed to parse JSON strings")
            return
        }
        
        // Compare the entire structures recursively
        func compareJson(_ actual: Any, _ expected: Any, path: String = "") throws {
            // Handle different types
            switch (actual, expected) {
            case let (actualDict as [String: Any], expectedDict as [String: Any]):
                // Compare dictionaries
                for (key, expectedValue) in expectedDict {
                    guard let actualValue = actualDict[key] else {
                        XCTFail("Missing key '\(key)' at path: \(path)")
                        continue
                    }
                    try compareJson(actualValue, expectedValue, path: "\(path).\(key)")
                }
                
            case let (actualArray as [Any], expectedArray as [Any]):
                // Compare arrays
                guard actualArray.count == expectedArray.count else {
                    XCTFail("Array count mismatch at path: \(path)")
                    return
                }
                for i in 0..<actualArray.count {
                    try compareJson(actualArray[i], expectedArray[i], path: "\(path)[\(i)]")
                }
                
            case let (actualValue as String, expectedValue as String):
                // Compare strings case-sensitively
                XCTAssertEqual(actualValue, expectedValue, "String mismatch at path: \(path)")
                
            default:
                // Compare other values
                XCTAssertEqual(String(describing: actual), String(describing: expected), "Value mismatch at path: \(path)")
            }
        }
        
        // Perform the comparison
        try compareJson(serializedJson, expectedJson)
    }
    
    func testTableCardParseOrphanedTableRow() throws {
        let tableCard = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "TableRow",
                    "cells": [
                        {
                            "type": "TableCell",
                            "items": [
                                {
                                    "type": "TextBlock",
                                    "text": "..."
                                }
                            ]
                        }
                    ]
                }
            ]
        }
        """
        
        let result = try SwiftAdaptiveCard.deserializeFromString(tableCard, version: "1.5")
        let card = result.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 1)
        let bodyElem = body.first!
        XCTAssertEqual(bodyElem.elementTypeString, "TableRow", "An orphaned TableRow should deserialize with its type string intact")
        XCTAssertEqual(bodyElem.elementTypeVal, .unknown, "An orphaned TableRow should be implemented as UnknownElement")
        
        let serializedCard = try card.serialize()
        let expected = "{\"actions\":[],\"body\":[{\"cells\":[{\"items\":[{\"text\":\"...\",\"type\":\"TextBlock\"}],\"type\":\"TableCell\"}],\"type\":\"TableRow\"}],\"type\":\"AdaptiveCard\",\"version\":\"1.5\"}\n"
        XCTAssertEqual(serializedCard, expected)
    }
    
    func testTableCardParseOrphanedTableCell() throws {
        let tableCard = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "TableCell",
                    "items": [
                        {
                            "type": "TextBlock",
                            "text": "Name",
                            "wrap": true,
                            "weight": "Bolder"
                        }
                    ]
                }
            ]
        }
        """
        
        let result = try SwiftAdaptiveCard.deserializeFromString(tableCard, version: "1.5")
        let card = result.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 1)
        let bodyElem = body.first!
        XCTAssertEqual(bodyElem.elementTypeString, "TableCell", "An orphaned TableCell should deserialize with its type string intact")
        XCTAssertEqual(bodyElem.elementTypeVal, .unknown, "An orphaned TableCell should be implemented as UnknownElement")
        
        let serializedCard = try card.serialize()
        let expected = "{\"actions\":[],\"body\":[{\"items\":[{\"text\":\"Name\",\"type\":\"TextBlock\",\"weight\":\"Bolder\",\"wrap\":true}],\"type\":\"TableCell\"}],\"type\":\"AdaptiveCard\",\"version\":\"1.5\"}\n"
        XCTAssertEqual(serializedCard, expected)
    }
    
    func testTableCardParseWithImpliedTypes() throws {
        let tableCard = """
        {
            "type": "AdaptiveCard",
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "version": "1.5",
            "body": [
                {
                    "type": "Table",
                    "columns": [
                        {
                            "width": 1
                        }
                    ],
                    "rows": [
                        {
                            "cells": [
                                {
                                    "items": [
                                        {
                                            "type": "TextBlock",
                                            "text": "Text goes here."
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
        
        let result = try SwiftAdaptiveCard.deserializeFromString(tableCard, version: "1.5")
        let card = result.adaptiveCard
        let body = card.body
        XCTAssertEqual(body.count, 1)
        let bodyElem = body.first!
        XCTAssertEqual(bodyElem.elementTypeVal, .table, "Only item in the body should be a Table")
        
        guard let table = bodyElem as? SwiftTable else {
            XCTFail("Expected body element to be a Table")
            return
        }
        
        XCTAssertEqual(table.columns.count, 1, "Should be only one column")
        XCTAssertEqual(table.rows.count, 1, "Should be only one row")
        
        let row = table.rows.first!
        XCTAssertEqual(row.elementTypeVal, .tableRow, "Should be a real TableRow")
        XCTAssertEqual(row.cells.count, 1, "Should be only one cell")
        
        let cell = row.cells.first!
        XCTAssertEqual(cell.elementTypeVal, .tableCell, "Should be a real TableCell")
    }
}
