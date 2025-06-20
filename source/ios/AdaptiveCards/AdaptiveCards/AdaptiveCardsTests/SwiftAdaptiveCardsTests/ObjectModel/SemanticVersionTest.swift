//
//  SemanticVersionTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
import AdaptiveCards

class SemanticVersionTests: XCTestCase {
    
    // MARK: - Positive Tests
    
    func testPositiveVersions() {
        do {
            let version = try SwiftSemanticVersion("1")
            XCTAssertEqual(version.major, 1)
            XCTAssertEqual(version.minor, 0)
            XCTAssertEqual(version.build, 0)
            XCTAssertEqual(version.revision, 0)
        } catch {
            XCTFail("Unexpected error for input \"1\": \(error)")
        }
        
        do {
            let version = try SwiftSemanticVersion("10.2")
            XCTAssertEqual(version.major, 10)
            XCTAssertEqual(version.minor, 2)
            XCTAssertEqual(version.build, 0)
            XCTAssertEqual(version.revision, 0)
        } catch {
            XCTFail("Unexpected error for input \"10.2\": \(error)")
        }
        
        do {
            let version = try SwiftSemanticVersion("100.20.3")
            XCTAssertEqual(version.major, 100)
            XCTAssertEqual(version.minor, 20)
            XCTAssertEqual(version.build, 3)
            XCTAssertEqual(version.revision, 0)
        } catch {
            XCTFail("Unexpected error for input \"100.20.3\": \(error)")
        }
        
        do {
            let version = try SwiftSemanticVersion("1000.200.30.4")
            XCTAssertEqual(version.major, 1000)
            XCTAssertEqual(version.minor, 200)
            XCTAssertEqual(version.build, 30)
            XCTAssertEqual(version.revision, 4)
        } catch {
            XCTFail("Unexpected error for input \"1000.200.30.4\": \(error)")
        }
        
        do {
            let version = try SwiftSemanticVersion("1000.200.30.40")
            XCTAssertEqual(version.major, 1000)
            XCTAssertEqual(version.minor, 200)
            XCTAssertEqual(version.build, 30)
            XCTAssertEqual(version.revision, 40)
        } catch {
            XCTFail("Unexpected error for input \"1000.200.30.40\": \(error)")
        }
    }
    
    // MARK: - Negative Tests
    
    func testNegativeVersions() {
        XCTAssertThrowsError(try SwiftSemanticVersion(""), "Empty version string should throw") { error in
            // Optionally: XCTAssertEqual(error as? AdaptiveCardParseException, expectedError)
        }
        XCTAssertThrowsError(try SwiftSemanticVersion("text"), "Non-numeric version should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("1234567890123456789012345678901234567890"), "Overly long version string should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("1."), "Trailing dot should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("1.2."), "Trailing dot should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("1.2.3."), "Trailing dot should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("1.2.3.4."), "Trailing dot should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion(" 1.0"), "Leading whitespace should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("1.0 "), "Trailing whitespace should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("-1"), "Negative numbers should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("0xF"), "Hex notation should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("F"), "Non-numeric value should throw")
        XCTAssertThrowsError(try SwiftSemanticVersion("1.c"), "Mixed numeric and non-numeric should throw")
    }
    
    // MARK: - Comparison Tests
    
    func testVersionComparison() {
        do {
            let lhs = try SwiftSemanticVersion("1")
            let rhs = try SwiftSemanticVersion("1.000000.0000000.0000000")
            XCTAssertEqual(lhs, rhs)
            XCTAssertFalse(lhs != rhs)
            XCTAssertFalse(lhs < rhs)
            XCTAssertFalse(lhs > rhs)
            XCTAssertTrue(lhs >= rhs)
            XCTAssertTrue(lhs <= rhs)
        } catch {
            XCTFail("Unexpected error in comparison test 1: \(error)")
        }
        
        do {
            let lhs = try SwiftSemanticVersion("1.1")
            let rhs = try SwiftSemanticVersion("1.001")
            XCTAssertEqual(lhs, rhs)
            XCTAssertFalse(lhs != rhs)
            XCTAssertFalse(lhs < rhs)
            XCTAssertFalse(lhs > rhs)
            XCTAssertTrue(lhs >= rhs)
            XCTAssertTrue(lhs <= rhs)
        } catch {
            XCTFail("Unexpected error in comparison test 2: \(error)")
        }
        
        do {
            let lhs = try SwiftSemanticVersion("1.0")
            let rhs = try SwiftSemanticVersion("1.1")
            XCTAssertNotEqual(lhs, rhs)
            XCTAssertTrue(lhs != rhs)
            XCTAssertTrue(lhs < rhs)
            XCTAssertFalse(lhs > rhs)
            XCTAssertFalse(lhs >= rhs)
            XCTAssertTrue(lhs <= rhs)
        } catch {
            XCTFail("Unexpected error in comparison test 3: \(error)")
        }
        
        do {
            let lhs = try SwiftSemanticVersion("1.0")
            let rhs = try SwiftSemanticVersion("1.0.1")
            XCTAssertNotEqual(lhs, rhs)
            XCTAssertTrue(lhs != rhs)
            XCTAssertTrue(lhs < rhs)
            XCTAssertFalse(lhs > rhs)
            XCTAssertFalse(lhs >= rhs)
            XCTAssertTrue(lhs <= rhs)
        } catch {
            XCTFail("Unexpected error in comparison test 4: \(error)")
        }
        
        do {
            let lhs = try SwiftSemanticVersion("1.1.2")
            let rhs = try SwiftSemanticVersion("1.1.3")
            XCTAssertNotEqual(lhs, rhs)
            XCTAssertTrue(lhs != rhs)
            XCTAssertTrue(lhs < rhs)
            XCTAssertFalse(lhs > rhs)
            XCTAssertFalse(lhs >= rhs)
            XCTAssertTrue(lhs <= rhs)
        } catch {
            XCTFail("Unexpected error in comparison test 5: \(error)")
        }
        
        do {
            let lhs = try SwiftSemanticVersion("1.1.3.100")
            let rhs = try SwiftSemanticVersion("1.1.4.1")
            XCTAssertNotEqual(lhs, rhs)
            XCTAssertTrue(lhs != rhs)
            XCTAssertTrue(lhs < rhs)
            XCTAssertFalse(lhs > rhs)
            XCTAssertFalse(lhs >= rhs)
            XCTAssertTrue(lhs <= rhs)
        } catch {
            XCTFail("Unexpected error in comparison test 6: \(error)")
        }
        
        do {
            let lhs = try SwiftSemanticVersion("1.3.1")
            let rhs = try SwiftSemanticVersion("1.10.2")
            XCTAssertNotEqual(lhs, rhs)
            XCTAssertTrue(lhs != rhs)
            XCTAssertTrue(lhs < rhs)
            XCTAssertFalse(lhs > rhs)
            XCTAssertFalse(lhs >= rhs)
            XCTAssertTrue(lhs <= rhs)
        } catch {
            XCTFail("Unexpected error in comparison test 7: \(error)")
        }
    }
}
