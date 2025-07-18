//
//  ElementTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
import AdaptiveCards

final class ElementTests: XCTestCase {

    func testColumnPixelWidth() throws {
        // 1) Create a fresh Column instance
        let columnTest = SwiftColumn()
        
        // 2) Verify default width/pixelWidth/serialized JSON
        XCTAssertEqual(columnTest.pixelWidth, 0, "Default pixelWidth should be 0")
        XCTAssertEqual(columnTest.width, "Auto", "Default width should be 'Auto'")
        
        let defaultSerialized = try columnTest.serialize()
        XCTAssertEqual(
            defaultSerialized,
            "{\"items\":[],\"type\":\"Column\",\"width\":\"Auto\"}\n",
            "Default Column serialization mismatch"
        )
        
        // 3) Set width to "20px", verify changes
        columnTest.width = "20px"
        XCTAssertEqual(columnTest.pixelWidth, 20, "pixelWidth should parse '20px' -> 20")
        XCTAssertEqual(columnTest.width, "20px", "width property should remain '20px'")
        
        let px20Serialized = try columnTest.serialize()
        XCTAssertEqual(
            px20Serialized,
            "{\"items\":[],\"type\":\"Column\",\"width\":\"20px\"}\n",
            "'20px' Column serialization mismatch"
        )
        
        // 4) Set pixelWidth = 40, verify width -> "40px"
        columnTest.pixelWidth = 40
        XCTAssertEqual(columnTest.pixelWidth, 40, "pixelWidth should remain 40")
        XCTAssertEqual(columnTest.width, "40px", "width property should become '40px'")
        
        let px40Serialized = try columnTest.serialize()
        XCTAssertEqual(
            px40Serialized,
            "{\"items\":[],\"type\":\"Column\",\"width\":\"40px\"}\n",
            "'40px' Column serialization mismatch"
        )
        
        // 5) Set width to "Stretch", verify pixelWidth resets to 0
        columnTest.width = "Stretch"
        XCTAssertEqual(columnTest.pixelWidth, 0, "pixelWidth should reset to 0 when width not in px")
        XCTAssertEqual(columnTest.width, "stretch", "width property should become 'stretch' (lowercased in your logic?)")
        
        let stretchSerialized = try columnTest.serialize()
        XCTAssertEqual(
            stretchSerialized,
            "{\"items\":[],\"type\":\"Column\",\"width\":\"stretch\"}\n",
            "'Stretch' Column serialization mismatch"
        )
    }
    
    func testColumnWidthDecodingFromJSON() throws {
        // Test numeric width decoding
        let numericWidthJSON = """
        {
            "type": "Column",
            "width": 1,
            "items": []
        }
        """
        
        let columnWithNumericWidth = try SwiftColumn.deserialize(from: numericWidthJSON) as! SwiftColumn
        XCTAssertEqual(columnWithNumericWidth.width, "1", "Numeric width should be converted to string '1'")
        
        // Test string width decoding
        let stringWidthJSON = """
        {
            "type": "Column",
            "width": "stretch",
            "items": []
        }
        """
        
        let columnWithStringWidth = try SwiftColumn.deserialize(from: stringWidthJSON) as! SwiftColumn
        XCTAssertEqual(columnWithStringWidth.width, "stretch", "String width should remain 'stretch'")
        
        // Test pixel width decoding
        let pixelWidthJSON = """
        {
            "type": "Column",
            "width": "50px", 
            "items": []
        }
        """
        
        let columnWithPixelWidth = try SwiftColumn.deserialize(from: pixelWidthJSON) as! SwiftColumn
        XCTAssertEqual(columnWithPixelWidth.width, "50px", "Pixel width should remain '50px'")
        XCTAssertEqual(columnWithPixelWidth.pixelWidth, 50, "Pixel width should be parsed to 50")
        
        // Test integer numeric width decoding
        let integerWidthJSON = """
        {
            "type": "Column",
            "width": 2,
            "items": []
        }
        """
        
        let columnWithIntegerWidth = try SwiftColumn.deserialize(from: integerWidthJSON) as! SwiftColumn
        XCTAssertEqual(columnWithIntegerWidth.width, "2", "Integer width should be converted to string '2'")
        
        // Test decimal numeric width decoding
        let decimalWidthJSON = """
        {
            "type": "Column",
            "width": 1.5,
            "items": []
        }
        """
        
        let columnWithDecimalWidth = try SwiftColumn.deserialize(from: decimalWidthJSON) as! SwiftColumn
        XCTAssertEqual(columnWithDecimalWidth.width, "2", "Decimal width should be rounded to string '2'")
    }
}
