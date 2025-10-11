//
//  IntegrationTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
import AdaptiveCards

class IntegrationTests: XCTestCase {
    
    func testCompleteWorkflow() async throws {
        // Test the complete workflow from parsing to evaluation
        
        // 1. Setup complex data context
        let complexData = [
            "company": [
                "name": "TechCorp",
                "employees": [
                    [
                        "id": 1,
                        "name": "John Doe",
                        "department": "Engineering",
                        "salary": 75000.0,
                        "skills": ["Swift", "Python", "JavaScript"],
                        "performance": [
                            "rating": 4.5,
                            "goals_met": true,
                            "bonus_eligible": true
                        ]
                    ],
                    [
                        "id": 2,
                        "name": "Jane Smith",
                        "department": "Marketing",
                        "salary": 65000.0,
                        "skills": ["Marketing", "Analytics", "Design"],
                        "performance": [
                            "rating": 4.8,
                            "goals_met": true,
                            "bonus_eligible": true
                        ]
                    ]
                ],
                "policies": [
                    "bonus_rate": 0.15,
                    "min_rating_for_bonus": 4.0
                ]
            ]
        ]
        
        // 2. Create custom functions
        let calculateBonusFunction = FunctionDeclaration(
            name: "calculateBonus",
            cacheResultFor: 1000,
            callback: { params in
                guard params.count >= 3,
                      let salary = params[0] as? Double,
                      let rating = params[1] as? Double,
                      let bonusRate = params[2] as? Double else {
                    throw BuiltInFunctionError.invalidArguments("calculateBonus requires salary, rating, and bonus rate")
                }
                
                if rating >= 4.0 {
                    return salary * bonusRate
                } else {
                    return 0.0
                }
            }
        )
        
        let formatCurrencyFunction = FunctionDeclaration(
            name: "formatCurrency",
            callback: { params in
                guard !params.isEmpty,
                      let amount = params[0] as? Double else {
                    throw BuiltInFunctionError.invalidArguments("formatCurrency requires an amount")
                }
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.currencyCode = "USD"
                return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
            }
        )
        
        // 3. Create evaluation context with custom functions
        let config = EvaluationContextConfig(
            groupId: "payroll",
            root: complexData,
            functions: [calculateBonusFunction, formatCurrencyFunction]
        )
        let context = await EvaluationContext(config: config)
        
        // 4. Test complex expressions
        
        // Access nested array data
        let firstEmployeeName = try Expression(expressionString: "company.employees[0].name")
        let nameResult = await firstEmployeeName.evaluateResult(context: context)
        switch nameResult {
        case .success(let name):
            XCTAssertEqual(name as? String, "John Doe")
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
        
        // Test array membership
        let hasSwiftSkill = try Expression(expressionString: "\"Swift\" in company.employees[0].skills")
        let hasSkillResult = await hasSwiftSkill.evaluateResult(context: context)
        switch hasSkillResult {
        case .success(let hasSkill):
            XCTAssertEqual(hasSkill as? Bool, true)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
        
        // Complex conditional logic
        let bonusEligibility = try Expression(expressionString: "company.employees[0].performance.bonus_eligible && (company.employees[0].performance.rating >= company.policies.min_rating_for_bonus)")
        let isEligibleResult = await bonusEligibility.evaluateResult(context: context)
        switch isEligibleResult {
        case .success(let isEligible):
            XCTAssertEqual(isEligible as? Bool, true)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
        
        // Custom function usage
        let bonusCalculation = try Expression(expressionString: "calculateBonus(company.employees[0].salary, company.employees[0].performance.rating, company.policies.bonus_rate)")
        let bonusResult = await bonusCalculation.evaluateResult(context: context)
        switch bonusResult {
        case .success(let bonus):
            XCTAssertEqual(bonus as? Double, 11250.0) // 75000 * 0.15
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
        
        // String formatting with custom function
        let formattedBonus = try Expression(expressionString: "formatCurrency(calculateBonus(company.employees[0].salary, company.employees[0].performance.rating, company.policies.bonus_rate))")
        let formattedResult = await formattedBonus.evaluateResult(context: context)
        switch formattedResult {
        case .success(let formatted):
            XCTAssertTrue((formatted as? String)?.contains("$11,250") ?? false)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
        
        // 5. Test variable assignments
        let options = ExpressionOptions(allowAssignment: true)
        
        let totalSalaryCalculation = try Expression(expressionString: "totalSalary := company.employees[0].salary + company.employees[1].salary", options: options)
        _ = await totalSalaryCalculation.evaluateResult(context: context)
        
        let averageSalaryCalculation = try Expression(expressionString: "avgSalary := totalSalary / 2", options: options)
        _ = await averageSalaryCalculation.evaluateResult(context: context)
        
        let averageCheck = try Expression(expressionString: "avgSalary")
        let averageResult = await averageCheck.evaluateResult(context: context)
        switch averageResult {
        case .success(let average):
            XCTAssertEqual(average as? Double, 70000.0) // (75000 + 65000) / 2
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
        
        // 7. Test error handling
        let invalidExpression = try Expression(expressionString: "company.nonexistent.property")
        let invalidResult = await invalidExpression.evaluateResult(context: context)
        switch invalidResult {
        case .success:
            XCTFail("Expected evaluation to fail, but it succeeded")
        case .failure:
            // Expected failure
            break
        }
    }
    
    func testPerformanceAndCaching() async throws {
        // Test that function caching works correctly under load
        
        // Create an actor to safely manage the call count
        actor CallCounter {
            private var count = 0
            
            func increment() -> Int {
                count += 1
                return count
            }
            
            func getValue() -> Int {
                return count
            }
        }
        
        let callCounter = CallCounter()
        
        let expensiveFunction = FunctionDeclaration(
            name: "expensiveOperation",
            cacheResultFor: 2000, // 2 seconds
            callback: { _ in
                let currentCount = await callCounter.increment()
                // Simulate expensive operation
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms
                return "Result \(currentCount)"
            }
        )
        
        let config = EvaluationContextConfig(functions: [expensiveFunction])
        let context = await EvaluationContext(config: config)
        
        // Make multiple concurrent calls - should only execute once due to caching
        let expression = try Expression(expressionString: "expensiveOperation()")
        
        let startTime = Date()
        
        // Execute 5 concurrent calls
        async let result1 = expression.evaluateResult(context: context)
        async let result2 = expression.evaluateResult(context: context)
        async let result3 = expression.evaluateResult(context: context)
        async let result4 = expression.evaluateResult(context: context)
        async let result5 = expression.evaluateResult(context: context)
        let results = await [result1, result2, result3, result4, result5]
        let endTime = Date()
        
        // All results should be the same
        for result in results {
            switch result {
            case .success(let value):
                XCTAssertEqual(value as? String, "Result 1")
            case .failure(let error):
                XCTFail("Evaluation failed: \(error)")
            }
        }
        
        // Should have been called only once
        let finalCallCount = await callCounter.getValue()
        XCTAssertEqual(finalCallCount, 1)
        
        // Should complete much faster than 5 * 50ms due to caching
        let executionTime = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(executionTime, 0.2) // Should be well under 200ms
    }
    
    func testModularArchitecture() async throws {
        // Test that all modules work together correctly
        
        // Test that each module can be used independently
        
        // 1. Tokenizer
        let tokens = try Tokenizer.parse(expression: "user.name + \" is \" + toString(user.age)")
        XCTAssertGreaterThan(tokens.count, 5)
        
        // 2. Parser
    let parser = try ExpressionParser(expression: "1 + 2 * 3")
    let ast = try parser.parse()
    XCTAssertNotNil(ast)
        
        // 3. Built-in functions
        let builtInProvider = BuiltInFunctions()
        let roundFunction = builtInProvider.getFunction(name: "round")
        XCTAssertNotNil(roundFunction)
        
        // 4. Function cache
        let cache = FunctionCallCache()
        let testFunction = FunctionDeclaration(name: "test", callback: { _ in return "cached" })
        let cachedResult = await cache.callFunction(declaration: testFunction, params: [])
        XCTAssertEqual(cachedResult as? String, "cached")
        
        // 5. Expression evaluation
        let expression = try Expression(expressionString: "round(3.7)")
        let result = await expression.evaluateResult()
        switch result {
        case .success(let value):
            XCTAssertEqual(value as? Double, 4.0)
        case .failure(let error):
            XCTFail("Evaluation failed: \(error)")
        }
        
        // 6. Binding evaluation
        let binding = try Binding(expressionString: "${\"Hello World\"}")
        let bindingResult = try await binding.evaluate()
        XCTAssertEqual(bindingResult as? String, "Hello World")
     
    }
}
