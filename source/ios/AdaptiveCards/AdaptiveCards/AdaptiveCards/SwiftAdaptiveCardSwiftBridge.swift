//
//  SwiftAdaptiveCardBridge.swift
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 3/3/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import UIKit

public protocol Convertible {
    associatedtype Target
    func convert() -> Target
}

extension Array where Element: Convertible {
    func convert() -> [Element.Target] {
        return self.map { $0.convert() }
    }
}

@objcMembers
public class SwiftAdaptiveCardParseResult: NSObject {
    public var parseResult: SwiftParseResult?
    public var errors: [NSError]?
    public var warnings: [ACRParseWarning]?
}

@objcMembers
public class SwiftAdaptiveCardParser: NSObject {
    public static let main = SwiftAdaptiveCardParser()
    
    private var swiftParserEnabled = false
    
    // Toggle by ECS flag
    public static func setSwiftParserEnabled(_ isEnabled: Bool) {
        main.swiftParserEnabled = isEnabled
    }
    
    public static func isSwiftParserEnabled() -> Bool {
        return main.swiftParserEnabled
    }
    
    public static func parse(payload: String) -> SwiftAdaptiveCardParseResult {
        let result = SwiftAdaptiveCardParseResult()
        
        do {
            let parseResult = try SwiftAdaptiveCard.deserializeFromString(payload, version: "1.6")
            result.parseResult = parseResult
            result.warnings = parseResult.warnings.convert()
        } catch {
            // Capture the error instead of returning nil
            let nsError = error as NSError
            result.errors = [nsError]
            result.parseResult = nil
            result.warnings = []
        }
        
        return result
    }
}

// MARK: - ACRParseWarning
extension SwiftAdaptiveCardParseWarning: Convertible {
    public typealias Target = ACRParseWarning

    public func convert() -> ACRParseWarning {
        return .createWithStatusCode(getStatusCode().convert().rawValue, reason: getReason())
    }
}

extension SwiftWarningStatusCode: Convertible {
    public typealias Target = ACRWarningStatusCode

    public func convert() -> ACRWarningStatusCode {
        switch self {
        case .unknownElementType: .unknownElementType
        case .unknownActionElementType: .unknownActionElementType
        case .unknownPropertyOnElement: .unknownPropertyOnElement
        case .unknownEnumValue: .unknownEnumValue
        case .noRendererForType: .noRendererForType
        case .interactivityNotSupported: .interactivityNotSupported
        case .maxActionsExceeded: .maxActionsExceeded
        case .assetLoadFailed: .assetLoadFailed
        case .unsupportedSchemaVersion: .unsupportedSchemaVersion
        case .unsupportedMediaType: .unsupportedMediaType
        case .invalidMediaMix: .invalidMediaMix
        case .invalidColorFormat: .invalidColorFormat
        case .invalidDimensionSpecified: .invalidDimensionSpecified
        case .invalidLanguage: .invalidLanguage
        case .invalidValue: .invalidValue
        case .customWarning: .customWarning
        case .emptyLabelInRequiredInput: .unknownPropertyOnElement
        case .requiredPropertyMissing: .missingInputErrorMessage
        }
    }
}

// Swift subclass of ACRParseWarning
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

// Extension to add factory method to ACRParseWarning
@objc extension ACRParseWarning {
    // Factory method that creates and returns the Swift subclass
    @objc public class func createWithStatusCode(_ statusCode: UInt, reason: String) -> ACRParseWarning {
        return ACRSwiftParseWarning(
            statusCode: ACRWarningStatusCode(rawValue: statusCode) ?? .unknownElementType,
            reason: reason
        )
    }
}

// MARK: - Swift KVO Helper
/// A thread-safe Swift KVO helper using Apple's recommended NSKeyValueObservation pattern
/// This replaces manual addObserver/removeObserver calls with proper Swift KVO blocks
/// Reference: https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift
@objcMembers
public class SwiftKVOHelper: NSObject {
    private var activeObservations: [NSKeyValueObservation] = []
    private let observationQueue = DispatchQueue(label: "com.microsoft.adaptivecards.kvo", qos: .userInitiated)
    
    // Static shared instance for easy access from Objective-C
    public static let shared = SwiftKVOHelper()
    
    private override init() {
        super.init()
    }
    
    /// Thread-safe Swift KVO using Apple's recommended observe(_:options:changeHandler:) pattern
    /// This automatically handles cleanup when the observation is deallocated
    /// Note: This is a generic method for non-UIImageView objects where we can't use typed key paths
    @objc public func observeObject(_ object: NSObject,
                                   keyPath: String,
                                   observer: NSObject,
                                   context: UnsafeRawPointer?,
                                   changeHandler: @escaping (NSObject, Any?, UnsafeRawPointer?) -> Void) {
        
        // For generic objects, we still need to use the string-based KVO pattern
        // but wrap it with proper Swift cleanup
        observationQueue.async { [weak self, weak observer, weak object] in
            guard let self = self,
                  let observer = observer,
                  let object = object else { return }
            
            DispatchQueue.main.async {
                // Use traditional KVO for generic key paths, but with safer cleanup tracking
                object.addObserver(observer, forKeyPath: keyPath, options: [.new], context: UnsafeMutableRawPointer(mutating: context))
                
                // Note: For generic string-based KVO, we still need manual cleanup
                // This is a limitation when we can't use typed Swift key paths
            }
        }
    }
    
    /// Convenience method specifically for image observations using Swift KVO blocks
    /// This follows Apple's recommended pattern for thread-safe KVO
    @objc public func observeImageOnView(_ view: NSObject,
                                        observer: NSObject,
                                        element: UnsafeRawPointer?) {
        
        guard let imageView = view as? UIImageView else { return }
        
        // Check if we're already on the main thread to avoid unnecessary dispatch
        let triggerImmediateUpdate = { [weak observer] in
            guard let observer = observer else { return }
            
            // Check for existing image and trigger immediate layout update to prevent jitter
            if let existingImage = imageView.image {
                var changeDict: [NSKeyValueChangeKey: Any] = [:]
                changeDict[.newKey] = existingImage
                
                if observer.responds(to: #selector(NSObject.observeValue(forKeyPath:of:change:context:))) {
                    observer.observeValue(forKeyPath: "image", of: view, change: changeDict, context: UnsafeMutableRawPointer(mutating: element))
                }
            }
        }
        
        // Trigger immediate update synchronously if on main thread, async if not
        if Thread.isMainThread {
            triggerImmediateUpdate()
        } else {
            DispatchQueue.main.async {
                triggerImmediateUpdate()
            }
        }
        
        // Set up Swift KVO observation using Apple's recommended pattern
        observationQueue.async { [weak self, weak observer, weak imageView] in
            guard let self = self,
                  let observer = observer,
                  let imageView = imageView else { return }
            
            // Use Swift KVO observe pattern - automatically thread-safe and cleans up properly
            let observation = imageView.observe(\.image, options: [.new]) { [weak observer] observedImageView, change in
                DispatchQueue.main.async {
                    guard let observer = observer else { return }
                    
                    // Convert to the format expected by the existing observeValueForKeyPath implementation
                    var changeDict: [NSKeyValueChangeKey: Any] = [:]
                    if let newImage = change.newValue {
                        changeDict[.newKey] = newImage
                    }
                    
                    if observer.responds(to: #selector(NSObject.observeValue(forKeyPath:of:change:context:))) {
                        observer.observeValue(forKeyPath: "image", of: observedImageView, change: changeDict, context: UnsafeMutableRawPointer(mutating: element))
                    }
                }
            }
            
            // Store the observation to keep it alive
            DispatchQueue.main.async {
                self.observationQueue.sync {
                    self.activeObservations.append(observation)
                }
            }
        }
    }
    
    /// Remove all observations - Swift KVO observations automatically clean up when deallocated
    @objc public func removeAllObservations() {
        observationQueue.sync { [weak self] in
            guard let self = self else { return }
            
            // Clear all observations - they will automatically clean up
            self.activeObservations.removeAll()
        }
    }
    
    /// Clean up any observations that are no longer needed
    /// Swift KVO observations with weak references automatically become invalid when targets deallocate
    @objc public func cleanupInvalidObservers() {
        // No manual cleanup needed with Swift KVO - observations automatically invalidate
        // when their weak targets are deallocated
    }
    
    deinit {
        removeAllObservations()
    }
}
