//
//  FunctionCacheTests.swift
//  TeamSpaceAppTests
//
//  Created by Rahul Pinjani on 8/4/25.
//  Copyright © Microsoft Corporation. All rights reserved.
//
//  Design Document: { Include link here }
//

import XCTest
@testable import Expressions

class FunctionCacheTests: XCTestCase {
    
    // Actor at class level for thread-safe call counting
    private actor CallCounter {
        private var count = 0
        
        func increment() -> Int {
            count += 1
            return count
        }
        
        func getValue() -> Int {
            return count
        }
        
        func reset() {
            count = 0
        }
    }
    
    private var callCounter: CallCounter!
    
    override func setUp() {
        super.setUp()
        callCounter = CallCounter()
    }
    
    func testFunctionCaching() async throws {
        let testFunction = FunctionDeclaration(
            name: "testFunction",
            cacheResultFor: 5000, // 5 seconds
            callback: { _ in
                let count = await self.callCounter.increment()
                return "Called \(count) times"
            }
        )
        
        let cache = FunctionCallCache()
        
        // First call
        let result1 = await cache.callFunction(declaration: testFunction, params: [])
        XCTAssertEqual(result1 as? String, "Called 1 times")
        let callCount1 = await callCounter.getValue()
        XCTAssertEqual(callCount1, 1)
        
        // Second call should use cache
        let result2 = await cache.callFunction(declaration: testFunction, params: [])
        XCTAssertEqual(result2 as? String, "Called 1 times")
        let callCount2 = await callCounter.getValue()
        XCTAssertEqual(callCount2, 1) // Should still be 1 due to caching
    }
    
    func testFunctionCacheWithDifferentParams() async throws {
        let testFunction = FunctionDeclaration(
            name: "testFunction",
            cacheResultFor: 5000,
            callback: { params in
                _ = await self.callCounter.increment()
                let param = params.first as? String ?? "default"
                return "Called with \(param)"
            }
        )
        
        let cache = FunctionCallCache()
        
        // First call with param "A"
        let result1 = await cache.callFunction(declaration: testFunction, params: ["A"])
        XCTAssertEqual(result1 as? String, "Called with A")
        let callCount1 = await callCounter.getValue()
        XCTAssertEqual(callCount1, 1)
        
        // Second call with param "B" should not use cache
        let result2 = await cache.callFunction(declaration: testFunction, params: ["B"])
        XCTAssertEqual(result2 as? String, "Called with B")
        let callCount2 = await callCounter.getValue()
        XCTAssertEqual(callCount2, 2)
        
        // Third call with param "A" should use cache
        let result3 = await cache.callFunction(declaration: testFunction, params: ["A"])
        XCTAssertEqual(result3 as? String, "Called with A")
        let callCount3 = await callCounter.getValue()
        XCTAssertEqual(callCount3, 2) // Should still be 2 due to caching
    }
    
    func testFunctionCacheExpiration() async throws {
        let testFunction = FunctionDeclaration(
            name: "testFunction",
            cacheResultFor: 100, // 100 milliseconds
            callback: { _ in
                let count = await self.callCounter.increment()
                return "Called \(count) times"
            }
        )
        
        let cache = FunctionCallCache()
        
        // First call
        let result1 = await cache.callFunction(declaration: testFunction, params: [])
        XCTAssertEqual(result1 as? String, "Called 1 times")
        let callCount1 = await callCounter.getValue()
        XCTAssertEqual(callCount1, 1)
        
        // Wait for cache to expire
        try await Task.sleep(nanoseconds: 150_000_000) // 150 milliseconds
        
        // Second call should not use cache due to expiration
        let result2 = await cache.callFunction(declaration: testFunction, params: [])
        XCTAssertEqual(result2 as? String, "Called 2 times")
        let callCount2 = await callCounter.getValue()
        XCTAssertEqual(callCount2, 2)
    }
    
    func testFunctionWithoutCaching() async throws {
        let testFunction = FunctionDeclaration(
            name: "testFunction",
            cacheResultFor: nil, // No caching
            callback: { _ in
                let count = await self.callCounter.increment()
                return "Called \(count) times"
            }
        )
        
        let cache = FunctionCallCache()
        
        // First call
        let result1 = await cache.callFunction(declaration: testFunction, params: [])
        XCTAssertEqual(result1 as? String, "Called 1 times")
        let callCount1 = await callCounter.getValue()
        XCTAssertEqual(callCount1, 1)
        
        // Second call should not use cache
        let result2 = await cache.callFunction(declaration: testFunction, params: [])
        XCTAssertEqual(result2 as? String, "Called 2 times")
        let callCount2 = await callCounter.getValue()
        XCTAssertEqual(callCount2, 2)
    }
}
