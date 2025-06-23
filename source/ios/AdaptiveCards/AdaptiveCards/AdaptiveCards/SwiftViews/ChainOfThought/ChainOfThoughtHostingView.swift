import UIKit
import SwiftUI

/// UIView container that hosts the SwiftUI Chain of Thought view
/// This allows integration with the existing Objective-C Adaptive Card infrastructure
@available(iOS 15.0, *)
@objc(ChainOfThoughtHostingView)
public class ChainOfThoughtHostingView: UIView {
    private var hostingController: UIHostingController<ChainOfThoughtView>?
    private let data: ChainOfThoughtData
    private var lastReportedHeight: CGFloat = 0
    
    init(data: ChainOfThoughtData) {
        self.data = data
        super.init(frame: .zero)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHostingController() {
        let chainOfThoughtView = ChainOfThoughtView(data: data) { [weak self] in
            self?.notifyHeightChange()
        }
        let hostingController = UIHostingController(rootView: chainOfThoughtView)
        
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
        guard abs(currentHeight - lastReportedHeight) > 5.0 else { return }
        lastReportedHeight = currentHeight
        
        print("Height changed from \(lastReportedHeight) to \(currentHeight)")
        
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
                print("Found ACRContentStackView: \(className)")
                view?.invalidateIntrinsicContentSize()
                view?.setNeedsLayout()
                view?.layoutIfNeeded()
                view?.superview?.invalidateIntrinsicContentSize()
                view?.superview?.setNeedsLayout()
                break
            } else if className.contains("UIStackView") {
                print("Found UIStackView: \(className)")
                view?.invalidateIntrinsicContentSize()
                view?.setNeedsLayout()
                view?.layoutIfNeeded()
            } else if let tableView = view as? UITableView {
                print("Found UITableView")
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
        
        // Force a complete layout update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self else { return }
            self.superview?.setNeedsLayout()
            self.superview?.layoutIfNeeded()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
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
        
        print("Intrinsic content size calculated: \(result) (measured: \(measuredSize))")
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
    
    private func debugViewHierarchy() {
        print("=== ChainOfThoughtHostingView Debug ===")
        print("Self frame: \(frame)")
        print("Self bounds: \(bounds)")
        print("Intrinsic content size: \(intrinsicContentSize)")
        
        var view: UIView? = self.superview
        var level = 1
        while view != nil && level <= 5 {
            let className = NSStringFromClass(type(of: view!))
            print("Level \(level): \(className) - frame: \(view!.frame) - bounds: \(view!.bounds)")
            view = view?.superview
            level += 1
        }
        print("=====================================")
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