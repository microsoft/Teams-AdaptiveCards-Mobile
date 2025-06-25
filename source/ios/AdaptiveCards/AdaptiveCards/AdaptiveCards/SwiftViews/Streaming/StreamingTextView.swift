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
    
    // Animation configuration
    private let typingSpeed: TimeInterval = 0.05
    private let charactersPerChunk: Int = 3
    
    // MARK: - Initializers
    
    public init(streamingData: StreamingContent, onHeightChange: (() -> Void)? = nil) {
        self.streamingData = streamingData
        self.onHeightChange = onHeightChange
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Progress indicator for start/informative phases
            if showProgressIndicator {
                progressIndicatorView
            }
            
            // Main text content
            textContentView
            
            // Stop streaming button
            if showStopButton {
                stopStreamingButton
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Fill available width
        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
        .onAppear {
            handleStreamingPhase()
        }
        .onChange(of: streamingData.content) { _ in
            handleContentUpdate()
        }
        .onChange(of: streamingData.phase) { _ in
            handleStreamingPhase()
        }
        .onChange(of: displayedText) { _ in
            // Notify height change when displayed text changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                onHeightChange?()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            // Handle orientation changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onHeightChange?()
            }
        }
    }
    
    // MARK: - View Components
    
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
                // Use a custom text view that properly handles newlines
                MultilineText(text: displayedText)
                    .font(fontForPhase(streamingData.streamingPhase))
                    .foregroundColor(colorForPhase(streamingData.streamingPhase))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Show blinking cursor during streaming
                if isTyping && streamingData.streamingPhase == .streaming {
                    Text("|")
                        .font(fontForPhase(streamingData.streamingPhase))
                        .foregroundColor(colorForPhase(streamingData.streamingPhase))
                        .opacity(isTyping ? 1.0 : 0.0)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: isTyping
                        )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(backgroundForPhase(streamingData.streamingPhase))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColorForPhase(streamingData.streamingPhase), lineWidth: 1)
        )
        .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
    }
    
    @ViewBuilder
    private var stopStreamingButton: some View {
        Button(action: {
            stopStreaming()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                Text("Stop")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.red)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Streaming Logic
    
    private func handleStreamingPhase() {
        guard let phase = streamingData.streamingPhase else { return }
        
        switch phase {
        case .start:
            showProgressIndicator = true
            showStopButton = false
            displayedText = ""
            
        case .informative:
            showProgressIndicator = true
            showStopButton = true
            // Show informative text immediately (no typing effect)
            displayedText = streamingData.content
            
        case .streaming:
            showProgressIndicator = false
            showStopButton = true
            startTypingAnimation()
            
        case .final:
            showProgressIndicator = false
            showStopButton = false
            stopTypingAnimation()
            displayedText = streamingData.content
        }
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
        
        // Add next chunk of characters
        let endIndex = min(currentCharacterIndex + charactersPerChunk, targetText.count)
        let targetEndIndex = targetText.index(targetText.startIndex, offsetBy: endIndex)
        
        displayedText = String(targetText[..<targetEndIndex])
        currentCharacterIndex = endIndex
        
        // Trigger height change notification during typing for better layout updates
        DispatchQueue.main.async {
            onHeightChange?()
        }
    }
    
    private func stopStreaming() {
        // In a real implementation, this would trigger the stop streaming API call
        // For now, we'll just transition to final state
        stopTypingAnimation()
        showStopButton = false
        showProgressIndicator = false
        displayedText = streamingData.content
        
        // TODO: Implement actual stop streaming logic
        print("Stop streaming requested for message: \(streamingData.messageID)")
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

// MARK: - MultilineText Helper

/// Custom text view that properly handles newline characters and multi-line text
@available(iOS 15.0, *)
struct MultilineText: View {
    let text: String
    
    var body: some View {
        // Split text by newlines and render each line separately
        VStack(alignment: .leading, spacing: 4) {
            ForEach(textLines, id: \.self) { line in
                if line.isEmpty {
                    // Empty line - add spacing
                    Text(" ")
                        .font(.caption)
                        .frame(height: 4)
                } else {
                    Text(line)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var textLines: [String] {
        // Split by both \n and \r\n to handle different line endings
        let lines = text.components(separatedBy: .newlines)
        return lines
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
        }
        .padding()
    }
}
