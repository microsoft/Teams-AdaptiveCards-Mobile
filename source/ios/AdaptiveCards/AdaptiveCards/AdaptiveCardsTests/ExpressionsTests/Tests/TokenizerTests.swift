//
//  TokenizerTests.swift
//  TeamSpaceAppTests
//
//  Created by Rahul Pinjani on 8/4/25.
//  Copyright © Microsoft Corporation. All rights reserved.
//
//  Design Document: { Include link here }
//

import XCTest
@testable import Expressions

class TokenizerTests: XCTestCase {
    
    func testBasicTokenization() throws {
        let expression = "1 + 2"
        let tokens = try Tokenizer.parse(expression: expression)
        
        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(tokens[0].type, "number")
        XCTAssertEqual(tokens[0].value, "1")
        XCTAssertEqual(tokens[1].type, "+")
        XCTAssertEqual(tokens[1].value, "+")
        XCTAssertEqual(tokens[2].type, "number")
        XCTAssertEqual(tokens[2].value, "2")
    }
    
    func testStringLiteralTokenization() throws {
        let expression = "\"hello world\""
        let tokens = try Tokenizer.parse(expression: expression)
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].type, "string")
        XCTAssertEqual(tokens[0].value, "hello world")
    }
    
    func testComplexExpressionTokenization() throws {
        let expression = "user.name == \"John\" && user.age > 25"
        let tokens = try Tokenizer.parse(expression: expression)
        
        XCTAssertEqual(tokens.count, 11)
        XCTAssertEqual(tokens[0].type, "identifier")
        XCTAssertEqual(tokens[0].value, "user")
        XCTAssertEqual(tokens[1].type, ".")
        XCTAssertEqual(tokens[2].type, "identifier")
        XCTAssertEqual(tokens[2].value, "name")
        XCTAssertEqual(tokens[3].type, "==")
        XCTAssertEqual(tokens[4].type, "string")
        XCTAssertEqual(tokens[4].value, "John")
    }
    
    func testBindingTokenization() throws {
        let expression = "${user.name}"
        let tokens = try Tokenizer.parse(expression: expression)
        
        XCTAssertEqual(tokens.count, 5)
        XCTAssertEqual(tokens[0].type, "${")
        XCTAssertEqual(tokens[1].type, "identifier")
        XCTAssertEqual(tokens[1].value, "user")
        XCTAssertEqual(tokens[2].type, ".")
        XCTAssertEqual(tokens[3].type, "identifier")
        XCTAssertEqual(tokens[3].value, "name")
        XCTAssertEqual(tokens[4].type, "}")
        
    }
    
    func testUnexpectedCharacterError() {
        let expression = "1 + @"
        
        XCTAssertThrowsError(try Tokenizer.parse(expression: expression)) { error in
            if let tokenizerError = error as? TokenizerError {
                switch tokenizerError {
                case .unexpectedCharacter(let message):
                    XCTAssertTrue(message.contains("@"))
                default:
                    XCTFail("Expected unexpectedCharacter error")
                }
            } else {
                XCTFail("Expected TokenizerError")
            }
        }
    }
}
