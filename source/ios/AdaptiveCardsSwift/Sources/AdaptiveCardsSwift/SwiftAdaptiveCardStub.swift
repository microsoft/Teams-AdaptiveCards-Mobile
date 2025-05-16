//
//  SwiftAdaptiveCardStub.swift
//  AdaptiveCardsSwift
//
//  Created on 05/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

// This file provides stub implementations for the SwiftAdaptiveCards types
// when the actual module is not available

#if !canImport(SwiftAdaptiveCards)

/// A stub implementation of SwiftAdaptiveCard
public class SwiftAdaptiveCard: NSObject {
    /// Initializes a new instance of the SwiftAdaptiveCard class
    public override init() {
        super.init()
    }
    
    /// Deserializes a card from a JSON string
    /// - Parameters:
    ///   - jsonString: The JSON string to deserialize
    ///   - version: The version of the schema to use
    /// - Returns: A parse result containing the card or error information
    public static func deserializeFromString(_ jsonString: String, version: String) throws -> SwiftParseResult {
        let card = SwiftAdaptiveCard()
        let result = SwiftParseResult(statusCode: 0, adaptiveCard: card)
        return result
    }
}

#endif
