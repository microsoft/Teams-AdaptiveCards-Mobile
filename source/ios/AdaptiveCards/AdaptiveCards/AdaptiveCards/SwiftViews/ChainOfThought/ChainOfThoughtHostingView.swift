import UIKit
import SwiftUI

/// UIView container that hosts the SwiftUI Chain of Thought view
/// This allows integration with the existing Objective-C Adaptive Card infrastructure
@available(iOS 15.0, *)
@objc(ChainOfThoughtHostingView)
public class ChainOfThoughtHostingView: UIView {
    private var hostingController: UIHostingController<ChainOfThoughtView>?
    private let data: ChainOfThoughtData
    
    init(data: ChainOfThoughtData) {
        self.data = data
        super.init(frame: .zero)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHostingController() {
        let chainOfThoughtView = ChainOfThoughtView(data: data)
        let hostingController = UIHostingController(rootView: chainOfThoughtView)
        
        // Configure hosting controller
        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add as child view controller (requires parent view controller)
        addSubview(hostingController.view)
        
        // Setup constraints with proper priorities to avoid conflicts
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set content hugging and compression resistance priorities
        hostingController.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        hostingController.view.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Set priority for the hosting view itself
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.hostingController = hostingController
    }
    
    /// Call this method to properly set up the hosting controller with a parent view controller
    @objc public func attachToParentViewController(_ parentViewController: UIViewController) {
        guard let hostingController = self.hostingController else { return }
        
        parentViewController.addChild(hostingController)
        hostingController.didMove(toParent: parentViewController)
    }
    
    /// Call this method when removing the view to clean up the hosting controller
    @objc public func detachFromParentViewController() {
        hostingController?.willMove(toParent: nil)
        hostingController?.removeFromParent()
    }
    
    override public var intrinsicContentSize: CGSize {
        guard let hostingController = self.hostingController else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        // Force layout if needed
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        
        let size = hostingController.view.intrinsicContentSize
        return CGSize(
            width: size.width == UIView.noIntrinsicMetric ? UIView.noIntrinsicMetric : max(size.width, 200),
            height: size.height == UIView.noIntrinsicMetric ? 150 : max(size.height, 150)
        )
    }
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        guard let hostingController = self.hostingController else {
            return targetSize
        }
        
        return hostingController.view.systemLayoutSizeFitting(targetSize)
    }
}

/// Factory class for creating Chain of Thought views
@objc(ChainOfThoughtViewFactory)
public class ChainOfThoughtViewFactory: NSObject {
    
    /// Creates a Chain of Thought hosting view from text content
    /// Returns nil if the text doesn't contain valid Chain of Thought data
    @objc public static func createChainOfThoughtViewFromTextContent(_ textContent: String) -> UIView? {
        guard #available(iOS 15.0, *) else {
            print("Chain of Thought view requires iOS 15.0 or later")
            return nil
        }
        
        guard let data = ChainOfThoughtData.from(textContent: textContent) else {
            return nil
        }
        
        return ChainOfThoughtHostingView(data: data)
    }
    
    /// Checks if the given text content contains Chain of Thought data
    @objc public static func isChainOfThoughtContent(_ textContent: String) -> Bool {
        return ChainOfThoughtData.from(textContent: textContent) != nil
    }
}