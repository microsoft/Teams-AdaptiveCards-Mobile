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
        hostingController.view.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        hostingController.view.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        
        // Store reference to hosting controller
        self.hostingController = hostingController
        
        // Force initial layout
        setNeedsLayout()
        layoutIfNeeded()
        
        // Notify initial height
        DispatchQueue.main.async { [weak self] in
            self?.notifyHeightChange()
        }
    }
    
    private func notifyHeightChange() {
        // Calculate the intrinsic content size
        let targetSize = CGSize(width: bounds.width > 0 ? bounds.width : UIView.noIntrinsicMetric,
                               height: UIView.noIntrinsicMetric)
        let newSize = hostingController?.view.systemLayoutSizeFitting(targetSize,
                                                                       withHorizontalFittingPriority: .required,
                                                                       verticalFittingPriority: .fittingSizeLevel) ?? .zero
        
        // Only notify if height changed significantly
        if abs(newSize.height - lastReportedHeight) > 1.0 {
            lastReportedHeight = newSize.height
            invalidateIntrinsicContentSize()
            
            // Notify superview of layout change
            if let superview = superview {
                superview.setNeedsLayout()
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let hostingController = hostingController else {
            return CGSize(width: UIView.noIntrinsicMetric, height: 44)
        }
        
        let targetSize = CGSize(width: bounds.width > 0 ? bounds.width : UIView.noIntrinsicMetric,
                               height: UIView.noIntrinsicMetric)
        let size = hostingController.view.systemLayoutSizeFitting(targetSize,
                                                                   withHorizontalFittingPriority: .required,
                                                                   verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: UIView.noIntrinsicMetric, height: max(44, size.height))
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Trigger height recalculation after layout
        DispatchQueue.main.async { [weak self] in
            self?.notifyHeightChange()
        }
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
