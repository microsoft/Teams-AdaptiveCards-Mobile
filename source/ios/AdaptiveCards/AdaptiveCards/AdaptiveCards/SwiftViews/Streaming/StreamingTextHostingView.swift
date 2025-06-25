import UIKit
import SwiftUI
import Foundation

/// UIView container that hosts the SwiftUI StreamingTextView
/// This allows integration with the existing Objective-C Adaptive Card infrastructure
@available(iOS 15.0, *)
@objc(StreamingTextHostingView)
public class StreamingTextHostingView: UIView {
    private var hostingController: UIHostingController<StreamingTextView>?
    private let streamingData: StreamingContent
    private var lastReportedHeight: CGFloat = 0
    private var heightUpdateCount = 0
    private var lastHeightChangeTime = Date()
    
    init(streamingData: StreamingContent) {
        self.streamingData = streamingData
        super.init(frame: .zero)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHostingController() {
        let streamingView = StreamingTextView(streamingData: streamingData) { [weak self] in
            self?.notifyHeightChange()
        }
        let hostingController = UIHostingController(rootView: streamingView)
        
        // Configure hosting controller
        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Prevent clipping
        hostingController.view.clipsToBounds = false
        self.clipsToBounds = false
        
        // Add as child view
        addSubview(hostingController.view)
        
        // Setup constraints with proper priorities to avoid conflicts
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set content hugging and compression resistance priorities
        hostingController.view.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        hostingController.view.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        
        // Set priority for the hosting view itself
        self.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        
        self.hostingController = hostingController
        
        // Add observer for size changes to trigger layout updates
        hostingController.view.addObserver(self, forKeyPath: "bounds", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
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
        guard abs(currentHeight - lastReportedHeight) > 10.0 else { return } // Increased threshold
        
        // Throttle notifications to avoid excessive updates
        let now = Date()
        guard now.timeIntervalSince(lastHeightChangeTime) >= 0.15 else { return } // Slower rate
        
        heightUpdateCount += 1
        let previousHeight = lastReportedHeight
        lastReportedHeight = currentHeight
        lastHeightChangeTime = now
        
        if heightUpdateCount % 3 == 0 { // Log every 3rd update to reduce noise
            print("🔄 StreamingTextHostingView: Height update #\(heightUpdateCount) - \(previousHeight) → \(currentHeight)")
        }
        
        // Invalidate our intrinsic content size first
        invalidateIntrinsicContentSize()
        
        // Update the hosting controller's view constraints
        if let hostingController = self.hostingController {
            hostingController.view.invalidateIntrinsicContentSize()
        }
        
        // Find and update table view with multiple strategies
        var view: UIView? = self.superview
        var foundTableView = false
        var tableViewCells: [UITableViewCell] = []
        
        while view != nil {
            let className = NSStringFromClass(type(of: view!))
            print("🔍 StreamingTextHostingView: Checking parent view: \(className)")
            
            // Collect table view cells along the way
            if let cell = view as? UITableViewCell {
                tableViewCells.append(cell)
                print("📱 StreamingTextHostingView: Found UITableViewCell")
            }
            
            if className.contains("ACRContentStackView") {
                print("📦 StreamingTextHostingView: Found ACRContentStackView, invalidating layout")
                view?.invalidateIntrinsicContentSize()
                view?.setNeedsLayout()
                view?.layoutIfNeeded()
                view?.superview?.invalidateIntrinsicContentSize()
                view?.superview?.setNeedsLayout()
                
                // Continue searching for table view
            } else if className.contains("UIStackView") {
                view?.invalidateIntrinsicContentSize()
                view?.setNeedsLayout()
                view?.layoutIfNeeded()
            } else if let tableView = view as? UITableView {
                print("📋 StreamingTextHostingView: Found UITableView, triggering updates")
                foundTableView = true
                
                // Multiple strategies for table view updates
                DispatchQueue.main.async {
                    // Strategy 1: beginUpdates/endUpdates
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                
                // Strategy 2: If we have specific cells, reload them
                if !tableViewCells.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        for cell in tableViewCells {
                            if let indexPath = tableView.indexPath(for: cell) {
                                print("🔄 StreamingTextHostingView: Reloading cell at indexPath: \(indexPath)")
                                tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    }
                }
                
                // Strategy 3: Force layout update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    tableView.setNeedsLayout()
                    tableView.layoutIfNeeded()
                }
                
                break
            } else if let scrollView = view as? UIScrollView {
                scrollView.invalidateIntrinsicContentSize()
                scrollView.setNeedsLayout()
                scrollView.layoutIfNeeded()
            }
            
            view = view?.superview
        }
        
        if !foundTableView {
            print("⚠️ StreamingTextHostingView: No UITableView found in hierarchy - using fallback layout update")
        }
        
        // Force a complete layout update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        guard let hostingController = self.hostingController else {
            print("📐 StreamingTextHostingView: No hosting controller, returning no intrinsic metric")
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        // Get the current width constraint
        let targetWidth = bounds.width > 0 ? bounds.width : 374.0 // Use a reasonable default
        
        // Create a temporary size to measure the content - removed artificial height limit
        let tempSize = CGSize(width: targetWidth, height: CGFloat.greatestFiniteMagnitude)
        
        // Measure the SwiftUI content
        let measuredSize = hostingController.sizeThatFits(in: tempSize)
        
        // Only enforce a minimum height, no maximum to prevent clipping
        let clampedHeight = max(measuredSize.height, 50)
        
        let result = CGSize(
            width: UIView.noIntrinsicMetric,
            height: clampedHeight
        )
        
        print("📐 StreamingTextHostingView: intrinsicContentSize calculated - width: \(targetWidth), measured: \(measuredSize), result: \(result)")
        return result
    }
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        guard let hostingController = self.hostingController else {
            return CGSize(width: targetSize.width, height: 50)
        }
        
        // Use unconstrained height for measurement
        let constrainedSize = CGSize(
            width: targetSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        let measuredSize = hostingController.sizeThatFits(in: constrainedSize)
        let clampedHeight = max(measuredSize.height, 50)
        
        let result = CGSize(
            width: targetSize.width,
            height: clampedHeight
        )
        
        print("📐 StreamingTextHostingView: systemLayoutSizeFitting = \(result)")
        return result
    }
    
    override public func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return systemLayoutSizeFitting(targetSize)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return systemLayoutSizeFitting(size)
    }
}

/// Factory class for creating Streaming Text views
@objc(StreamingTextViewFactory)
public class StreamingTextViewFactory: NSObject {
    
    /// Creates a Streaming Text hosting view from text content
    /// Returns nil if the text doesn't contain valid streaming data
    @objc public static func createStreamingTextViewFromTextContent(_ textContent: String) -> UIView? {
        guard #available(iOS 15.0, *) else {
            print("Streaming Text view requires iOS 15.0 or later")
            return nil
        }
        
        guard let data = StreamingDataParser.parseStreamingData(from: textContent) else {
            return nil
        }
        
        return StreamingTextHostingView(streamingData: data)
    }
    
    /// Checks if the given text content contains streaming data
    @objc public static func isStreamingTextContent(_ textContent: String) -> Bool {
        return StreamingDataParser.isStreamingContent(textContent)
    }
}
