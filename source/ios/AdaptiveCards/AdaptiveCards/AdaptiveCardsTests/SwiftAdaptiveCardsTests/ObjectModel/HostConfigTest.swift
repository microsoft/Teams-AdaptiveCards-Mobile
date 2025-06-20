//
//  HostConfigTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
import AdaptiveCards

final class HostConfigTests: XCTestCase {
    
    func testDeserializeTable() throws {
        let tableConfigJson = """
        {
           "table": {
               "cellSpacing": 11
           }
        }
        """
        let hostConfig = SwiftHostConfig.deserialize(from: tableConfigJson)
        // Instead of getTable(), we use the table property.
        let tableConfig = hostConfig.table
        XCTAssertEqual(tableConfig.cellSpacing, 11, "Expected cellSpacing to be 11")
    }
    
    func testDeserializeDefaultTable() throws {
        let hostConfig = SwiftHostConfig.deserialize(from: "{}")
        // Default table configuration should have cellSpacing == 8
        XCTAssertEqual(hostConfig.table.cellSpacing, 8, "Expected default cellSpacing to be 8")
    }
    
    func testDeserializeColumnHeader() throws {
        let columnHeaderJson = """
        {
            "textStyles": {
                "columnHeader": {
                    "size": "small",
                    "weight": "normal",
                    "color": "accent",
                    "isSubtle": true,
                    "fontType": "monospace"
                }
            }
        }
        """
        let hostConfig = SwiftHostConfig.deserialize(from: columnHeaderJson)
        // Instead of getTextStyles(), we use the textStyles property.
        let columnConfig = hostConfig.textStyles.columnHeader
        
        // Assuming that our Swift mapping converts "normal" to the default weight.
        XCTAssertEqual(columnConfig.weight, SwiftTextWeight.defaultWeight, "Expected weight to be default (normal)")
        XCTAssertEqual(columnConfig.size, SwiftTextSize.small, "Expected size to be Small")
        XCTAssertTrue(columnConfig.isSubtle, "Expected isSubtle to be true")
        XCTAssertEqual(columnConfig.color, SwiftForegroundColor.accent, "Expected color to be Accent")
        XCTAssertEqual(columnConfig.fontType, SwiftFontType.monospace, "Expected fontType to be Monospace")
    }
    
    func testDeserializeDefaultColumnHeader() throws {
        let hostConfig = SwiftHostConfig.deserialize(from: "{}")
        let actualConfig = hostConfig.textStyles.columnHeader
        let expectedConfig = SwiftTextStyleConfig(
            weight: .bolder,        // Expected weight: Bolder
            size: .defaultSize,     // Expected size: Default (i.e. "Normal")
            isSubtle: false,
            color: .default,        // Expected color: Default
            fontType: .defaultFont  // Expected fontType: Default
        )
        XCTAssertEqual(expectedConfig.weight, actualConfig.weight, "Expected weight to match")
        XCTAssertEqual(expectedConfig.size, actualConfig.size, "Expected size to match")
        XCTAssertEqual(expectedConfig.isSubtle, actualConfig.isSubtle, "Expected isSubtle to match")
        XCTAssertEqual(expectedConfig.color, actualConfig.color, "Expected color to match")
        XCTAssertEqual(expectedConfig.fontType, actualConfig.fontType, "Expected fontType to match")
    }
}
