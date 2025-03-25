//
//  ElementTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import SwiftAdaptiveCards

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
}
