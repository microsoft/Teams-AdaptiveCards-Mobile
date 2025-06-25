import SwiftUI
import Combine

// MARK: - Streaming Text View

@available(iOS 15.0, *)
public struct StreamingTextView: View {
    let streamingData: StreamingContent
    var onHeightChange: (() -> Void)? = nil
    
    @State private var displayedText: String = ""
    @State private var isTyping: Bool = false
    @State private var showStopButton: Bool = false
    @State private var showProgressIndicator: Bool = false
    @State private var currentCharacterIndex: Int = 0
    @State private var typingTimer: Timer?
    @State private var lastHeightNotification: Date = Date()
    @State private var isPerformanceMode: Bool = false
    @State private var lastCharacterCountForHeightUpdate: Int = 0
    @State private var heightUpdateCounter: Int = 0
    
    // Collapse/Expand state
    @State private var isCollapsed: Bool = false
    
    // Internal streaming state management (separate from streamingData.phase)
    @State private var internalStreamingPhase: StreamingPhase = .start
    @State private var hasBeenManuallyExpanded: Bool = false
    
    // Animation configuration
    private let typingSpeed: TimeInterval = 0.03 // Faster typing speed (30ms per character)
    private let charactersPerChunk: Int = 1 // Single character for proper animation
    
    // Performance optimization constants - VERY conservative
    private let maxHeightNotificationFrequency: TimeInterval = 2.0 // Very infrequent height notifications
    private let longTextThreshold: Int = 50000 // Much higher - disable performance mode
    private let performanceModeChunkSize: Int = 3 // Small chunks in performance mode
    private let veryLongTextThreshold: Int = 100000 // Extremely high threshold
    private let maxHeightNotificationBuffer: Int = 1000 // More characters before notifying height change
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isCollapsed {
                // Collapsed view - shows "thinking" state
                collapsedView
                    .onAppear {
                        print("🟦 COLLAPSED VIEW APPEARED - isCollapsed: \(isCollapsed)")
                        print("🟦 Stream data: messageID=\(streamingData.messageID), phase=\(streamingData.streamingPhase?.rawValue ?? "nil")")
                    }
            } else {
                // Expanded view - shows full streaming content
                expandedView
                    .onAppear {
                        print("🟩 EXPANDED VIEW APPEARED - isCollapsed: \(isCollapsed)")
                    }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            print("🟨 MAIN VIEW APPEARED - About to call handleStreamingPhase()")
            handleStreamingPhase()
        }
        .onChange(of: streamingData.content) { _ in
            handleContentUpdate()
        }
        .onChange(of: streamingData.phase) { _ in
            handleStreamingPhase()
        }
        .onChange(of: displayedText) { _ in
            // Smart height change notifications with logging
            let now = Date()
            let characterDifference = abs(displayedText.count - lastCharacterCountForHeightUpdate)
            let shouldNotify = now.timeIntervalSince(lastHeightNotification) >= maxHeightNotificationFrequency ||
                             characterDifference >= maxHeightNotificationBuffer
            
            if shouldNotify {
                lastHeightNotification = now
                lastCharacterCountForHeightUpdate = displayedText.count
                heightUpdateCounter += 1
                
                print("📏 StreamingTextView: Height update #\(heightUpdateCounter) - Text length: \(displayedText.count), Performance mode: \(isPerformanceMode)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    onHeightChange?()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            // Handle orientation changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onHeightChange?()
            }
        }
        .onChange(of: isCollapsed) { newValue in
            print("🔄 isCollapsed changed to: \(newValue)")
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var collapsedView: some View {
        VStack {
            HStack(spacing: 12) {
                // Thinking animation
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                    }
                }
                
                // Thinking text
                Text("Thinking... (Tap to expand)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Expand icon
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(20)
        }
        .onAppear {
            print("🟦 CollapsedView onAppear called - Creating tap target")
        }
        .onTapGesture {
            print("🚨 BUTTON TAP DETECTED! 🚨")
            print("🔓 Expanding collapsed card - Content length: \(streamingData.content.count)")
            print("🔓 Content preview: '\(streamingData.content.prefix(50))...'")
            print("🔓 Stream phase: \(streamingData.streamingPhase?.rawValue ?? "nil")")
            print("🔓 Current isCollapsed: \(isCollapsed)")
            print("🔓 Current hasBeenManuallyExpanded: \(hasBeenManuallyExpanded)")
            
            withAnimation(.easeInOut(duration: 0.3)) {
                isCollapsed = false
                print("🔓 Setting isCollapsed = false")
            }
            
            // If this was a "start" phase, transition to streaming when expanded
            if streamingData.streamingPhase == .start && !streamingData.content.isEmpty {
                print("🔓 Conditions met for starting animation: phase=start, content not empty")
                hasBeenManuallyExpanded = true
                
                // Start the typing animation after expansion
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    print("🔓 Delayed action executing...")
                    internalStreamingPhase = .streaming
                    showProgressIndicator = false
                    showStopButton = true
                    
                    // Reset the displayed text to ensure clean start
                    displayedText = ""
                    currentCharacterIndex = 0
                    
                    print("🎬 Starting typing animation after manual expansion...")
                    print("🔄 Internal phase changed to: \(internalStreamingPhase.rawValue)")
                    print("🎯 Target content: \(streamingData.content.prefix(50))...")
                    print("🔄 Reset state - displayedText: '\(displayedText)', currentCharacterIndex: \(currentCharacterIndex)")
                    
                    startTypingAnimation()
                }
            } else {
                print("🔓 Conditions NOT met - phase: \(streamingData.streamingPhase?.rawValue ?? "nil"), content empty: \(streamingData.content.isEmpty)")
            }
            
            // Trigger height update when expanding
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                onHeightChange?()
            }
        }
        .background(Color.red.opacity(0.1)) // Temporary debug background
        .border(Color.red, width: 2) // Temporary debug border
    }
    
    @ViewBuilder
    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with collapse button
            HStack {
                Text("AI Assistant")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isCollapsed = true
                    }
                    // Trigger height update when collapsing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        onHeightChange?()
                    }
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Progress indicator for start/informative phases
            if showProgressIndicator {
                progressIndicatorView
                    .padding(.horizontal, 16)
            }
            
            // Main text content
            textContentView
            
            // Stop streaming button
            if showStopButton {
                stopStreamingButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var progressIndicatorView: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .scaleEffect(showProgressIndicator ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: showProgressIndicator
                    )
                    .padding(.horizontal, 2)
            }
        }
        .frame(height: 20)
    }
    
    @ViewBuilder
    private var textContentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                // Use performance-optimized text view for long content
                PerformantMultilineText(text: displayedText, isLongText: isPerformanceMode)
                    .font(fontForPhase(currentEffectivePhase()))
                    .foregroundColor(colorForPhase(currentEffectivePhase()))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onAppear {
                        print("📱 TextContentView appeared - displayedText: '\(displayedText.prefix(30))...' (length: \(displayedText.count))")
                        print("📱 Current effective phase: \(currentEffectivePhase().rawValue)")
                        print("📱 isTyping: \(isTyping)")
                    }
                    .onChange(of: displayedText) { newText in
                        if newText.count <= 20 { // Only log for first few characters
                            print("📝 displayedText changed to: '\(newText)' (length: \(newText.count))")
                        }
                    }
                
                // Show blinking cursor during streaming (use internal phase)
                if isTyping && currentEffectivePhase() == .streaming {
                    Text("|")
                        .font(fontForPhase(currentEffectivePhase()))
                        .foregroundColor(colorForPhase(currentEffectivePhase()))
                        .opacity(isTyping ? 1.0 : 0.0)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: isTyping
                        )
                        .onAppear {
                            print("👁️ Cursor appeared - isTyping: \(isTyping), phase: \(currentEffectivePhase().rawValue)")
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundForPhase(currentEffectivePhase()))
        .cornerRadius(12)
        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
    }
    
    @ViewBuilder
    private var stopStreamingButton: some View {
        Button(action: {
            stopStreaming()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                Text("Stop")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.red)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Streaming Logic
    
    private func handleStreamingPhase() {
        print("🚨 handleStreamingPhase() called")
        print("🚨 streamingData.streamingPhase: \(streamingData.streamingPhase?.rawValue ?? "nil")")
        
        guard let phase = streamingData.streamingPhase else { 
            print("❌ No streaming phase found, returning early")
            return 
        }
        
        // Initialize internal phase if not manually managed
        if !hasBeenManuallyExpanded {
            internalStreamingPhase = phase
            print("🔄 Set internalStreamingPhase to: \(internalStreamingPhase.rawValue)")
        }
        
        // Check if we should enable performance mode for long text
        let oldPerformanceMode = isPerformanceMode
        isPerformanceMode = streamingData.content.count > longTextThreshold
        
        if oldPerformanceMode != isPerformanceMode {
            print("🚀 StreamingTextView: Performance mode \(isPerformanceMode ? "ENABLED" : "DISABLED") - Content length: \(streamingData.content.count)")
        }
        
        print("📋 StreamingTextView: Phase changed to \(phase.rawValue) - Content length: \(streamingData.content.count)")
        print("🔄 Internal phase: \(internalStreamingPhase.rawValue), Manual expansion: \(hasBeenManuallyExpanded)")
        print("🔄 Current isCollapsed: \(isCollapsed)")
        
        switch phase {
        case .start:
            print("🟦 Processing .start phase")
            showProgressIndicator = true
            showStopButton = false
            displayedText = ""
            // Start in collapsed state
            isCollapsed = true
            print("🟦 Set isCollapsed = true for start phase")
            
        case .informative:
            showProgressIndicator = true
            showStopButton = true
            // Show informative text immediately (no typing effect)
            displayedText = streamingData.content
            // Expand to show informative content
            withAnimation(.easeInOut(duration: 0.3)) {
                isCollapsed = false
            }
            
        case .streaming:
            showProgressIndicator = false
            showStopButton = true
            // Expand to show streaming content
            withAnimation(.easeInOut(duration: 0.3)) {
                isCollapsed = false
            }
            startTypingAnimation()
            
        case .final:
            showProgressIndicator = false
            showStopButton = false
            stopTypingAnimation()
            displayedText = streamingData.content
            // Keep expanded to show final content
            // Force height update for final content
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                forceHeightUpdate()
            }
        }
    }
    
    // Helper function to get the current effective phase for styling
    private func currentEffectivePhase() -> StreamingPhase {
        return hasBeenManuallyExpanded ? internalStreamingPhase : (streamingData.streamingPhase ?? .start)
    }
    
    private func handleContentUpdate() {
        guard let phase = streamingData.streamingPhase else { return }
        
        switch phase {
        case .informative:
            // Update informative text immediately
            displayedText = streamingData.content
            
        case .streaming:
            // Handle streaming content update
            if streamingData.content.count > displayedText.count {
                // New content to stream
                if !isTyping {
                    startTypingAnimation()
                }
            }
            
        case .final:
            // Show final content immediately
            stopTypingAnimation()
            displayedText = streamingData.content
            // Force height update for final content
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                forceHeightUpdate()
            }
            
        default:
            break
        }
    }
    
    private func startTypingAnimation() {
        guard !isTyping else { return }
        
        isTyping = true
        currentCharacterIndex = displayedText.count
        
        typingTimer = Timer.scheduledTimer(withTimeInterval: typingSpeed, repeats: true) { _ in
            updateDisplayedText()
        }
    }
    
    private func stopTypingAnimation() {
        isTyping = false
        typingTimer?.invalidate()
        typingTimer = nil
    }
    
    private func updateDisplayedText() {
        let targetText = streamingData.content
        
        guard currentCharacterIndex < targetText.count else {
            // Finished typing current content
            print("⏹️ StreamingTextView: Finished typing at \(currentCharacterIndex) characters")
            if streamingData.streamingPhase == .final {
                stopTypingAnimation()
            } else {
                // Pause animation but keep ready for more content
                isTyping = false
                typingTimer?.invalidate()
                typingTimer = nil
            }
            return
        }
        
        // Use larger chunks for very long text to improve performance
        let chunkSize: Int
        if targetText.count > veryLongTextThreshold {
            chunkSize = performanceModeChunkSize * 2 // Even larger chunks for very long text
        } else if isPerformanceMode {
            chunkSize = performanceModeChunkSize
        } else {
            chunkSize = charactersPerChunk
        }
        
        // Add next chunk of characters - optimized for long strings
        let endIndex = min(currentCharacterIndex + chunkSize, targetText.count)
        
        // More efficient string slicing for long text
        if isPerformanceMode {
            // For very long text, avoid expensive string indexing operations
            let utf8View = targetText.utf8
            let startIdx = utf8View.index(utf8View.startIndex, offsetBy: 0)
            let endIdx = utf8View.index(utf8View.startIndex, offsetBy: endIndex)
            displayedText = String(utf8View[startIdx..<endIdx]) ?? String(targetText.prefix(endIndex))
        } else {
            // Standard approach for shorter text
            let targetEndIndex = targetText.index(targetText.startIndex, offsetBy: endIndex)
            displayedText = String(targetText[..<targetEndIndex])
        }
        
        currentCharacterIndex = endIndex
        
        // Log every 1000 characters to track progress
        if currentCharacterIndex % 1000 == 0 {
            print("📝 StreamingTextView: Typed \(currentCharacterIndex)/\(targetText.count) characters")
        }
        
        // Throttled height change notification during typing with smarter logic
        let now = Date()
        let shouldNotifyHeight = targetText.count > veryLongTextThreshold ?
            (currentCharacterIndex % (performanceModeChunkSize * 4) == 0) : // Less frequent for very long text
            (!isPerformanceMode || now.timeIntervalSince(lastHeightNotification) >= maxHeightNotificationFrequency)
        
        if shouldNotifyHeight {
            lastHeightNotification = now
            DispatchQueue.main.async {
                onHeightChange?()
            }
        }
    }
    
    private func stopStreaming() {
        // In a real implementation, this would trigger the stop streaming API call
        // For now, we'll just transition to final state
        print("🛑 StreamingTextView: Stop streaming requested")
        stopTypingAnimation()
        showStopButton = false
        showProgressIndicator = false
        displayedText = streamingData.content
        
        // Force a final height update
        forceHeightUpdate()
        
        // TODO: Implement actual stop streaming logic
        print("Stop streaming requested for message: \(streamingData.messageID)")
    }
    
    private func forceHeightUpdate() {
        print("🔄 StreamingTextView: Forcing height update - Text length: \(displayedText.count)")
        DispatchQueue.main.async {
            onHeightChange?()
        }
        
        // Also try a delayed update in case the first one doesn't work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🔄 StreamingTextView: Delayed height update")
            onHeightChange?()
        }
    }
    
    // MARK: - Style Helpers
    
    private func fontForPhase(_ phase: StreamingPhase?) -> Font {
        switch phase {
        case .informative:
            return .system(size: 16, weight: .semibold)
        case .streaming, .final:
            return .system(size: 16, weight: .regular)
        default:
            return .system(size: 16, weight: .regular)
        }
    }
    
    private func colorForPhase(_ phase: StreamingPhase?) -> Color {
        switch phase {
        case .informative:
            return .blue
        case .streaming:
            return .primary
        case .final:
            return .primary
        default:
            return .primary
        }
    }
    
    private func backgroundForPhase(_ phase: StreamingPhase?) -> Color {
        switch phase {
        case .informative:
            return .blue.opacity(0.1)
        case .streaming:
            return .gray.opacity(0.05)
        case .final:
            return .clear
        default:
            return .clear
        }
    }
    
    private func borderColorForPhase(_ phase: StreamingPhase?) -> Color {
        switch phase {
        case .informative:
            return .blue.opacity(0.3)
        case .streaming:
            return .blue.opacity(0.2)
        default:
            return .clear
        }
    }
}

// MARK: - Performance-Optimized Text Views

/// Custom text view that handles both short and long text efficiently
@available(iOS 15.0, *)
struct PerformantMultilineText: View {
    let text: String
    let isLongText: Bool
    
    var body: some View {
        // Use a single Text view for all cases - simpler and more reliable
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                let mode = isLongText ? "performance" : "standard"
                print("📊 PerformantMultilineText: Using \(mode) mode for text (\(text.count) chars)")
            }
    }
}

// MARK: - Preview

@available(iOS 15.0, *)
struct StreamingTextView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Start phase
            StreamingTextView(streamingData: StreamingContent(
                messageID: "1",
                phase: "start",
                content: "",
                isComplete: false,
                streamEndReason: nil
            ))
            
            // Informative phase
            StreamingTextView(streamingData: StreamingContent(
                messageID: "2", 
                phase: "informative",
                content: "Analyzing your request...",
                isComplete: false,
                streamEndReason: nil
            ))
            
            // Streaming phase with multi-line content
            StreamingTextView(streamingData: StreamingContent(
                messageID: "3",
                phase: "streaming", 
                content: "This is a streaming message that will appear character by character.\n\nIt includes multiple lines and paragraphs.\n\n• Bullet points\n• Multiple items\n• Properly formatted\n\nTo demonstrate the multi-line streaming effect.",
                isComplete: false,
                streamEndReason: nil
            ))
            
            // Final phase
            StreamingTextView(streamingData: StreamingContent(
                messageID: "4",
                phase: "final",
                content: "This is the final message content that appears immediately.",
                isComplete: true,
                streamEndReason: nil
            ))
            
            // Long text performance test
            StreamingTextView(streamingData: StreamingContent(
                messageID: "5",
                phase: "streaming",
                content: String(repeating: "This is a very long text that will test the performance optimizations. It contains many paragraphs and should remain responsive even when the content becomes extremely long. The system should automatically switch to performance mode when the text exceeds the threshold.\n\n", count: 50),
                isComplete: false,
                streamEndReason: nil
            ))
        }
        .padding()
    }
}
