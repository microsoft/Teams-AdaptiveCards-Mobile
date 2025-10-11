import UIKit
import SwiftUI

/// UIView container that hosts the SwiftUI Streaming view
/// This allows integration with the existing Objective-C Adaptive Card infrastructure
@available(iOS 15.0, *)
@objc(StreamingHostingView)
public class StreamingHostingView: UIView {
    private var hostingController: UIHostingController<StreamingTextView>?
    private let streamingData: StreamingContent
    private var lastReportedHeight: CGFloat = 0
    
    init(streamingData: StreamingContent) {
        self.streamingData = streamingData
        super.init(frame: .zero)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHostingController() {
        let streamingView = StreamingTextView(streamingData: streamingData, onHeightChange: { [weak self] in
            self?.notifyHeightChange()
        })
        let hostingController = UIHostingController(rootView: streamingView)
        
        // Configure hosting controller
        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Prevent clipping
        hostingController.view.clipsToBounds = false
        self.clipsToBounds = false
        
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
        hostingController.view.setContentHuggingPriority(.required, for: .vertical)
        hostingController.view.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Set priority for the hosting view itself
        self.setContentHuggingPriority(.required, for: .vertical)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.hostingController = hostingController
        
        // Add observer for size changes to trigger layout updates
        hostingController.view.addObserver(self, forKeyPath: "bounds", options: [.new, .old], context: nil)
    }
    
    /// Call this method to properly set up the hosting controller with a parent view controller
    @objc public func attachToParentViewController(_ parentViewController: UIViewController) {
        guard let hostingController = self.hostingController else { return }
        
        parentViewController.addChild(hostingController)
        hostingController.didMove(toParent: parentViewController)
    }
    
    /// Call this method when removing the view to clean up the hosting controller
    @objc public func detachFromParentViewController() {
        hostingController?.view.removeObserver(self, forKeyPath: "bounds")
        hostingController?.willMove(toParent: nil)
        hostingController?.removeFromParent()
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            // Immediate size invalidation
            invalidateIntrinsicContentSize()
            
            DispatchQueue.main.async { [weak self] in
                self?.notifyHeightChange()
            }
        }
    }
    
    private func notifyHeightChange() {
        let currentHeight = intrinsicContentSize.height
        
        // Only notify if height actually changed significantly (avoid redundant updates)
        guard abs(currentHeight - lastReportedHeight) > 1.0 else { return }
        lastReportedHeight = currentHeight
        
        // Invalidate our intrinsic content size first
        invalidateIntrinsicContentSize()
        
        // Update the hosting controller's view constraints
        if let hostingController = self.hostingController {
            hostingController.view.invalidateIntrinsicContentSize()
        }
        
        // Notify containers in the hierarchy
        var view: UIView? = self.superview
        while view != nil {
            let className = NSStringFromClass(type(of: view!))
            
            if className.contains("ACRContentStackView") {
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
        
        // Force a complete layout update with more aggressive timing
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
            
            // Additional forced layout for Adaptive Card containers
            var parentView: UIView? = self.superview
            while parentView != nil {
                if NSStringFromClass(type(of: parentView!)).contains("ACR") {
                    parentView?.setNeedsLayout()
                    parentView?.layoutIfNeeded()
                }
                parentView = parentView?.superview
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let hostingController = self.hostingController else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        // Get the current width constraint
        let targetWidth = bounds.width > 0 ? bounds.width : 374.0 // Use a reasonable default
        
        // Create a temporary size to measure the content
        let tempSize = CGSize(width: targetWidth, height: 1000) // Reasonable max height for measurement
        
        // Measure the SwiftUI content
        let measuredSize = hostingController.sizeThatFits(in: tempSize)
        
        // Clamp the height to reasonable bounds
        let clampedHeight = min(max(measuredSize.height, 50), 800) // Between 50 and 800 points
        
        let result = CGSize(
            width: UIView.noIntrinsicMetric,
            height: clampedHeight
        )
        
        return result
    }
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        guard let hostingController = self.hostingController else {
            return CGSize(width: targetSize.width, height: 50)
        }
        
        // Use reasonable constraints for measurement
        let constrainedSize = CGSize(
            width: targetSize.width,
            height: min(targetSize.height, 1000) // Cap at 1000 points
        )
        
        let measuredSize = hostingController.sizeThatFits(in: constrainedSize)
        let clampedHeight = min(max(measuredSize.height, 50), 800)
        
        return CGSize(
            width: targetSize.width,
            height: clampedHeight
        )
    }
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return systemLayoutSizeFitting(targetSize)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return systemLayoutSizeFitting(size)
    }
}

// MARK: - Factory Implementation

@available(iOS 15.0, *)
@objc(StreamingViewFactory)
public class StreamingViewFactory: NSObject {
    
    /// Creates a Streaming hosting view from text content
    /// Returns nil if the text doesn't contain valid Streaming data
    @objc public static func createStreamingView(fromTextContent textContent: String) -> UIView? {
        guard let streamingData = StreamingDataParser.parseStreamingData(from: textContent) else {
            return nil
        }
        
        return StreamingHostingView(streamingData: streamingData)
    }
    
    /// Checks if the given text content contains Streaming data
    @objc public static func isStreamingContent(_ textContent: String) -> Bool {
        return StreamingDataParser.isStreamingContent(textContent)
    }
}

// MARK: - Update Support

@available(iOS 15.0, *)
extension StreamingHostingView {
    
    /// Updates the streaming content with new data
    /// This allows for real-time updates to the streaming state
    public func updateStreamingContent(_ newData: StreamingContent) {
        let streamingView = StreamingTextView(streamingData: newData, onHeightChange: { [weak self] in
            self?.notifyHeightChange()
        })
        hostingController?.rootView = streamingView
        notifyHeightChange()
    }
    
    /// Updates streaming content from JSON string
    /// Returns true if the update was successful
    @objc public func updateFromTextContent(_ textContent: String) -> Bool {
        guard let newData = StreamingDataParser.parseStreamingData(from: textContent) else {
            return false
        }
        updateStreamingContent(newData)
        return true
    }
}
