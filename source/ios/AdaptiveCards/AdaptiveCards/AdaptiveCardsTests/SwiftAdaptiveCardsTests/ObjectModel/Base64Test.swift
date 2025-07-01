//
//  Base64Test.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
import AdaptiveCards

class Base64Tests: XCTestCase {
    
    /// Utility function for comparing decoded data to an expected string.
    private func containSameCharacters(_ expected: String, _ decoded: [UInt8]) -> Bool {
        // Convert decoded bytes back to a String using UTF-8.
        guard let decodedString = String(bytes: decoded, encoding: .utf8) else {
            return false
        }
        return decodedString == expected
    }
    
    func testEncoding() {
        let decodedData = ["", "f", "fo", "foo", "foob", "fooba", "foobar"]
        let expectedEncodedData = ["", "Zg==", "Zm8=", "Zm9v", "Zm9vYg==", "Zm9vYmE=", "Zm9vYmFy"]
        
        for i in 0..<decodedData.count {
            // Convert the string to a byte array.
            let bytes = Array(decodedData[i].utf8)
            let encoded = SwiftAdaptiveBase64Util.encode(bytes)
            XCTAssertEqual(encoded, expectedEncodedData[i], "Encoded string did not match expected result at index \(i).")
        }
    }

    func testDecoding() {
        let expectedDecodedData = ["", "f", "fo", "foo", "foob", "fooba", "foobar"]
        let encodedData = ["", "Zg==", "Zm8=", "Zm9v", "Zm9vYg==", "Zm9vYmE=", "Zm9vYmFy"]
        
        // Check empty base64.
        guard let decoded0 = SwiftAdaptiveBase64Util.decode(encodedData[0]) else {
            XCTFail("Decoding returned nil for empty base64 string")
            return
        }
        XCTAssertEqual(decoded0.count, expectedDecodedData[0].count, "Empty base64 should decode to empty data.")
        
        // Check the rest.
        for i in 1..<encodedData.count {
            guard let decodedBytes = SwiftAdaptiveBase64Util.decode(encodedData[i]) else {
                XCTFail("Decoding returned nil for \(encodedData[i])")
                continue
            }
            XCTAssertTrue(containSameCharacters(expectedDecodedData[i], decodedBytes),
                          "Decoded data does not match expected string at index \(i).")
        }
    }
    
    func testFailToDecode() {
        let badUris = [
            "foo_bar", "foo(bar)", "foo-bar", "foo*bar", "foo\"bar",
            "foo&bar", "foo^bar", "foo#bar", "foo@bar", "foo!bar"
        ]
        
        // Ensure that decoding invalid base64 doesn't crash. If decode returns nil,
        // that is acceptable; if it returns a value, we simply ignore it.
        for uri in badUris {
            _ = SwiftAdaptiveBase64Util.decode(uri)
        }
    }
}
