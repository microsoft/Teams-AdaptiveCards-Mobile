//
//  ExpressionTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
@testable import AdaptiveCards
class ExpressionTests: XCTestCase {
    
    func testBasicArithmeticExpression() async throws {
        let expression = try Expression(expressionString: "1 + 2 * 3")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? Double, 7.0)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testStringConcatenation() async throws {
        let expression = try Expression(expressionString: "\"Hello\" + \" \" + \"World\"")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? String, "Hello World")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testBooleanLogic() async throws {
        let expression = try Expression(expressionString: "true && false || true")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? Bool, true)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testComparisonOperators() async throws {
        let expression1 = try Expression(expressionString: "5 > 3")
        let result1 = await expression1.evaluateResult()
        switch result1 {
        case .success(let value):
            XCTAssertEqual(value as? Bool, true)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }

        let expression2 = try Expression(expressionString: "5 <= 3")
        let result2 = await expression2.evaluateResult()
        switch result2 {
        case .success(let value):
            XCTAssertEqual(value as? Bool, false)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }

        let expression3 = try Expression(expressionString: "\"hello\" == \"hello\"")
        let result3 = await expression3.evaluateResult()
        switch result3 {
        case .success(let value):
            XCTAssertEqual(value as? Bool, true)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testDataContextAccess() async throws {
        let data: [String: Any] = ["name": "John", "age": 30, "active": true]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        let expression = try Expression(expressionString: "name")
        let result = await expression.evaluateResult(context: context)
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? String, "John")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testNestedDataAccess() async throws {
        let data = [
            "user": [
                "profile": [
                    "name": "Jane",
                    "email": "jane@example.com"
                ]
            ]
        ]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        let expression = try Expression(expressionString: "user.profile.name")
        let result = await expression.evaluateResult(context: context)
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? String, "Jane")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testArrayAccess() async throws {
        let data: [String: Any] = ["numbers": [1, 2, 3, 4, 5]]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        let expression = try Expression(expressionString: "numbers[2]")
        let result = await expression.evaluateResult(context: context)
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? Int, 3)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testVariableAssignment() async throws {
        let options = ExpressionOptions(allowAssignment: true)
        let expression = try Expression(expressionString: "x := 10 + 5", options: options)
        let context = await EvaluationContext()
        let result = await expression.evaluateResult(context: context)
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? Double, 15.0)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
    
    func testComplexExpression() async throws {
        let data = [
            "users": [
                ["name": "John", "age": 25, "active": true],
                ["name": "Jane", "age": 30, "active": false],
                ["name": "Bob", "age": 35, "active": true]
            ]
        ]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        let expression = try Expression(expressionString: "users[0].name + \" is \" + toString(users[0].age) + \" years old\"")
        let result = await expression.evaluateResult(context: context)
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? String, "John is 25 years old")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
    }
}
