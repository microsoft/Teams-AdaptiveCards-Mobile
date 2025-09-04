//
//  DateFunctionsTests.swift
//  AdaptiveCards
//
//  Created by Rahul Pinjani on 8/12/25.
//

import XCTest
@testable import AdaptiveCards

class DateFunctionsTests: XCTestCase {
    private var category: DateFunctions!
    
    override func setUp() {
        super.setUp()
        category = DateFunctions()
    }
    
    func testCategoryInfo() {
        XCTAssertEqual(category.categoryName, "Date")
        let expectedFunctions = Set(["Date.format", "Time.format"])
        let actualFunctions = Set(category.functions.keys)
        XCTAssertEqual(expectedFunctions, actualFunctions)
    }
    
    func testDateFormatFunction() async throws {
        guard let function = category.functions["Date.format"] else {
            XCTFail("Date.format function not found")
            return
        }
        
        // Test with timestamp
        let timestamp: Int64 = 1640995200000 // 2022-01-01 00:00:00 UTC
        let result = try await function.callback([NSNumber(value: timestamp)])
        XCTAssertNotNil(result as? String)
        
        // Test with format
        let result2 = try await function.callback([NSNumber(value: timestamp), "short"])
        XCTAssertNotNil(result2 as? String)
    }
    
    func testTimeFormatFunction() async throws {
        guard let function = category.functions["Time.format"] else {
            XCTFail("Time.format function not found")
            return
        }
        
        let timestamp: Int64 = 1640995200000
        let result = try await function.callback([NSNumber(value: timestamp)])
        XCTAssertNotNil(result as? String)
    }
}
