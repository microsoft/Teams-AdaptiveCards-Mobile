//
//  MathFunctionsTests.swift
//  TeamSpaceAppTests
//
//  Created by Rahul Pinjani on 8/4/25.
//  Copyright © Microsoft Corporation. All rights reserved.
//
//  Design Document: { Include link here }
//

import XCTest
@testable import Expressions

class MathFunctionsTests: XCTestCase {
    private var category: MathFunctions!
    
    override func setUp() {
        super.setUp()
        category = MathFunctions()
    }
    
    func testCategoryInfo() {
        XCTAssertEqual(category.categoryName, "Math")
        let expectedFunctions = Set(["round", "ceil", "floor"])
        let actualFunctions = Set(category.functions.keys)
        XCTAssertEqual(expectedFunctions, actualFunctions)
    }
    
    func testRoundFunction() async throws {
        guard let function = category.functions["round"] else {
            XCTFail("Round function not found")
            return
        }
        
        // Test positive number
        let result1 = try await function.callback([3.7])
        XCTAssertEqual(result1 as? Double, 4.0)
        
        // Test negative number
        let result2 = try await function.callback([-3.7])
        XCTAssertEqual(result2 as? Double, -4.0)
        
        // Test error cases
        do {
            _ = try await function.callback([])
            XCTFail("Expected error for missing parameters")
        } catch let error as FunctionError {
            guard case .invalidParameterCount(let expected, let actual) = error else {
                XCTFail("Expected invalidParameterCount error")
                return
            }
            XCTAssertEqual(expected, 1)
            XCTAssertEqual(actual, 0)
        }
        
        do {
            _ = try await function.callback(["not a number"])
            XCTFail("Expected error for invalid parameter type")
        } catch {
            XCTAssertTrue(error is FunctionError)
        }
    }
    
    func testCeilFunction() async throws {
        guard let function = category.functions["ceil"] else {
            XCTFail("ceil function not found")
            return
        }
        
        let result1 = try await function.callback([3.2])
        XCTAssertEqual(result1 as? Double, 4.0)
        
        let result2 = try await function.callback([-3.7])
        XCTAssertEqual(result2 as? Double, -3.0)
    }
    
    func testFloorFunction() async throws {
        guard let function = category.functions["floor"] else {
          XCTFail("floor function not found")
          return
        }
        
        let result1 = try await function.callback([3.9])
        XCTAssertEqual(result1 as? Double, 3.0)
        
        let result2 = try await function.callback([-3.2])
        XCTAssertEqual(result2 as? Double, -4.0)
    }
}
