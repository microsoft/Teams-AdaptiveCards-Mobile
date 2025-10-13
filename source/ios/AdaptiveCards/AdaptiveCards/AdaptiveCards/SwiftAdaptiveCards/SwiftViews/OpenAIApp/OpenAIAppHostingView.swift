//
//  OpenAIAppHostingView.swift
//  AdaptiveCards
//
//  Created on 10/12/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import SwiftUI
import UIKit

import UIKit
import SwiftUI

/// UIKit wrapper for OpenAIAppView that can be integrated into the Objective-C rendering pipeline
/// Handles automatic height calculation and layout invalidation
@available(iOS 15.0, *)
@objc public class OpenAIAppHostingView: UIView {
    
    private let appData: OpenAIAppData
    private var hostingController: UIHostingController<AnyView>?
    private var heightConstraint: NSLayoutConstraint?
    private var lastKnownHeight: CGFloat = 0
    private var isUpdatingHeight = false
    private var lastReportedHeight: CGFloat = 0
    
    /// Initialize with app data
    init(appData: OpenAIAppData) {
        self.appData = appData
        super.init(frame: .zero)
        ACDiagnosticLogger.log("Initializing hosting view for app: \(appData.appName)", category: "Lifecycle")
        setupHostingView()
    }
    
    /// Initialize with multiple apps
    init(apps: [OpenAIAppData]) {
        // Use first app for now (multi-app support via container view)
        self.appData = apps.first!
        super.init(frame: .zero)
        ACDiagnosticLogger.log("Initializing hosting view for \(apps.count) apps", category: "Lifecycle")
        setupMultiAppHostingView(apps: apps)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    private func setupHostingView() {
        let swiftUIView = OpenAIAppView(appData: appData) { [weak self] in
            self?.notifyHeightChange()
        }
        
        let hostingController = UIHostingController(rootView: AnyView(swiftUIView))
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Prevent clipping
        hostingController.view.clipsToBounds = false
        self.clipsToBounds = false
        
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set content priorities like ChainOfThought
        hostingController.view.setContentHuggingPriority(.required, for: .vertical)
        hostingController.view.setContentCompressionResistancePriority(.required, for: .vertical)
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.hostingController = hostingController
        
        // Add KVO observer for size changes
        hostingController.view.addObserver(self, forKeyPath: "bounds", options: [.new, .old], context: nil)
        
        // Set initial height
        notifyHeightChange()
    }
    
    private func setupMultiAppHostingView(apps: [OpenAIAppData]) {
        let swiftUIView = OpenAIAppsContainerView(apps: apps) { [weak self] in
            self?.updateHeight()
        }
        
        let hostingController = UIHostingController(rootView: AnyView(swiftUIView))
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.hostingController = hostingController
        updateHeight()
    }
    
    deinit {
        hostingController?.view.removeObserver(self, forKeyPath: "bounds")
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            invalidateIntrinsicContentSize()
            DispatchQueue.main.async { [weak self] in
                self?.notifyHeightChange()
            }
        }
    }
    
    private func notifyHeightChange() {
        let currentHeight = intrinsicContentSize.height
        
        // Only notify if height changed significantly
        guard abs(currentHeight - lastReportedHeight) > 5.0 else { return }
        lastReportedHeight = currentHeight
        
        ACDiagnosticLogger.log("Height changed from \(lastReportedHeight) to \(currentHeight)pt", category: "Rendering")
        
        // Invalidate our intrinsic content size
        invalidateIntrinsicContentSize()
        
        // Update hosting controller
        if let hostingController = self.hostingController {
            hostingController.view.invalidateIntrinsicContentSize()
        }
        
        // Walk up view hierarchy to find and update containers (like ChainOfThought does)
        var view: UIView? = self.superview
        while view != nil {
            let className = NSStringFromClass(type(of: view!))
            
            if className.contains("ACRContentStackView") {
                ACDiagnosticLogger.log("Found ACRContentStackView, updating layout", category: "Rendering")
                view?.invalidateIntrinsicContentSize()
                view?.setNeedsLayout()
                view?.layoutIfNeeded()
                view?.superview?.invalidateIntrinsicContentSize()
                view?.superview?.setNeedsLayout()
                break
            } else if className.contains("UIStackView") {
                view?.invalidateIntrinsicContentSize()
                view?.setNeedsLayout()
                view?.layoutIfNeeded()
            } else if let tableView = view as? UITableView {
                ACDiagnosticLogger.log("Found UITableView, calling beginUpdates/endUpdates", category: "Rendering")
                tableView.beginUpdates()
                tableView.endUpdates()
                break
            } else if let scrollView = view as? UIScrollView {
                scrollView.invalidateIntrinsicContentSize()
                scrollView.setNeedsLayout()
                scrollView.layoutIfNeeded()
            }
            
            view = view?.superview
        }
        
        // Force complete layout update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
    
    private func updateHeight() {
        // Legacy method - redirect to notifyHeightChange
        notifyHeightChange()
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let hostingController = hostingController else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        // Get the current width constraint
        let targetWidth = bounds.width > 0 ? bounds.width : 374.0 // Reasonable default
        
        // Create a temporary size to measure the content
        let tempSize = CGSize(width: targetWidth, height: 1000) // Reasonable max height
        
        // Measure the SwiftUI content
        let measuredSize = hostingController.sizeThatFits(in: tempSize)
        
        // Clamp the height to reasonable bounds
        let clampedHeight = min(max(measuredSize.height, 50), 800) // Between 50 and 800 points
        
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: clampedHeight
        )
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        guard let hostingController = hostingController else {
            return CGSize(width: targetSize.width, height: 50)
        }
        
        let constrainedSize = CGSize(
            width: targetSize.width,
            height: min(targetSize.height, 1000)
        )
        
        let measuredSize = hostingController.sizeThatFits(in: constrainedSize)
        let clampedHeight = min(max(measuredSize.height, 50), 800)
        
        return CGSize(
            width: targetSize.width,
            height: clampedHeight
        )
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return systemLayoutSizeFitting(targetSize)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return systemLayoutSizeFitting(size)
    }
}

// MARK: - Factory Methods

@available(iOS 15.0, *)
extension OpenAIAppHostingView {
    
    /// Create hosting view from ACOAdaptiveCard
    /// Returns nil if card doesn't contain OpenAI app data
    public static func createFromCard(_ card: ACOAdaptiveCard) -> UIView? {
        guard let appsContainer = card.parseOpenAIApps() else {
            print("⚠️ OpenAIAppHostingView: No OpenAI app data found in card")
            return nil
        }
        
        if appsContainer.count == 1, let app = appsContainer.app(at: 0) {
            print("✅ OpenAIAppHostingView: Creating single app view - \(app.appName)")
            return OpenAIAppHostingView(appData: app)
        } else {
            print("✅ OpenAIAppHostingView: Creating multi-app view - \(appsContainer.count) apps")
            return OpenAIAppHostingView(apps: appsContainer.apps)
        }
    }
    
    /// Create hosting view from OpenAIAppData
    public static func createFromAppData(_ appData: OpenAIAppData) -> UIView {
        return OpenAIAppHostingView(appData: appData)
    }
    
    /// Create hosting view from multiple apps
    public static func createFromApps(_ apps: [OpenAIAppData]) -> UIView {
        return OpenAIAppHostingView(apps: apps)
    }
    
    /// Check if card contains OpenAI app data
    public static func cardHasOpenAIApps(_ card: ACOAdaptiveCard) -> Bool {
        return card.hasOpenAIApps()
    }
}

// MARK: - Helper Extensions

@available(iOS 15.0, *)
extension OpenAIAppHostingView {
    
    /// Get the underlying SwiftUI view (for debugging)
    var swiftUIView: UIHostingController<AnyView>? {
        return hostingController
    }
    
    /// Force refresh the view
    @objc public func refresh() {
        updateHeight()
    }
}

// MARK: - Factory for Objective-C Integration

/// Factory class for creating OpenAI App views from text content
/// This follows the same pattern as ChainOfThoughtViewFactory and StreamingViewFactory
/// OpenAI app data is embedded in TextBlock content as JSON
@objc(OpenAIAppViewFactory)
public class OpenAIAppViewFactory: NSObject {
    
    /// Creates an OpenAI App hosting view from text content containing JSON
    /// Returns nil if the text doesn't contain valid OpenAI app data
    /// Expected format: {"openAIApp": {...}} or {"openAIApps": [{...}]}
    @objc public static func createOpenAIAppViewFromTextContent(_ textContent: String) -> UIView? {
        ACDiagnosticLogger.log("Factory called with text content", category: "OpenAIApp")
        
        guard #available(iOS 15.0, *) else {
            ACDiagnosticLogger.log("iOS 15.0+ required, current version unsupported", category: "Error")
            return nil
        }
        
        guard let data = textContent.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            ACDiagnosticLogger.log("Failed to parse JSON from text content", category: "Error")
            return nil
        }
        
        ACDiagnosticLogger.log("Successfully parsed JSON, looking for app data", category: "Parsing")
        
        var apps: [OpenAIAppData] = []
        
        // Try parsing single app
        if let singleAppDict = json["openAIApp"] as? [String: Any],
           let app = OpenAIAppData.parse(from: singleAppDict) {
            ACDiagnosticLogger.log("Parsed single app: \(app.appName) (\(app.appId))", category: "OpenAIApp")
            apps.append(app)
        }
        
        // Try parsing multiple apps
        if let appsArray = json["openAIApps"] as? [[String: Any]] {
            let parsedApps = appsArray.compactMap { OpenAIAppData.parse(from: $0) }
            ACDiagnosticLogger.log("Parsed \(parsedApps.count) apps from array", category: "OpenAIApp")
            apps.append(contentsOf: parsedApps)
        }
        
        guard !apps.isEmpty else {
            ACDiagnosticLogger.log("No valid app data found in JSON", category: "Warning")
            return nil
        }
        
        if apps.count == 1 {
            ACDiagnosticLogger.log("Creating single app view: \(apps[0].appName)", category: "Success")
            return OpenAIAppHostingView(appData: apps[0])
        } else {
            ACDiagnosticLogger.log("Creating multi-app view with \(apps.count) apps", category: "Success")
            return OpenAIAppHostingView(apps: apps)
        }
    }
    
    /// Checks if the given text content contains OpenAI app data
    @objc public static func isOpenAIAppContent(_ textContent: String) -> Bool {
        guard let data = textContent.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }
        return json["openAIApp"] != nil || json["openAIApps"] != nil
    }
}
