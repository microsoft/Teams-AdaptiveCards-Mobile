//
//  FontStylesUnitTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import AdaptiveCards

final class FontTypeTests: XCTestCase {
    
    func testDefineFromEmptyConstructor() throws {
        // Create an empty TextBlock instance.
        let emptyTB = SwiftTextBlock()
        
        // Initially, fontType should be nil.
        XCTAssertNil(emptyTB.fontType, "Expected fontType to be nil initially")
        
        // Directly assign fontType to Default.
        emptyTB.fontType = .defaultFont
        XCTAssertEqual(emptyTB.fontType, .defaultFont, "Expected fontType to be .defaultFont after setting")
        
        // Directly assign fontType to Monospace.
        emptyTB.fontType = .monospace
        XCTAssertEqual(emptyTB.fontType, .monospace, "Expected fontType to be .monospace after setting")
    }

    func testEmptyTextBlockSerialization() throws {
        // Create an empty TextBlock instance.
        let emptyTB = SwiftTextBlock()
        
        // Serialize the empty text block.
        let jsonString = try emptyTB.serialize()
        XCTAssertEqual(jsonString, "{\"text\":\"\",\"type\":\"TextBlock\"}\n", "Empty TextBlock serialization mismatch")
        
        // Create a ParseContext and parse the JSON back into a TextBlock.
        var context = SwiftParseContext()
        let parser = SwiftTextBlockParser()
        let parsedObject = try parser.deserialize(fromString: context, value: jsonString)
        
        guard let parsedTextBlock = parsedObject as? SwiftTextBlock else {
            XCTFail("Parsed object is not a TextBlock")
            return
        }
        
        // Since we haven't set a font type, both should be nil.
        XCTAssertEqual(emptyTB.fontType, parsedTextBlock.fontType, "Expected fontType to match after parsing")
    }
}
