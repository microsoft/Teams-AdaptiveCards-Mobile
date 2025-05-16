//
// ImportHelpers.swift
// AdaptiveCardsSwift
//
// Created on 05/15/25.
// Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

// This file contains helpers for conditional imports and type aliases
// to help with module resolution during development

#if canImport(SwiftAdaptiveCards)
// SwiftAdaptiveCards module is available
#else
// Create stub types to allow compilation when module is not available
public class SwiftAdaptiveCard {
    public init() {}
    
    public static func deserializeFromString(_ jsonString: String, version: String) throws -> SwiftParseResult {
        // This is a stub implementation for development
        return SwiftParseResult(statusCode: 0, adaptiveCard: SwiftAdaptiveCard(), warnings: nil)
    }
}

public enum SwiftCardElementType {
    case adaptiveCard
    case textBlock
    case image
    case container
    case column
    case columnSet
    case factSet
    case fact
    case imageSet
    case actionSet
}

public enum SwiftVerticalContentAlignment {
    case top
    case center
    case bottom
}

public enum SwiftContainerStyle {
    case defaultStyle
    case emphasis
    case good
    case attention
    case warning
    case accent
}

public enum SwiftHeightType {
    case auto
    case stretch
}

public class SwiftRefresh {
}

public class SwiftAuthentication {
}

public class SwiftBackgroundImage {
}

public class SwiftBaseElement {
}

public class SwiftBaseCardElement {
}

public class SwiftBaseActionElement {
}

public class SwiftLayout {
}

public class SwiftSemanticVersion {
}

#endif
