//
//  CustomFunctionCategoryTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
import AdaptiveCards

class CustomFunctionCategoryTests: XCTestCase {
    
    func testCustomCategory() async throws {
        // Create a custom category for testing
        class TestFunctions: FunctionCategory {
            let categoryName = "Test"
            
            var functions: [String: FunctionDeclaration] {
                return [
                    "double": FunctionDeclaration(name: "double") { params in
                        try ParameterValidator.validateCount(params, expected: 1)
                        let value = try ParameterValidator.extractNumber(params[0], at: 0)
                        return value * 2
                    }
                ]
            }
        }
        
        let customCategory = TestFunctions()
        let registry = FunctionRegistry(categories: [customCategory])
        
        guard let doubleFunction = registry.getFunction(name: "double") else {
            XCTFail("Function 'double' not found in registry")
            return
        }
        let result = try await doubleFunction.callback([5.0])
        XCTAssertEqual(result as? Double, 10.0)
    }
}
