//
//  AdaptiveCardsBridgeHelper.swift
//  AdaptiveCardsSwift
//
//  Created on 05/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

/// Helper class to convert between Swift and Objective-C models
@objc public class AdaptiveCardsBridgeHelper: NSObject {
    
    /// Converts an ACOAdaptiveCard to a SwiftAdaptiveCard
    @objc public static func convertToSwift(card: AnyObject) -> Any? {
        // Placeholder implementation
        return "Converted Swift card"
    }
    
    /// Registers Swift renderers with the Objective-C rendering system
    @objc public static func registerSwiftRenderers() {
        // Placeholder implementation
    }
}
