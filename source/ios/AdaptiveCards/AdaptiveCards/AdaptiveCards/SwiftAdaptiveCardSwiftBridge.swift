//
//  SwiftAdaptiveCardBridge.swift
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 3/3/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

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
    
    /// Convenience method specifically for image observations using Swift KVO blocks
    /// This follows Apple's recommended pattern for thread-safe KVO
    @objc public func observeImageOnView(_ view: NSObject,
                                        observer: NSObject,
                                        element: NSValue?) {
        
        guard let imageView = view as? UIImageView else { return }
        
        // Extract context pointer from NSValue
        let contextPointer = element?.pointerValue
        
        // Check if we're already on the main thread to avoid unnecessary dispatch
        let triggerImmediateUpdate = { [weak observer] in
            guard let observer = observer else { return }
            
            // Check for existing image and trigger immediate layout update to prevent jitter
            if let existingImage = imageView.image {
                // Prevent constraint animations during immediate setup
                UIView.performWithoutAnimation {
                    var changeDict: [NSKeyValueChangeKey: Any] = [:]
                    changeDict[.newKey] = existingImage
                    
                    if observer.responds(to: #selector(NSObject.observeValue(forKeyPath:of:change:context:))) {
                        observer.observeValue(forKeyPath: "image", of: view, change: changeDict, context: UnsafeMutableRawPointer(mutating: contextPointer))
                    }
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
            let observation = imageView.observe(\.image, options: [.new, .old]) { [weak observer] observedImageView, change in
                DispatchQueue.main.async {
                    guard let observer = observer else { return }
                    
                    // Extract actual image values from optionals-of-optionals
                    let actualOldImage = change.oldValue ?? nil
                    let actualNewImage = change.newValue ?? nil
                    
                    // Skip initial nil→nil observations to match traditional KVO behavior
                    if actualOldImage == nil && actualNewImage == nil {
                        return
                    }
                    
                    // Prevent constraint animations during image changes
                    UIView.performWithoutAnimation {
                        // Convert to the format expected by the existing observeValueForKeyPath implementation
                        var changeDict: [NSKeyValueChangeKey: Any] = [:]
                        if let newImage = actualNewImage {
                            changeDict[.newKey] = newImage
                        }
                        
                        if observer.responds(to: #selector(NSObject.observeValue(forKeyPath:of:change:context:))) {
                            observer.observeValue(forKeyPath: "image", of: observedImageView, change: changeDict, context: UnsafeMutableRawPointer(mutating: contextPointer))
                        }
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
    
    deinit {
        removeAllObservations()
    }
    
    /// Static method for updating layout when using Swift KVO
    /// This prevents animation issues and timing problems with image loading
    @objc public static func updateLayoutForSwiftKVO(_ view: UIView) {
        // Disable all layer animations during layout updates
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Also prevent UIKit animations
        UIView.performWithoutAnimation {
            updateLayoutForSwiftKVOInternal(view)
        }
        
        CATransaction.commit()
    }
    
    private static func updateLayoutForSwiftKVOInternal(_ view: UIView) {
        // Thread-safe recursion protection using a Set
        struct RecursionGuard {
            static var currentlyUpdatingViews: Set<UIView> = []
            static let lock = NSLock()
        }
        
        RecursionGuard.lock.lock()
        defer { RecursionGuard.lock.unlock() }
        
        // Prevent infinite recursion
        if RecursionGuard.currentlyUpdatingViews.contains(view) {
            return
        }
        
        RecursionGuard.currentlyUpdatingViews.insert(view)
        
        // Ensure we're on the main thread for UI updates
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                updateLayoutForSwiftKVO(view)
            }
            return
        }
        
        // Disable animations on the entire view hierarchy
        var currentView: UIView? = view
        var originalAnimationEnabledStates: [(UIView, Bool)] = []
        
        // Walk up the hierarchy and disable animations
        while let safeView = currentView {
            let originalState = safeView.layer.allowsGroupOpacity
            originalAnimationEnabledStates.append((safeView, originalState))
            safeView.layer.allowsGroupOpacity = false
            currentView = safeView.superview
            
            // Stop at table view or collection view level
            if safeView is UITableView || safeView is UICollectionView {
                break
            }
        }
        
        // Force intrinsic content size update
        view.invalidateIntrinsicContentSize()
        
        // Walk up view hierarchy to invalidate parent intrinsic content sizes
        currentView = view.superview
        var depth = 0
        let maxDepth = 10 // Prevent infinite loops in complex hierarchies
        
        while let safeCurrentView = currentView, depth < maxDepth {
            safeCurrentView.invalidateIntrinsicContentSize()
            
            // Special handling for collection views and table views
            if safeCurrentView is UITableViewCell || safeCurrentView is UICollectionViewCell {
                safeCurrentView.setNeedsLayout()
                
                // Find and notify the parent collection/table view WITHOUT animations
                var collectionCandidate = safeCurrentView.superview
                while let candidate = collectionCandidate, depth < maxDepth {
                    if let tableView = candidate as? UITableView {
                        // Disable table view animations completely
                        DispatchQueue.main.async {
                            UIView.performWithoutAnimation {
                                CATransaction.begin()
                                CATransaction.setDisableActions(true)
                                tableView.beginUpdates()
                                tableView.endUpdates()
                                CATransaction.commit()
                            }
                        }
                        break
                    } else if let collectionView = candidate as? UICollectionView {
                        // Disable collection view animations completely
                        DispatchQueue.main.async {
                            UIView.performWithoutAnimation {
                                CATransaction.begin()
                                CATransaction.setDisableActions(true)
                                collectionView.collectionViewLayout.invalidateLayout()
                                CATransaction.commit()
                            }
                        }
                        break
                    }
                    collectionCandidate = candidate.superview
                    depth += 1
                }
                break
            }
            
            currentView = safeCurrentView.superview
            depth += 1
        }
        
        // Force layout update on original view
        view.setNeedsLayout()
        
        // Restore original animation states
        for (viewToRestore, originalState) in originalAnimationEnabledStates {
            viewToRestore.layer.allowsGroupOpacity = originalState
        }
        
        // Remove from recursion protection after a brief delay
        DispatchQueue.main.async {
            RecursionGuard.lock.lock()
            RecursionGuard.currentlyUpdatingViews.remove(view)
            RecursionGuard.lock.unlock()
        }
    }
}
