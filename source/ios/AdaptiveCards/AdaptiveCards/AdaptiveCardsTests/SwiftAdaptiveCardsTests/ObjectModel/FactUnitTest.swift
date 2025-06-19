//
//  FactUnitTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import AdaptiveCards

class FactTest: XCTestCase {
    
    func testDefineFromEmptyConstructor() {
        // Create an empty Fact instance
        var emptyFact = SwiftFact()
        XCTAssertTrue(emptyFact.title.isEmpty, "Expected title to be empty on initialization.")
        
        // Define & test title
        var testTitle = "1 Example Title!"
        emptyFact.title = testTitle
        XCTAssertEqual(emptyFact.title, testTitle, "Title should be set correctly.")
        
        // Define & test value
        var testValue = "1 Example Value!"
        emptyFact.value = testValue
        XCTAssertEqual(emptyFact.value, testValue, "Value should be set correctly.")
        
        // Test serialization
        let jsonData = emptyFact.serialize()
        XCTAssertEqual(jsonData, "{\"title\":\"1 Example Title!\",\"value\":\"1 Example Value!\"}\n", "Serialized JSON does not match expected output.")
        
        // Create parse context and test deserialization
        let context = SwiftParseContext()
        guard let parsedFact = SwiftFact.deserialize(fromString: jsonData, context: context) else {
            XCTFail("Deserialization failed to return a Fact instance.")
            return
        }
        
        XCTAssertEqual(emptyFact.title, parsedFact.title, "Deserialized Fact should have the same title.")
        XCTAssertEqual(emptyFact.value, parsedFact.value, "Deserialized Fact should have the same value.")
    }
}
