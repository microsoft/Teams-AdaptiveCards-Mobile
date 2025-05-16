//
//  SwiftAdaptiveCardBridge.swift
//  SwiftAdaptiveCardsBridge
//
//  Created on 5/14/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation
import SwiftAdaptiveCards

// Import AnyObject for the protocol constraint on the Obj-C protocol
#if canImport(AdaptiveCards)
import AdaptiveCards
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

@objcMembers
public class SwiftAdaptiveCardParseResult: NSObject {
    public var parseResult: SwiftParseResult?
    public var errors: [NSError]?
    public var warnings: [ACRParseWarning]?
}

// MARK: - Swift Factory Implementation

/**
 * Swift implementation of the ACRAdaptiveCardParserFactory protocol.
 * This class is responsible for bridging between the Swift implementation
 * and the Objective-C framework.
 */
@objcMembers
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
    
    @objc public func parseWarningsFromPayload(_ payload: String) -> [ACRParseWarning]? {
        guard let parseResult = try? SwiftAdaptiveCard.deserializeFromString(payload, version: "1.6") else {
            return nil
        }
        
        return parseResult.warnings.map { warning in
            // Convert SwiftAdaptiveCardParseWarning to ACRParseWarning
            ACRParseWarning.createWithStatusCode(
                warning.getStatusCode().convert().rawValue,
                reason: warning.getReason()
            )
        }
    }
    
    @objc public func getWarningsFromParseResult(_ parseResult: Any) -> [ACRParseWarning]? {
        // Safely cast to SwiftParseResult
        guard let swiftResult = parseResult as? SwiftParseResult else {
            return nil
        }
        
        return swiftResult.warnings.map { warning in
            ACRParseWarning.createWithStatusCode(
                warning.getStatusCode().convert().rawValue,
                reason: warning.getReason()
            )
        }
    }
}

// MARK: - Swift Integration Helper

/**
 * This class provides static methods that can be called from Objective-C
 * to register the Swift factory with the registry.
 */
@objcMembers
public class SwiftAdaptiveCardBridge: NSObject {
    
    @objc public static let shared = SwiftAdaptiveCardBridge()
    private static var factory: SwiftAdaptiveCardFactoryImpl?
    
    private override init() {
        super.init()
    }
    
    @objc public static func registerWithRegistry() {
        let factoryImpl = SwiftAdaptiveCardFactoryImpl(enabled: false)
        factory = factoryImpl
        
        // The following line requires ACRAdaptiveCardParserFactoryRegistry to be accessible
        // We use the Objective-C runtime to avoid direct dependencies
        if let registryClass = NSClassFromString("ACRAdaptiveCardParserFactoryRegistry"),
           let sharedInstance = registryClass.perform(NSSelectorFromString("sharedInstance")),
           let registry = sharedInstance.takeUnretainedValue() as? NSObject {
            
            let selector = NSSelectorFromString("registerFactory:withName:")
            typealias RegisterFunction = @convention(c) (NSObject, Selector, Any, String) -> Void
            let registerImpl = unsafeBitCast(registry.method(for: selector), to: RegisterFunction.self)
            registerImpl(registry, selector, factoryImpl, "SwiftAdaptiveCardParser")
            
            print("✅ SwiftAdaptiveCardBridge: Successfully registered Swift factory with registry")
        } else {
            print("❌ SwiftAdaptiveCardBridge: Failed to register Swift factory - registry not found")
        }
    }
    
    @objc public static func isRegistered() -> Bool {
        return factory != nil
    }
}

// MARK: - Conversion Helpers

extension SwiftWarningStatusCode: Convertible {
    public typealias Target = ACRWarningStatusCode

    public func convert() -> ACRWarningStatusCode {
        switch self {
        case .unknownElementType: return .unknownElementType
        case .unknownActionElementType: return .unknownActionElementType
        case .unknownPropertyOnElement: return .unknownPropertyOnElement
        case .unknownEnumValue: return .unknownEnumValue
        case .noRendererForType: return .noRendererForType
        case .interactivityNotSupported: return .interactivityNotSupported
        case .maxActionsExceeded: return .maxActionsExceeded
        case .assetLoadFailed: return .assetLoadFailed
        case .unsupportedSchemaVersion: return .unsupportedSchemaVersion
        case .unsupportedMediaType: return .unsupportedMediaType
        case .invalidMediaMix: return .invalidMediaMix
        case .invalidColorFormat: return .invalidColorFormat
        case .invalidDimensionSpecified: return .invalidDimensionSpecified
        case .invalidLanguage: return .invalidLanguage
        case .invalidValue: return .invalidValue
        case .customWarning: return .customWarning
        case .emptyLabelInRequiredInput: return .unknownPropertyOnElement
        case .requiredPropertyMissing: return .missingInputErrorMessage
        }
    }
}

// MARK: - Swift Parse Warning Conversion

extension SwiftAdaptiveCardParseWarning: Convertible {
    public typealias Target = ACRParseWarning

    public func convert() -> ACRParseWarning {
        return ACRParseWarning.createWithStatusCode(
            getStatusCode().convert().rawValue,
            reason: getReason()
        )
    }
}

// MARK: - ACRParseWarning Subclass

@objc public class ACRSwiftParseWarning: ACRParseWarning {
    // These properties will override the readonly properties from the parent
    private var _statusCode: ACRWarningStatusCode
    private var _reason: String
    
    @objc override public var statusCode: ACRWarningStatusCode {
        return _statusCode
    }
    
    @objc override public var reason: String {
        return _reason
    }
    
    @objc public init(statusCode: ACRWarningStatusCode, reason: String) {
        self._statusCode = statusCode
        self._reason = reason
        super.init()
    }
}

// MARK: - ACRParseWarning Extension

@objc extension ACRParseWarning {
    // Factory method that creates and returns the Swift subclass
    @objc public class func createWithStatusCode(_ statusCode: UInt, reason: String) -> ACRParseWarning {
        return ACRSwiftParseWarning(
            statusCode: ACRWarningStatusCode(rawValue: statusCode) ?? .unknownElementType,
            reason: reason
        )
    }
}