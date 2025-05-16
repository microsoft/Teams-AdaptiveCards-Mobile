//
//  AdaptiveCardsAPI.swift
//  AdaptiveCardsSwift
//
//  Created on 05/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

/// The main entry point for Swift developers to work with Adaptive Cards.
@objc public class AdaptiveCardsAPI: NSObject {
    
    /// Singleton instance of the API.
    @objc public static let shared = AdaptiveCardsAPI()
    
    /// Whether to use the Swift parser implementation (if available).
    @objc public var useSwiftParser: Bool = false
    
    private override init() {
        super.init()
    }
    
    /// Parses an Adaptive Card from a JSON string.
    ///
    /// - Parameter jsonString: The JSON string to parse.
    /// - Returns: A result containing the parsed card or errors.
    /*@objc*/ public func parseCard(fromJSON jsonString: String) -> Result<Any, Error> {
        // Placeholder implementation
        return .success("Card parsed successfully")
    }
}
