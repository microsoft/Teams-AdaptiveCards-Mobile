//
//  AllExpressionsTests.swift
//  TeamSpaceApp
//
//  Created by Rahul Pinjani on 8/28/25.
//  Copyright © Microsoft Corporation. All rights reserved.
//
//  Design Document: { Include link here }
//
import XCTest
@testable import Expressions

class AllExpressionsTests: XCTestCase {
    
    // MARK: - Test Data Structure
    
    struct ExpressionTestCase {
        let expression: String
        let expectedResult: Any?
        let contextRoot: [String: Any?]?
        let customFunctions: [FunctionDeclaration]
        let parseShouldThrow: Bool
        let evaluateShouldThrow: Bool
        
        init(expression: String,
             expectedResult: Any? = nil,
             contextRoot: [String: Any?]? = nil,
             customFunctions: [FunctionDeclaration] = [],
             parseShouldThrow: Bool = false,
             evaluateShouldThrow: Bool = false) {
            self.expression = expression
            self.expectedResult = expectedResult
            self.contextRoot = contextRoot
            self.customFunctions = customFunctions
            self.parseShouldThrow = parseShouldThrow
            self.evaluateShouldThrow = evaluateShouldThrow
        }
    }
    
    // MARK: - Test Context
    
    private var context: EvaluationContext!
    
    override func setUp() async throws {
        try await super.setUp()
        context =  await EvaluationContext()
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }
    
    // MARK: - Helper Functions
    
    private func formatDateForTest(_ isoString: String, style: DateFormatter.Style) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else {
            return "Invalid Date"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = style
        return displayFormatter.string(from: date)
    }
    
    private func formatTimeForTest(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else {
            return "Invalid Time"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
    
    // MARK: - Test Cases Provider
    
    private func getExpressionTestCases() -> [ExpressionTestCase] {
        return [
            // Basic Arithmetic
            ExpressionTestCase(expression: "1 + 2", expectedResult: 3.0),
            ExpressionTestCase(expression: "1 - 2", expectedResult: -1.0),
            ExpressionTestCase(expression: "(1 + 2) * 3", expectedResult: 9.0),
            ExpressionTestCase(expression: "8 / 2 * (2 + 2)", expectedResult: 16.0),
            
            // Context Root Variable Access
            ExpressionTestCase(
                expression: "8 / divider * (2 + 2) - subtract",
                expectedResult: 14.0,
                contextRoot: ["divider": 2.0, "subtract": 2.0]
            ),
            
            // String Operations
            ExpressionTestCase(expression: "\"abc\" + \"def\"", expectedResult: "abcdef"),
            ExpressionTestCase(expression: "'Calling substr: ' + substr(\"Hello world\", 2, 4)", expectedResult: "Calling substr: ll"),
            
            // Built-in Function Calls
            ExpressionTestCase(
                expression: "2 * parseFloat(myNumber) + 6",
                expectedResult: 15.0,
                contextRoot: ["myNumber": "4.5"]
            ),
            ExpressionTestCase(
                expression: "if(n1 == n2, \"true\", \"false\")",
                expectedResult: "true",
                contextRoot: ["n1": 3.0, "n2": 3.0]
            ),
            ExpressionTestCase(expression: "toUpper(\"abc\") + toLower(\"DEF\")", expectedResult: "ABCdef"),
            
            // Math Functions
            ExpressionTestCase(expression: "round(3.54)", expectedResult: 4.0),
            ExpressionTestCase(expression: "ceil(3.14)", expectedResult: 4.0),
            ExpressionTestCase(expression: "floor(3.14)", expectedResult: 3.0),
            
            // Length function
            ExpressionTestCase(
                expression: "length(list)",
                expectedResult: 3,
                contextRoot: ["list": [2, 3, 4]]
            ),
            ExpressionTestCase(expression: "length('This is a string')", expectedResult: 16),
          //  ExpressionTestCase(expression: "length(32)", evaluateShouldThrow: true),
            
            // Date/Time Functions
            ExpressionTestCase(
                expression: "Date.format(\"2024-01-10T08:00:00Z\", \"long\")",
                expectedResult: formatDateForTest("2024-01-10T08:00:00Z", style: .long)
            ),
            ExpressionTestCase(
                expression: "Date.format(\"2024-01-10T08:00:00Z\", \"short\")",
                expectedResult: formatDateForTest("2024-01-10T08:00:00Z", style: .short)
            ),
            ExpressionTestCase(
                expression: "Date.format(\"2024-01-10T08:00:00Z\", \"compact\")",
                expectedResult: formatDateForTest("2024-01-10T08:00:00Z", style: .medium)
            ),
            ExpressionTestCase(
                expression: "Date.format(1704873600000, \"compact\")",
                expectedResult: formatDateForTest("2024-01-10T08:00:00Z", style: .medium)
            ),
            ExpressionTestCase(
                expression: "Time.format(\"2024-01-10T07:29:00Z\")",
                expectedResult: formatTimeForTest("2024-01-10T07:29:00Z")
            ),
            
            // Array/List Handling
            ExpressionTestCase(expression: "[1,2,3]", expectedResult: [1.0, 2.0, 3.0]),
            ExpressionTestCase(expression: "[1,2,3] + [4,5,6]", expectedResult: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]),
            ExpressionTestCase(expression: "[1,2,3] + 4", expectedResult: [1.0, 2.0, 3.0, 4.0]),
            ExpressionTestCase(expression: "'hello' + [1,2,3]", expectedResult: ["hello", 1.0, 2.0, 3.0]),
            
            // 'in' operator
            ExpressionTestCase(expression: "'hello' in [1,2,3]", expectedResult: false),
            ExpressionTestCase(expression: "'hello' in [1,2,'hello',3]", expectedResult: true),
            
            // Custom and Async Functions
            ExpressionTestCase(
                expression: "'Calling custom function: ' + myCustomFunction('David')",
                expectedResult: "Calling custom function: Hello David",
                customFunctions: [
                    FunctionDeclaration(name: "myCustomFunction") { params in
                        return "Hello \(params[0] ?? "")"
                    }
                ]
            ),
            ExpressionTestCase(
                expression: "asyncFunction1('Hello') + ' ' + asyncFunction2('David')",
                expectedResult: "Hello David",
                customFunctions: [
                    FunctionDeclaration(name: "asyncFunction1") { params in
                        try await Task.sleep(nanoseconds: 10_000_000) // 10ms
                        return params[0]
                    },
                    FunctionDeclaration(name: "asyncFunction2") { params in
                        try await Task.sleep(nanoseconds: 20_000_000) // 20ms
                        return params[0]
                    }
                ]
            ),
            ExpressionTestCase(
                expression: "asyncFunction1(asyncFunction2('Worked'))",
                expectedResult: "Worked",
                customFunctions: [
                    FunctionDeclaration(name: "asyncFunction1") { params in
                        try await Task.sleep(nanoseconds: 10_000_000)
                        return params[0]
                    },
                    FunctionDeclaration(name: "asyncFunction2") { params in
                        try await Task.sleep(nanoseconds: 20_000_000)
                        return params[0]
                    }
                ]
            ),
            ExpressionTestCase(
                expression: "[asyncFunction('result1'), 1, 2]",
                expectedResult: ["result1", 1.0, 2.0],
                customFunctions: [
                    FunctionDeclaration(name: "asyncFunction") { params in
                        try await Task.sleep(nanoseconds: 10_000_000)
                        return params[0]
                    }
                ]
            ),
            ExpressionTestCase(
                expression: "noParamFunction()",
                expectedResult: "Hello world",
                customFunctions: [
                    FunctionDeclaration(name: "noParamFunction") { _ in
                        return "Hello world"
                    }
                ]
            ),
            
            // Boolean Operations
            ExpressionTestCase(expression: "true && false", expectedResult: false),
            ExpressionTestCase(expression: "true || false", expectedResult: true),
            ExpressionTestCase(expression: "true && false || true", expectedResult: true),
            ExpressionTestCase(expression: "true && (false || true)", expectedResult: true),
            ExpressionTestCase(expression: "3 && false", expectedResult: false),
            ExpressionTestCase(expression: "3 || false", expectedResult: false),
            ExpressionTestCase(expression: "3 && 4", expectedResult: false),
            ExpressionTestCase(expression: "3 || 4", expectedResult: false)
        ]
    }
    
    // MARK: - Individual Tests
     
    func testBinding_parsesAndEvaluatesCorrectly() async {
        do {
            let binding = try Binding(expressionString: "${1 + 2}")
            let result = try await binding.evaluate()
            XCTAssertEqual(result as? Double, 3.0)
        } catch {
            XCTFail("Binding evaluation should succeed: \(error)")
        }
    }
    
    // MARK: - Variable Assignment Tests
    
    func testVariableAssignment_shouldAssignSimpleValue() async {
        do {
            let expression = try Expression(
                expressionString: "myVar := 42",
                options: ExpressionOptions(allowAssignment: true)
            )
            let result = await expression.evaluateResult(context: context)
            switch result {
            case .success(let value):
                XCTAssertEqual(value as? Double, 42.0)
            case .failure(let error):
                XCTFail("Variable assignment should succeed: \(error)")
            }
        } catch {
            XCTFail("Variable assignment should succeed: \(error)")
        }
    }
    
    func testVariableAssignment_shouldHandleMultipleAssignmentsInSequence() async {
        do {
            let expr1 = try Expression(
                expressionString: "first := 10",
                options: ExpressionOptions(allowAssignment: true)
            )
            let expr2 = try Expression(
                expressionString: "second := 20",
                options: ExpressionOptions(allowAssignment: true)
            )
            let expr3 = try Expression(
                expressionString: "sum := first + second",
                options: ExpressionOptions(allowAssignment: true)
            )
            
            let result1 = await expr1.evaluateResult(context: context)
            switch result1 {
            case .success:
                break
            case .failure(let error):
                XCTFail("First assignment should succeed: \(error)")
                return
            }
            
            let result2 = await expr2.evaluateResult(context: context)
            switch result2 {
            case .success:
                break
            case .failure(let error):
                XCTFail("Second assignment should succeed: \(error)")
                return
            }
            
            let result3 = await expr3.evaluateResult(context: context)
            switch result3 {
            case .success(let value):
                XCTAssertEqual(value as? Double, 30.0)
            case .failure(let error):
                XCTFail("Third assignment should succeed: \(error)")
            }

        } catch {
            XCTFail("Variable assignment should succeed: \(error)")
        }
    }
    
   // MARK: - Function Call Cache Tests
    func testFunctionCallCache_shouldCacheResults() async {
        do {
            let mockFunction = FunctionDeclaration(
                name: "testFunc",
                cacheResultFor: 1000
            ) { _ in
                return "result-hello"
            }
            
            let cacheContext = await EvaluationContext(
                config: EvaluationContextConfig(functions: [mockFunction])
            )
            let expression = try Expression(expressionString: "testFunc('hello')")
            
            let result1 = await expression.evaluateResult(context: cacheContext)
            switch result1 {
            case .success(let value):
                XCTAssertEqual(value as? String, "result-hello")
            case .failure(let error):
                XCTFail("First evaluation should succeed: \(error)")
            }
            
            let result2 = await expression.evaluateResult(context: cacheContext)
            switch result2 {
            case .success(let value):
                XCTAssertEqual(value as? String, "result-hello")
            case .failure(let error):
                XCTFail("Second evaluation should succeed: \(error)")
            }
        } catch {
            XCTFail("Function cache test should succeed: \(error)")
        }
    }
    
    // MARK: - Comprehensive Test Runner
    
    func testAllExpressionTestCases() async {
        let allTestCases = getExpressionTestCases()
        var failures: [String] = []
        
        print("--- Running \(allTestCases.count) Expression Test Cases ---")
        
        for testCase in allTestCases {
            print("Testing: \(testCase.expression)")
            
            var evaluateError: Error?
            var actualResult: Any?
            
            // Phase 1: Test Parsing
            do {
                let options = ExpressionOptions(allowAssignment: testCase.expression.contains(":="))
                let expression = try Expression(expressionString: testCase.expression, options: options)
                
                // Assert Parsing Outcome
                if testCase.parseShouldThrow {
                    failures.append("FAIL [Parse]: '\(testCase.expression)' -- Expected to throw an error during parsing, but it succeeded.")
                    continue
                }
                
                    let contextConfig = EvaluationContextConfig(
                        root: testCase.contextRoot,
                        functions: testCase.customFunctions
                    )
                    let context = await EvaluationContext(config: contextConfig)
                    let result = await expression.evaluateResult(context: context)
                    switch result {
                    case .success(let value):
                        actualResult = value
                    case .failure(let error):
                        evaluateError = error
                    }
                
            } catch {
                
                // Assert Parsing Outcome
                if testCase.parseShouldThrow {
                    // Expected to fail, continue to next test
                    continue
                } else {
                    failures.append("FAIL [Parse]: '\(testCase.expression)' -- Expected to parse successfully, but it failed with: \(error.localizedDescription)")
                    continue
                }
            }
            
            // Assert Evaluation Outcome
            if testCase.evaluateShouldThrow {
                if evaluateError == nil {
                    failures.append("FAIL [Evaluate]: '\(testCase.expression)' -- Expected to throw an error during evaluation, but it succeeded.")
                }
            } else {
                if evaluateError != nil {
                    failures.append("FAIL [Evaluate]: '\(testCase.expression)' -- Expected to evaluate successfully, but it failed with: \(evaluateError?.localizedDescription ?? "Unknown error")")
                } else {
                    // Compare the results
                    let expected = testCase.expectedResult
                    let resultsMatch = compareResults(expected: expected, actual: actualResult)
                    
                    if !resultsMatch {
                        failures.append("FAIL [Result]: '\(testCase.expression)' -- Expected <\(String(describing: expected))> but got <\(String(describing: actualResult))>")
                    }
                }
            }
        }
        
        // Final Assertion
        if !failures.isEmpty {
            XCTFail("One or more expression test cases failed:\n" + failures.joined(separator: "\n"))
        } else {
            print("\n--- SUCCESS: All \(allTestCases.count) test cases passed! ---")
        }
    }
    
    // MARK: - Helper Methods
    
    func compareResults(expected: Any?, actual: Any?) -> Bool {
        // Handle nil cases
        if expected == nil && actual == nil { return true }
        if expected == nil || actual == nil { return false }
        
        // Handle array comparison
        if let expectedArray = expected as? [Any], let actualArray = actual as? [Any] {
            guard expectedArray.count == actualArray.count else { return false }
            for (index, expectedElement) in expectedArray.enumerated() where !compareResults(expected: expectedElement, actual: actualArray[index]) {
               return false
            }
            return true
        }
        
        // Handle numeric comparison with tolerance
        if let expectedDouble = expected as? Double, let actualDouble = actual as? Double {
            return abs(expectedDouble - actualDouble) < 0.000001
        }
        
        if let expectedInt = expected as? Int, let actualDouble = actual as? Double {
            return abs(Double(expectedInt) - actualDouble) < 0.000001
        }
        
        if let expectedDouble = expected as? Double, let actualInt = actual as? Int {
            return abs(expectedDouble - Double(actualInt)) < 0.000001
        }
        
        // Handle string comparison
        if let expectedString = expected as? String, let actualString = actual as? String {
            return expectedString == actualString
        }
        
        // Handle boolean comparison
        if let expectedBool = expected as? Bool, let actualBool = actual as? Bool {
            return expectedBool == actualBool
        }
        
        // Fallback comparison using description
        return String(describing: expected) == String(describing: actual)
    }
}
