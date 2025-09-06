//
//  BuiltInFunctionIntegrationTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
import AdaptiveCards

class BuiltInFunctionIntegrationTests: XCTestCase {
    
    // MARK: - Math Function Integration Tests
    
    func testRoundFunctionIntegration() async throws {
        let expression = try Expression(expressionString: "round(3.7)")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? Double, 4.0)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testCeilFunctionIntegration() async throws {
        let expression = try Expression(expressionString: "ceil(3.2)")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? Double, 4.0)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testFloorFunctionIntegration() async throws {
        let expression = try Expression(expressionString: "floor(3.9)")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? Double, 3.0)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    // MARK: - String Function Integration Tests
    
    func testToUpperFunctionIntegration() async throws {
        let expression = try Expression(expressionString: "toUpper(\"hello\")")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? String, "HELLO")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testToLowerFunctionIntegration() async throws {
        let expression = try Expression(expressionString: "toLower(\"WORLD\")")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? String, "world")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testSubstrFunctionIntegration() async throws {
        let expression1 = try Expression(expressionString: "substr(\"Hello World\", 0, 5)")
        let result1 = await expression1.evaluateResult()
        switch result1 {
        case .success(let value):
            XCTAssertEqual(value as? String, "Hello")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }

        let expression2 = try Expression(expressionString: "substr(\"Hello World\", 6)")
        let result2 = await expression2.evaluateResult()
        switch result2 {
        case .success(let value):
            XCTAssertEqual(value as? String, "World")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testLengthFunctionIntegration() async throws {
        let expression1 = try Expression(expressionString: "length(\"hello\")")
        let result1 = await expression1.evaluateResult()
        switch result1 {
        case .success(let value):
            XCTAssertEqual(value as? Int, 5)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }

        let data = ["items": [1, 2, 3, 4]]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        let expression2 = try Expression(expressionString: "length(items)")
        let result2 = await expression2.evaluateResult(context: context)
        switch result2 {
        case .success(let value):
            XCTAssertEqual(value as? Int, 4)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    // MARK: - Conversion Function Integration Tests
    
    func testParseFloatFunctionIntegration() async throws {
        let expression1 = try Expression(expressionString: "parseFloat(\"3.14\")")
        let result1 = await expression1.evaluateResult()
        switch result1 {
        case .success(let value):
            XCTAssertEqual(value as? Double, 3.14)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }

        let expression2 = try Expression(expressionString: "parseFloat(42)")
        let result2 = await expression2.evaluateResult()
        switch result2 {
        case .success(let value):
            XCTAssertEqual(value as? Double, 42.0)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testParseIntFunctionIntegration() async throws {
        let expression1 = try Expression(expressionString: "parseInt(\"42\")")
        let result1 = await expression1.evaluateResult()
        switch result1 {
        case .success(let value):
            XCTAssertEqual(value as? Int64, 42)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }

        let expression2 = try Expression(expressionString: "parseInt(\"FF\", 16)")
        let result2 = await expression2.evaluateResult()
        switch result2 {
        case .success(let value):
            XCTAssertEqual(value as? Int64, 255)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
}
