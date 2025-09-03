//
//  ErrorHandlingTests.swift
//  TeamSpaceAppTests
//
//  Created by Rahul Pinjani on 8/4/25.
//  Copyright © Microsoft Corporation. All rights reserved.
//
//  Design Document: { Include link here }
//

import XCTest
@testable import Expressions

class ErrorHandlingTests: XCTestCase {
    
    func testFunctionErrorDescriptions() {
        let error1 = FunctionError.invalidParameterCount(expected: 2, actual: 1)
        XCTAssertEqual(error1.description, "Expected 2 parameters, got 1")
        
        let error2 = FunctionError.invalidParameterType(parameter: 0, expected: "String", actual: "Number")
        XCTAssertEqual(error2.description, "Parameter 0: expected String, got Number")
        
        let error3 = FunctionError.executionError("Test error")
        XCTAssertEqual(error3.description, "Execution error: Test error")
    }
}
