//
//  ACOAdaptiveCard+OpenAIApp.swift
//  AdaptiveCards
//
//  Created on 10/12/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

/// Extension to parse OpenAI App data from Adaptive Card metadata
@available(iOS 15.0, *)
extension ACOAdaptiveCard {
    
    /// Parse OpenAI app configuration from the card's additionalProperty/metadata field
    /// - Returns: OpenAIAppsContainer with parsed apps, or nil if no valid app data found
    @objc public func parseOpenAIApps() -> OpenAIAppsContainer? {
        // Get the additional properties (metadata) from the card
        guard let additionalPropertyData = self.additionalProperty(),
              let jsonObject = try? JSONSerialization.jsonObject(with: additionalPropertyData, options: []),
              let metadata = jsonObject as? [String: Any] else {
            print("⚠️ OpenAI Apps: No additionalProperty found or invalid format")
            return nil
        }
        
        // Parse using the container's static method
        return OpenAIAppsContainer.parse(from: metadata)
    }
    
    /// Check if this card contains OpenAI app data
    @objc public func hasOpenAIApps() -> Bool {
        return parseOpenAIApps() != nil
    }
}

// MARK: - Objective-C Bridge for OpenAIAppsContainer

/// Objective-C compatible wrapper for OpenAI apps container
/// This allows the Objective-C renderer to access the parsed data
@available(iOS 15.0, *)
@objc public class OpenAIAppsContainer: NSObject {
    /// Array of app configurations
    let apps: [OpenAIAppData]
    
    /// Number of apps
    @objc public var count: Int {
        return apps.count
    }
    
    /// Get app at specific index (Swift-only, returns struct)
    public func app(at index: Int) -> OpenAIAppData? {
        guard index >= 0 && index < apps.count else {
            return nil
        }
        return apps[index]
    }
    
    /// Initialize with app array
    init(apps: [OpenAIAppData]) {
        self.apps = apps
        super.init()
    }
    
    /// Parse multiple apps from metadata
    /// Supports both single app ("openAIApp") and multiple apps ("openAIApps")
    @objc public static func parse(from metadata: [String: Any]) -> OpenAIAppsContainer? {
        var parsedApps: [OpenAIAppData] = []
        
        // Try parsing single app first
        if let singleAppDict = metadata["openAIApp"] as? [String: Any],
           let app = OpenAIAppData.parse(from: singleAppDict) {
            parsedApps.append(app)
            print("✅ Parsed single OpenAI app: \(app.appName)")
        }
        
        // Try parsing multiple apps
        if let appsArray = metadata["openAIApps"] as? [[String: Any]] {
            let multipleApps = appsArray.compactMap { OpenAIAppData.parse(from: $0) }
            parsedApps.append(contentsOf: multipleApps)
            print("✅ Parsed \(multipleApps.count) OpenAI apps")
        }
        
        guard !parsedApps.isEmpty else {
            print("⚠️ No valid OpenAI app data found in metadata")
            return nil
        }
        
        return OpenAIAppsContainer(apps: parsedApps)
    }
}

// MARK: - Swift-only conveniences for OpenAIAppData

@available(iOS 15.0, *)
extension OpenAIAppData {
    
    /// Convenience computed properties (Swift-only, structs can't be @objc)
    public var objc_appId: String {
        return appId
    }
    
    public var objc_appName: String {
        return appName
    }
    
    public var objc_appIconUrl: String? {
        return appIconUrl
    }
    
    public var objc_embedUrl: URL {
        return embedUrl
    }
    
    public var objc_authToken: String? {
        return authToken
    }
    
    public var objc_renderMode: String {
        return renderMode.rawValue
    }
    
    public var objc_isInlineMode: Bool {
        return renderMode == .inline
    }
    
    public var objc_isFullscreenMode: Bool {
        return renderMode == .fullscreen
    }
    
    public var objc_isPopupMode: Bool {
        return renderMode == .popup
    }
}
