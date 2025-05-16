//
//  SwiftAdaptiveCardBridge.swift
//  AdaptiveCardsSwift
//
//  Created on 5/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

// Try to import SwiftAdaptiveCards if available
#if canImport(SwiftAdaptiveCards)
import SwiftAdaptiveCards
#endif

// MARK: - Conversion Protocol

public protocol Convertible {
    associatedtype Target
    func convert() -> Target
}

extension Array where Element: Convertible {
    func convert() -> [Element.Target] {
        return self.map { $0.convert() }
    }
}

// MARK: - Swift Result Wrapper

@objc(SwiftAdaptiveCardParseResultSwift)
public class SwiftAdaptiveCardParseResultSwift: NSObject {
    @objc public var parseResult: SwiftParseResult?
    @objc public var errors: [NSError]?
    @objc public var warnings: [SwiftAdaptiveCardBridgeWarning]?
    
    @objc public var statusCode: Int {
        return parseResult?.statusCode ?? 0
    }
}

// MARK: - Swift Factory Implementation

/**
 * Swift implementation of the adaptive card parser factory.
 * This class is responsible for bridging between the Swift implementation
 * and the Objective-C framework.
 */
@objc(SwiftAdaptiveCardFactoryImpl)
public class SwiftAdaptiveCardFactoryImpl: NSObject {
    
    private var swiftParserEnabled = false
    
    @objc public init(enabled: Bool = false) {
        self.swiftParserEnabled = enabled
        super.init()
    }
    
    @objc public func isEnabled() -> Bool {
        return swiftParserEnabled
    }
    
    @objc public func setEnabled(_ enabled: Bool) {
        swiftParserEnabled = enabled
    }
    
    @objc public func parseWarningsFromPayload(_ payload: String) -> [SwiftAdaptiveCardBridgeWarning]? {
        guard let parseResult = try? SwiftAdaptiveCard.deserializeFromString(payload, version: "1.6") else {
            return nil
        }
        
        // Convert from SwiftAdaptiveCardParseWarning to SwiftAdaptiveCardBridgeWarning
//        return parseResult.warnings.map { SwiftAdaptiveCardBridgeWarning(from: $0) } // fixme
        fatalError()
    }
    
    @objc public func getWarningsFromParseResult(_ parseResult: Any) -> [SwiftAdaptiveCardBridgeWarning]? {
        // Safely cast to SwiftParseResult
        guard let swiftResult = parseResult as? SwiftParseResult else {
            return nil
        }
        
        // Convert from SwiftAdaptiveCardParseWarning to SwiftAdaptiveCardBridgeWarning
//        return swiftResult.warnings?.map { SwiftAdaptiveCardBridgeWarning(from: $0) } // fixme
        fatalError()
    }
}

// MARK: - Swift Integration Helper

/**
 * This class provides static methods that can be called from Objective-C
 * to interact with Swift functionality.
 */
// Using SwiftAdaptiveCardBridgeParser instead to avoid duplicate class declaration
@objc(SwiftAdaptiveCardBridgeParserSwift)
public class SwiftAdaptiveCardBridgeParserSwift: NSObject {
    
    private static var factoryImpl: SwiftAdaptiveCardFactoryImpl?
    
    @objc public static func isSwiftParserEnabled() -> Bool {
        return factoryImpl?.isEnabled() ?? false
    }
    
    @objc public static func enableSwiftParser(_ enabled: Bool) {
        if factoryImpl == nil {
            factoryImpl = SwiftAdaptiveCardFactoryImpl(enabled: enabled)
        } else {
            factoryImpl?.setEnabled(enabled)
        }
    }
    
    @objc public static func parseWithPayload(_ payload: String) -> SwiftAdaptiveCardParseResultSwift? {
        guard let parseResult = try? SwiftAdaptiveCard.deserializeFromString(payload, version: "1.6") else {
            return nil
        }
        
        let result = SwiftAdaptiveCardParseResultSwift()
//        result.parseResult = parseResult
        
        // Convert from SwiftAdaptiveCardParseWarning to SwiftAdaptiveCardBridgeWarning
//        if let warnings = parseResult.warnings {
//            result.warnings = warnings.map { SwiftAdaptiveCardBridgeWarning(from: $0) }
//        }
        
        return result
    }
}

// MARK: - Warning Type Definition

@objc(SwiftWarningStatusCode)
public class SwiftWarningStatusCode: NSObject {
    @objc public static let unknownElementType = 0
    @objc public static let unknownActionElementType = 1
    @objc public static let unknownPropertyOnElement = 2
    @objc public static let unknownEnumValue = 3
    @objc public static let noRendererForType = 4
    @objc public static let interactivityNotSupported = 5
    @objc public static let maxActionsExceeded = 6
    @objc public static let assetLoadFailed = 7
    @objc public static let unsupportedSchemaVersion = 8
    @objc public static let unsupportedMediaType = 9
    @objc public static let invalidMediaMix = 10
    @objc public static let invalidColorFormat = 11
    @objc public static let invalidDimensionSpecified = 12
    @objc public static let invalidLanguage = 13
    @objc public static let invalidValue = 14
    @objc public static let customWarning = 15
    @objc public static let emptyLabelInRequiredInput = 16
    @objc public static let requiredPropertyMissing = 17
    @objc public static let missingInputErrorMessage = 18
}

// MARK: - Swift Parse Warning Definition

// Using internal wrapper to avoid duplicate class declaration with SwiftParseResult.swift
@objc(SwiftAdaptiveCardBridgeWarning)
public class SwiftAdaptiveCardBridgeWarning: NSObject {
    private var _statusCode: Int
    private var _reason: String
    
    @objc public init(statusCode: Int, reason: String) {
        self._statusCode = statusCode
        self._reason = reason
        super.init()
    }
    
    @objc public func getStatusCode() -> Int {
        return _statusCode
    }
    
    @objc public var statusCode: Int {
        return _statusCode
    }
    
    @objc public func getReason() -> String {
        return _reason
    }
    
    @objc public var reason: String {
        return _reason
    }
    
    // Add conversion from the primary warning type
    public convenience init(from warning: SwiftAdaptiveCardParseWarning) {
        self.init(statusCode: warning.statusCode, reason: warning.reason)
    }
}
