import Foundation

// MARK: - Streaming State Models

/// Represents the different phases of streaming
public enum StreamingPhase: String, CaseIterable {
    case start = "start"
    case informative = "informative" 
    case streaming = "streaming"
    case final = "final"
    
    static func from(_ rawValue: String) -> StreamingPhase? {
        return StreamingPhase(rawValue: rawValue.lowercased())
    }
}

/// Model for streaming content and state
public struct StreamingContent: Codable {
    let messageID: String
    let phase: String
    let content: String
    let isComplete: Bool
    let streamEndReason: String?
    let typingSpeed: Double?
    let showStopButton: Bool?
    let showProgressIndicator: Bool?
    
    var streamingPhase: StreamingPhase? {
        return StreamingPhase.from(phase)
    }
    
    init(messageID: String, phase: String, content: String, isComplete: Bool, streamEndReason: String? = nil, typingSpeed: Double? = nil, showStopButton: Bool? = nil, showProgressIndicator: Bool? = nil) {
        self.messageID = messageID
        self.phase = phase
        self.content = content
        self.isComplete = isComplete
        self.streamEndReason = streamEndReason
        self.typingSpeed = typingSpeed
        self.showStopButton = showStopButton
        self.showProgressIndicator = showProgressIndicator
    }
}

// MARK: - Streaming Data Parser

/// Helper class for parsing streaming data from text content
public struct StreamingDataParser {
    
    /// Attempts to parse streaming data from a text string
    /// - Parameter text: The text content to parse
    /// - Returns: StreamingContent if valid streaming data is found, nil otherwise
    public static func parseStreamingData(from text: String) -> StreamingContent? {
        // Check if the text looks like JSON streaming data
        guard text.hasPrefix("{") && text.hasSuffix("}") else {
            return nil
        }
        
        // Try to parse as JSON
        guard let data = text.data(using: .utf8) else {
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            // Check if it has streaming properties
            guard let json = json,
                  json["streamingEnabled"] as? Bool == true,
                  let messageID = json["messageID"] as? String,
                  let phase = json["phase"] as? String,
                  let content = json["content"] as? String else {
                return nil
            }
            
            return StreamingContent(
                messageID: messageID,
                phase: phase,
                content: content,
                isComplete: json["isComplete"] as? Bool ?? false,
                streamEndReason: json["streamEndReason"] as? String,
                typingSpeed: json["typingSpeed"] as? Double,
                showStopButton: json["showStopButton"] as? Bool,
                showProgressIndicator: json["showProgressIndicator"] as? Bool
            )
        } catch {
            return nil
        }
    }
    
    /// Checks if the given text content contains streaming data
    /// - Parameter text: The text content to check
    /// - Returns: true if the text contains valid streaming data
    public static func isStreamingContent(_ text: String) -> Bool {
        return parseStreamingData(from: text) != nil
    }
}

// MARK: - Convenience Extensions

extension StreamingContent {
    /// Create StreamingContent from text content (JSON string) for compatibility
    static func from(textContent: String) -> StreamingContent? {
        return StreamingDataParser.parseStreamingData(from: textContent)
    }
}
