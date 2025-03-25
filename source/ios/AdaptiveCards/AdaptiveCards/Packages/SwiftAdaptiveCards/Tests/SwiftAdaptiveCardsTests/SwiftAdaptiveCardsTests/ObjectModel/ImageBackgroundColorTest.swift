//
//  ImageBackgroundColorTest.swift
//  SwiftAdaptiveCardsTests
//
//  Created by Hugo Gonzalez on 3/07/25.
//

import XCTest
@testable import SwiftAdaptiveCards

final class ImageBackgroundColorTest: XCTestCase {

    func testNoBackgroundColorTest() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Image",
                    "url": "Image"
                }
            ]
        }
        """
        
        // Mimic: ParseResult parseResult = AdaptiveCard::DeserializeFromString(...)
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let card = parseResult.adaptiveCard
        
        guard let elem = card.body.first else {
            XCTFail("Expected at least one element in card.body")
            return
        }
        
        // "std::static_pointer_cast<Image>(elem)" => "elem as? Image"
        guard let image = elem as? SwiftImage else {
            XCTFail("Expected the first element to be an Image")
            return
        }
        
        let backgroundColor = image.backgroundColor
        XCTAssertEqual(backgroundColor, "", "Expected empty backgroundColor")
    }
    
    func testAARRGGBBTest() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Image",
                    "url": "Image",
                    "backgroundColor": "#ABF65314"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let card = parseResult.adaptiveCard
        guard let image = card.body.first as? SwiftImage else {
            XCTFail("Expected an Image element")
            return
        }
        XCTAssertEqual(image.backgroundColor, "#ABF65314")
    }

    func testRRGGBBTest() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Image",
                    "url": "Image",
                    "backgroundColor": "#00A1F1"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let card = parseResult.adaptiveCard
        guard let image = card.body.first as? SwiftImage else {
            XCTFail("Expected an Image element")
            return
        }
        
        // Expect alpha is auto-inserted => "#FF00A1F1"
        XCTAssertEqual(image.backgroundColor, "#FF00A1F1")
    }
    
    func testLowerCaseCharactersTest() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Image",
                    "url": "Image",
                    "backgroundColor": "#ffa65314"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let card = parseResult.adaptiveCard
        guard let image = card.body.first as? SwiftImage else {
            XCTFail("Expected an Image element")
            return
        }
        XCTAssertEqual(image.backgroundColor, "#ffa65314")
    }
    
    func testInvalidLengthTest() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Image",
                    "url": "Image",
                    "backgroundColor": "#A00A1F1"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let card = parseResult.adaptiveCard
        guard let image = card.body.first as? SwiftImage else {
            XCTFail("Expected an Image element")
            return
        }
        
        // per the original test, invalid => "#00000000"
        XCTAssertEqual(image.backgroundColor, "#00000000")
    }
    
    func testInvalidCharacterTest() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Image",
                    "url": "Image",
                    "backgroundColor": "#ABF6P314"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let card = parseResult.adaptiveCard
        guard let image = card.body.first as? SwiftImage else {
            XCTFail("Expected an Image element")
            return
        }
        XCTAssertEqual(image.backgroundColor, "#00000000")
    }
    
    func testInvalidFormatTest() throws {
        let testJsonString = """
        {
            "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
            "type": "AdaptiveCard",
            "version": "1.0",
            "body": [
                {
                    "type": "Image",
                    "url": "Image",
                    "backgroundColor": "@ABF65314"
                }
            ]
        }
        """
        
        let parseResult = try SwiftAdaptiveCard.deserializeFromString(testJsonString, version: "1.0")
        let card = parseResult.adaptiveCard
        guard let image = card.body.first as? SwiftImage else {
            XCTFail("Expected an Image element")
            return
        }
        XCTAssertEqual(image.backgroundColor, "#00000000")
    }
}
