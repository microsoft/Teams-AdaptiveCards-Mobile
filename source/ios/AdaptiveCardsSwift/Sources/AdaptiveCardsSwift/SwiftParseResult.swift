//
//  SwiftParseResult.swift
//  AdaptiveCardsSwift
//
//  Created on 05/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation
import SwiftAdaptiveCards
import UIKit

/// Represents the result of parsing an Adaptive Card.
@objc(SwiftParseResultSwift)
public class SwiftParseResultSwift: NSObject {
    
    /// The status code of the parsing operation.
    @objc public var statusCode: Int
    
    /// The parsed Adaptive Card object, if parsing was successful.
    /*@objc */public var adaptiveCard: SwiftAdaptiveCard?
    
    /// Initializes a new instance of the SwiftParseResult class.
    /*@objc */public init(statusCode: Int, adaptiveCard: SwiftAdaptiveCard?) {
        self.statusCode = statusCode
        self.adaptiveCard = adaptiveCard
        super.init()
    }
}

/// Represents a warning that occurred during parsing.
@objc(SwiftAdaptiveCardParseWarningSwift)
public class SwiftAdaptiveCardParseWarningSwift: NSObject {
    
    /// The status code of the warning.
    @objc public var statusCode: Int
    
    /// The reason for the warning.
    @objc public var reason: String
    
    /// Initializes a new instance of the SwiftAdaptiveCardParseWarning class.
    @objc public init(statusCode: Int, reason: String) {
        self.statusCode = statusCode
        self.reason = reason
        super.init()
    }
}
