//
//  UtilityFunctionsTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
@testable import AdaptiveCards

class UtilityFunctionsTests: XCTestCase {
    private var category: UtilityFunctions!
    
    override func setUp() {
        super.setUp()
        category = UtilityFunctions()
    }
    
    func testIfFunction() async throws {
        guard let function = category.functions["if"] else {
            XCTFail("if function not found")
            return
        }
        
        let result1 = try await function.callback([true, "yes", "no"])
        XCTAssertEqual(result1 as? String, "yes")
        
        let result2 = try await function.callback([false, "yes", "no"])
        XCTAssertEqual(result2 as? String, "no")
    }
    
    func testLengthFunction() async throws {
        guard let function = category.functions["length"] else {
            XCTFail("length function not found")
            return
        }
        
        // Test string
        let result1 = try await function.callback(["hello"])
        XCTAssertEqual(result1 as? Int, 5)
        
        // Test array
        let result2 = try await function.callback([[1, 2, 3, 4]])
        XCTAssertEqual(result2 as? Int, 4)
        
        // Test dictionary
        let result3 = try await function.callback([["a": 1, "b": 2]])
        XCTAssertEqual(result3 as? Int, 2)
    }
}
