//
//  ObjCExpressionEvaluatorTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
import AdaptiveCards

class ObjCExpressionEvaluatorTests: XCTestCase {
    func testBasicArithmeticExpressionObjCBridge() {
        let expectation = self.expectation(description: "ObjC bridge arithmetic")
        ObjCExpressionEvaluator.evaluateExpression("1 + 2 * 3", withData: nil) { result, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            XCTAssertEqual(result as? NSNumber, 7.0)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func testStringConcatenationObjCBridge() {
        let expectation = self.expectation(description: "ObjC bridge string concat")
        ObjCExpressionEvaluator.evaluateExpression("\"Hello\" + \" \" + \"World\"", withData: nil) { result, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            XCTAssertEqual(result as? NSString, "Hello World")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func testDataContextObjCBridge() {
        let expectation = self.expectation(description: "ObjC bridge data context")
        let data: NSDictionary = ["name": "Rahul", "age": 42]
        ObjCExpressionEvaluator.evaluateExpression("name + \" is \" + toString(age)", withData: data) { result, error in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            XCTAssertEqual(result as? NSString, "Rahul is 42")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    func testErrorHandlingObjCBridge() {
        let expectation = self.expectation(description: "ObjC bridge error handling")
        ObjCExpressionEvaluator.evaluateExpression("1 + ", withData: nil) { result, error in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            XCTAssertTrue(error!.localizedDescription.count > 0)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
}
