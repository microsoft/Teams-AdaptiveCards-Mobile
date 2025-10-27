//
//  BindingTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
import AdaptiveCards

class BindingTests: XCTestCase {
    
    func testBasicBinding() async throws {
        let data: [String: Any] = ["name": "John", "age": 30]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        
        let binding = try Binding(expressionString: "${name}")
        let result = try await binding.evaluate(context: context)
        
        XCTAssertEqual(result as? String, "John")
    }
    
    func testBindingWithExpression() async throws {
        let data = ["firstName": "John", "lastName": "Doe"]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        
        let binding = try Binding(expressionString: "${firstName + \" \" + lastName}")
        let result = try await binding.evaluate(context: context)
        
        XCTAssertEqual(result as? String, "John Doe")
    }
    
    func testBindingWithNullHandling() async throws {
        let binding = try Binding(expressionString: "${?#nonExistentProperty}")
        let result = try await binding.evaluate()
        
        // Should not throw error when allowNull is true (default with ?# prefix)
        XCTAssertNil(result)
    }
    
    func testBindingNullErrorWhenNotAllowed() async throws {
        let binding = try Binding(expressionString: "${nonExistentProperty}")

        do {
            _ = try await binding.evaluate()
            XCTFail("Expected binding to throw an error for a non-existent property")
        } catch let error as EvaluationError {
            // The correct error to expect is undefinedVariable, which is now correctly thrown.
            switch error {
            case .undefinedVariable(let message):
                XCTAssertEqual(message, "Variable 'nonExistentProperty' is not defined")
            default:
                XCTFail("Expected EvaluationError.undefinedVariable, but got \(error)")
            }
        } catch {
            XCTFail("An unexpected error type was thrown: \(error)")
        }
    }

    func testComplexBinding() async throws {
        let data = [
            "user": [
                "profile": [
                    "name": "Jane",
                    "age": 25
                ],
                "settings": [
                    "theme": "dark",
                    "notifications": true
                ]
            ]
        ]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        
        let binding = try Binding(expressionString: "${user.profile.name + \" (\" + toString(user.profile.age) + \")\"}")
        let result = try await binding.evaluate(context: context)
        
        XCTAssertEqual(result as? String, "Jane (25)")
    }
    
    func testBindingWithFunctions() async throws {
        let data = ["message": "hello world"]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        
        let binding = try Binding(expressionString: "${toUpper(message)}")
        let result = try await binding.evaluate(context: context)
        
        XCTAssertEqual(result as? String, "HELLO WORLD")
    }
    
    func testBindingWithArrayAccess() async throws {
        let data = ["colors": ["red", "green", "blue"]]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        
        let binding = try Binding(expressionString: "${colors[1]}")
        let result = try await binding.evaluate(context: context)
        
        XCTAssertEqual(result as? String, "green")
    }
    
    func testBindingWithConditionalLogic() async throws {
        let data = ["score": 85, "passing": 70]
        let context = await EvaluationContext(config: EvaluationContextConfig(root: data))
        
        let binding = try Binding(expressionString: "${if(score >= passing, \"Pass\", \"Fail\")}")
        let result = try await binding.evaluate(context: context)
        
        XCTAssertEqual(result as? String, "Pass")
    }
}
