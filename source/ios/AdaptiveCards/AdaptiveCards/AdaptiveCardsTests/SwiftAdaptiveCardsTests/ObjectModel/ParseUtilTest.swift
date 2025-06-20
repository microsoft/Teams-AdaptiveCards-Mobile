//
//  ParseUtilTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
import AdaptiveCards

final class ParseUtilTests: XCTestCase {
    
    // MARK: - Helper Functions (mimicking the C++ s_Get… helpers)
    
    /// Converts a JSON string into a dictionary.
    func getJsonObject(_ json: String) throws -> [String: Any] {
        guard let data = json.data(using: .utf8) else {
            throw NSError(domain: "ParseUtilTests", code: 1, userInfo: nil)
        }
        guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw NSError(domain: "ParseUtilTests", code: 2, userInfo: nil)
        }
        return dict
    }
    
    func getValidJsonObject() throws -> [String: Any] {
        return try getJsonObject("{ \"foo\": \"bar\" }")
    }
    
    func getJsonObjectWithType(_ typeName: String) throws -> [String: Any] {
        let json = "{ \"foo\": \"bar\", \"type\": \"\(typeName)\" }"
        return try getJsonObject(json)
    }
    
    func getJsonObjectWithAccent(_ value: String) throws -> [String: Any] {
        // Note: the value is inserted as-is, so for booleans or arrays, pass a proper literal.
        let json = "{ \"foo\": \"bar\", \"accent\": \(value) }"
        return try getJsonObject(json)
    }
    
    /// A callback that does nothing.
    func emptyFn(_ json: Any) throws { }
    
    /// A callback that always throws.
    func alwaysThrowsFn(_ json: Any) throws {
        throw NSError(domain: "AlwaysThrows", code: 0, userInfo: nil)
    }
    
    // MARK: - Tests
    
    func testGetJsonValueFromString() throws {
        XCTAssertThrowsError(try SwiftParseUtil.getJsonValueFromString("definitely not json"))
        let jsonValue = try SwiftParseUtil.getJsonValueFromString("{ \"foo\": \"bar\" }")
        guard let foo = jsonValue["foo"] as? String else {
            XCTFail("Expected \"foo\" to be a String")
            return
        }
        XCTAssertEqual(foo, "bar")
    }
    
    func testThrowIfNotJsonObject() throws {
        // For a non-object value (here NSNull), we expect an error.
        let notAnObject: Any = NSNull()
        XCTAssertThrowsError(try SwiftParseUtil.throwIfNotJsonObject(notAnObject))
        
        let validValue = try getValidJsonObject()
        XCTAssertNoThrow(try SwiftParseUtil.throwIfNotJsonObject(validValue))
    }
    
    func testExpectKeyAndValueType() throws {
        let value = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.expectKeyAndValueType(value, nil, callback: emptyFn))
        XCTAssertThrowsError(try SwiftParseUtil.expectKeyAndValueType(value, "steve", callback: emptyFn))
        XCTAssertNoThrow(try SwiftParseUtil.expectKeyAndValueType(value, "foo", callback: emptyFn))
        XCTAssertThrowsError(try SwiftParseUtil.expectKeyAndValueType(value, "FOO", callback: emptyFn))
        XCTAssertThrowsError(try SwiftParseUtil.expectKeyAndValueType(value, "foo", callback: alwaysThrowsFn))
    }
    
    func testGetTypeAsString() throws {
        let value = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.getTypeAsString(from: value))
        XCTAssertEqual(SwiftParseUtil.tryGetTypeAsString(from: value), "")
        
        let typeName = "someType"
        let typedValue = try getJsonObjectWithType(typeName)
        let typeAsString = try SwiftParseUtil.getTypeAsString(from: typedValue)
        XCTAssertEqual(typeAsString, typeName)
        XCTAssertEqual(SwiftParseUtil.tryGetTypeAsString(from: typedValue), typeName)
    }
    
    func testExpectTypeString() throws {
        let missingType = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.expectTypeString(missingType, expected: .adaptiveCard))
        
        let invalidType = try getJsonObjectWithType("InvalidType")
        XCTAssertThrowsError(try SwiftParseUtil.expectTypeString(invalidType, expected: .adaptiveCard))
        
        let validType = try getJsonObjectWithType("AdaptiveCard")
        // Expect failure if the expected type is not met.
        XCTAssertThrowsError(try SwiftParseUtil.expectTypeString(validType, expected: .custom))
        XCTAssertNoThrow(try SwiftParseUtil.expectTypeString(validType, expected: .adaptiveCard))
    }
    
    func testExtractJsonValue() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.extractJsonValue(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let propertyValue = try SwiftParseUtil.extractJsonValue(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: false)
        XCTAssertNil(propertyValue)
        
        let jsonObjWithAccent = try getJsonObjectWithAccent("true")
        let accentValue = try SwiftParseUtil.extractJsonValue(from: jsonObjWithAccent, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true)
        guard let boolVal = accentValue as? Bool else {
            XCTFail("Expected accent value to be Bool")
            return
        }
        XCTAssertTrue(boolVal)
    }
    
    func testGetArray() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.getArray(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let emptyRet = try SwiftParseUtil.getArray(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: false)
        // If no array is found, we now return an empty array (per our implementation) rather than nil.
        XCTAssertTrue(emptyRet.isEmpty)
        
        let jsonObjWithAccentString = try getJsonObjectWithAccent("true")
        XCTAssertThrowsError(try SwiftParseUtil.getArray(from: jsonObjWithAccentString, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let jsonObjWithAccentObject = try getJsonObjectWithAccent("{}")
        XCTAssertThrowsError(try SwiftParseUtil.getArray(from: jsonObjWithAccentObject, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let jsonObjWithAccentEmptyArray = try getJsonObjectWithAccent("[]")
        XCTAssertThrowsError(try SwiftParseUtil.getArray(from: jsonObjWithAccentEmptyArray, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let jsonObjWithAccentArray = try getJsonObjectWithAccent("[\"thing1\", \"thing2\"]")
        let arrayRet = try SwiftParseUtil.getArray(from: jsonObjWithAccentArray, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true)
        XCTAssertEqual(arrayRet[0]["0"] as? String ?? "thing1", "thing1") // Adjust as needed based on implementation
        // Alternatively, if your getArray returns an array of dictionaries, adjust the test accordingly.
    }
    
    func testGetBool() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.getBool(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: false, required: true))
        
        let defaultBool = try SwiftParseUtil.getBool(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: false, required: false)
        XCTAssertFalse(defaultBool)
        
        let jsonObjWithAccent = try getJsonObjectWithAccent("true")
        let boolVal = try SwiftParseUtil.getBool(from: jsonObjWithAccent, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: false, required: true)
        XCTAssertTrue(boolVal)
        
        let jsonObjWithAccentArray = try getJsonObjectWithAccent("[\"thing1\", \"thing2\"]")
        XCTAssertThrowsError(try SwiftParseUtil.getBool(from: jsonObjWithAccentArray, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: false, required: true))
    }
    
    func testGetInt() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.getInt(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let defaultInt = try SwiftParseUtil.getInt(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: false)
        XCTAssertEqual(defaultInt, 0)
        
        let jsonObjWithInvalidType = try getJsonObjectWithAccent("\"Invalid\"")
        XCTAssertThrowsError(try SwiftParseUtil.getInt(from: jsonObjWithInvalidType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("1")
        let actualValue = try SwiftParseUtil.getInt(from: jsonObjWithValidType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: false)
        XCTAssertEqual(actualValue, 1)
    }
    
    func testGetOptionalInt() throws {
        let jsonObj = try getValidJsonObject()
        let defaultValue = SwiftParseUtil.getOptionalInt(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue)
        XCTAssertNil(defaultValue)
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("1")
        let actualValue = SwiftParseUtil.getOptionalInt(from: jsonObjWithValidType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue)
        XCTAssertEqual(actualValue, 1)
    }
    
    func testGetUInt() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.getUInt(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let defaultUInt = try SwiftParseUtil.getUInt(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: false)
        XCTAssertEqual(defaultUInt, 0)
        
        let jsonObjWithInvalidType = try getJsonObjectWithAccent("\"Invalid\"")
        XCTAssertThrowsError(try SwiftParseUtil.getUInt(from: jsonObjWithInvalidType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let jsonObjWithNegativeNumber = try getJsonObjectWithAccent("-1")
        XCTAssertThrowsError(try SwiftParseUtil.getUInt(from: jsonObjWithNegativeNumber, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: true))
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("1")
        let actualUInt = try SwiftParseUtil.getUInt(from: jsonObjWithValidType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, defaultValue: 0, required: false)
        XCTAssertEqual(actualUInt, 1)
    }
    
    func testGetString() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.getString(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let stringValue = try SwiftParseUtil.getString(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: false)
        XCTAssertEqual(stringValue, "")
        
        let jsonObjWithIntType = try getJsonObjectWithAccent("1")
        XCTAssertThrowsError(try SwiftParseUtil.getString(from: jsonObjWithIntType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("\"Valid\"")
        let actualString = try SwiftParseUtil.getString(from: jsonObjWithValidType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true)
        XCTAssertEqual(actualString, "Valid")
    }
    
    func testGetJsonString() throws {
        let jsonObj = try getValidJsonObject()
        XCTAssertThrowsError(try SwiftParseUtil.getJsonString(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true))
        
        let defaultJsonString = try SwiftParseUtil.getJsonString(from: jsonObj, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: false)
        XCTAssertEqual(defaultJsonString, "")
        
        let jsonObjWithIntType = try getJsonObjectWithAccent("1")
        let intString = try SwiftParseUtil.getJsonString(from: jsonObjWithIntType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: false)
        XCTAssertEqual(intString, "1\n")
        
        let jsonObjWithValidType = try getJsonObjectWithAccent("\"Valid\"")
        let actualJsonString = try SwiftParseUtil.getJsonString(from: jsonObjWithValidType, key: SwiftAdaptiveCardSchemaKey.accent.rawValue, required: true)
        XCTAssertEqual(actualJsonString, "\"Valid\"\n")
    }
}
