//
//  AdaptiveCardView.swift
//  AdaptiveCardsSwift
//
//  Created on 05/15/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

// Import our helper to get platform-independent types
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Try to import SwiftAdaptiveCards if available
#if canImport(SwiftAdaptiveCards)
import SwiftAdaptiveCards
#endif

#if canImport(AdaptiveCards)
import AdaptiveCards

/// A Swift-native view for rendering Adaptive Cards
@objc(ACRSwiftAdaptiveCardView)
public class AdaptiveCardView: UIKit.UIView {
    
    /// The underlying Objective-C ACRView
    private var acrView: ACRView?
    
    /// The Swift adaptive card model
    private var swiftCard: SwiftAdaptiveCard?
    
    /// Delegate for action handling
    public weak var actionDelegate: AdaptiveCardActionDelegate?
    
    /// Initialize with a Swift adaptive card
    ///
    /// - Parameters:
    ///   - card: The Swift adaptive card to render
    ///   - hostConfig: Optional host configuration for rendering
    ///   - frame: The frame for the view
    @objc public init(card: SwiftAdaptiveCard, hostConfig: Any? = nil, frame: CGRect = .zero) {
        self.swiftCard = card
        super.init(frame: frame)
        setupWithCard(card, hostConfig: hostConfig)
    }
    
    /// Initialize with a JSON string
    ///
    /// - Parameters:
    ///   - jsonString: The JSON string representing an adaptive card
    ///   - hostConfig: Optional host configuration for rendering
    ///   - frame: The frame for the view
    @objc public convenience init(jsonString: String, hostConfig: Any? = nil, frame: CGRect = .zero) {
        let result = AdaptiveCardsAPI.shared.parseCard(fromJSON: jsonString)
        
        switch result {
        case .success(let card):
            self.init(card: card, hostConfig: hostConfig, frame: frame)
        case .failure:
            self.init(frame: frame)
            // Display an error state
            let errorLabel = UIKit.UILabel(frame: self.bounds)
            errorLabel.text = "Error parsing adaptive card"
            errorLabel.textAlignment = .center
            errorLabel.textColor = .red
            self.addSubview(errorLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupWithCard(_ card: SwiftAdaptiveCard, hostConfig: Any?) {
        // In a real implementation, we would:
        // 1. Convert the SwiftAdaptiveCard to an ACOAdaptiveCard
        // 2. Create an ACRView with the ACOAdaptiveCard
        // 3. Add the ACRView as a subview
        
        #if canImport(AdaptiveCards)
        // Placeholder implementation
        let dummyData = Data() // This would be actual JSON data
        if let acoCard = ACOAdaptiveCard.fromJson(dummyData) {
            let config = hostConfig as? ACOHostConfig ?? ACOHostConfig()
            self.acrView = ACRRenderer.render(acoCard, config: config, width: self.bounds.width)
            
            if let acrView = self.acrView {
                self.addSubview(acrView)
                acrView.frame = self.bounds
                acrView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        }
        #endif
    }
    
    /// Updates the rendered card with new data
    @objc public func update(with card: SwiftAdaptiveCard) {
        self.swiftCard = card
        setupWithCard(card, hostConfig: nil)
    }
}

/// Protocol for handling adaptive card actions
public protocol AdaptiveCardActionDelegate: AnyObject {
    /// Called when an action is executed on the card
    func adaptiveCardView(_ cardView: AdaptiveCardView, didExecuteAction actionData: [String: Any])
}
#endif
