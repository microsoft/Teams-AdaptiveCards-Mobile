//
//  StringFunctionTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
import AdaptiveCards

class StringFunctionsTests: XCTestCase {
    private var category: StringFunctions!
    
    override func setUp() {
        super.setUp()
        category = StringFunctions()
    }
    
    func testCategoryInfo() {
        XCTAssertEqual(category.categoryName, "String")
        let expectedFunctions = Set(["toUpper", "toLower", "substr"])
        let actualFunctions = Set(category.functions.keys)
        XCTAssertEqual(expectedFunctions, actualFunctions)
    }
    
    func testToUpperFunction() async throws {
        guard let function = category.functions["toUpper"] else {
            XCTFail("toUpper function not found")
            return
        }
        
        let result = try await function.callback(["hello world"])
        XCTAssertEqual(result as? String, "HELLO WORLD")
        
        do {
            _ = try await function.callback([123])
            XCTFail("Expected error for invalid parameter type")
        } catch {
            XCTAssertTrue(error is FunctionError)
        }
    }
    
    func testToLowerFunction() async throws {
        guard let function = category.functions["toLower"] else {
            XCTFail("toLower function not found")
            return
        }
        
        let result = try await function.callback(["HELLO WORLD"])
        XCTAssertEqual(result as? String, "hello world")
    }
    
    func testSubstrFunction() async throws {
        guard let function = category.functions["substr"] else {
            XCTFail("toLower function not found")
            return
        }
        
        // Test with start and end
        let result1 = try await function.callback(["hello", 1, 4])
        XCTAssertEqual(result1 as? String, "ell")
        
        // Test with only start
        let result2 = try await function.callback(["hello", 2])
        XCTAssertEqual(result2 as? String, "llo")
        
        // Test error cases
        do {
            _ = try await function.callback(["hello", 10])
            XCTFail("Expected error for out of bounds index")
        } catch {
            XCTAssertTrue(error is FunctionError)
        }
        
        do {
            _ = try await function.callback(["hello", 3, 1])
            XCTFail("Expected error for invalid range")
        } catch {
            XCTAssertTrue(error is FunctionError)
        }
    }
}
