//
//  ACRatingsTest.swift
//  ACSwiftRewrite
//
//  Created by Rahul Pinjani on 1/23/25.
//
import Foundation
import XCTest
@testable import SwiftAdaptiveCards

class ACRatingTests: XCTestCase {
    
    /*
     This card doesnt render in production. Commenting out for now.
    func testShowCardSerialization() {
        let cardWithShowCard = """
               {
                 "type": "AdaptiveCard",
                 "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
                 "version": "1.5",
                 "body": [
                   {
                     "type": "Rating",
                     "max": 20,
                     "value": 3.2,
                     "color": "marigold",
                     "size": "large",
                     "count": 150
                   },
                   {
                     "type": "Rating",
                     "style": "compact",
                     "value": 3.2,
                     "color": "marigold",
                     "count": 1000
                   }
                 ]
               }
               """
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(cardWithShowCard, version: "1.5")
            let card = parseResult.adaptiveCard
            
            guard let ratingLabel = card.body.first as? SwiftRatingInput else {
                XCTFail("Cannot parse ratings label")
                return
            }
            
            XCTAssertEqual(ratingLabel.color.rawValue, "marigold")
            XCTAssertEqual(ratingLabel.elementTypeVal, .ratingInput) // Assuming elementTypeVal maps to the old 'type' property
            XCTAssertEqual(ratingLabel.value, 3.2)
            XCTAssertEqual(ratingLabel.max, 20)
            XCTAssertEqual(ratingLabel.count, 150)
            
            // Optionally test the second rating element if needed
            guard let secondRating = card.body[1] as? SwiftRatingInput else {
                XCTFail("Cannot parse second rating label")
                return
            }
            
            XCTAssertEqual(secondRating.style, "compact")
            XCTAssertEqual(secondRating.value, 3.2)
            XCTAssertEqual(secondRating.color.rawValue, "marigold")
            XCTAssertEqual(secondRating.count, 1000)
            
        } catch {
            XCTFail("Deserialization or serialization failed with error: \(error)")
        }
    }
     */
}
