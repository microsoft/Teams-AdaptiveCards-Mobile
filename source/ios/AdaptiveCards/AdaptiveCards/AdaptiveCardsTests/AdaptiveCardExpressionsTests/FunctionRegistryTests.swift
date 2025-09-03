//
//  FunctionRegistryTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
@testable import AdaptiveCards

class FunctionRegistryTests: XCTestCase {
    private var registry: FunctionRegistry!
    
    override func setUp() {
        super.setUp()
        registry = FunctionRegistry()
    }
    
    func testRegistryContainsAllCategories() {
        let functions = registry.getAllFunctions()
        
        // Test that all expected functions are registered
        XCTAssertNotNil(functions["round"])
        XCTAssertNotNil(functions["toUpper"])
        XCTAssertNotNil(functions["parseFloat"])
        XCTAssertNotNil(functions["if"])
        XCTAssertNotNil(functions["Date.format"])
    }
    
    func testGetFunction() {
        let roundFunction = registry.getFunction(name: "round")
        XCTAssertNotNil(roundFunction)
        XCTAssertEqual(roundFunction?.name, "round")
        
        let nonExistentFunction = registry.getFunction(name: "nonExistent")
        XCTAssertNil(nonExistentFunction)
    }
    
    func testGetFunctionsByCategory() {
        let mathFunctions = registry.getFunctionsByCategory("Math")
        XCTAssertTrue(mathFunctions.keys.contains("round"))
        XCTAssertTrue(mathFunctions.keys.contains("ceil"))
        XCTAssertTrue(mathFunctions.keys.contains("floor"))
        
        let stringFunctions = registry.getFunctionsByCategory("String")
        XCTAssertTrue(stringFunctions.keys.contains("toUpper"))
        XCTAssertTrue(stringFunctions.keys.contains("toLower"))
    }
    
    func testGetAllCategories() {
        let categories = registry.getAllCategories()
        let expectedCategories = Set(["Math", "String", "Conversion", "Utility", "Date"])
        XCTAssertEqual(Set(categories), expectedCategories)
    }
}
