//
//  OpenAIAppModels.swift
//  AdaptiveCards
//
//  Created on 10/12/25.
//  Copyright © 2025 Microsoft. All rights reserved.
//

import Foundation

/// Data model representing an OpenAI embedded application configuration
/// Parsed from Adaptive Card metadata field
@available(iOS 15.0, *)
public struct OpenAIAppData {
    /// Unique identifier for the app instance
    let appId: String
    
    /// Display name of the application (e.g., "Figma", "Canva")
    let appName: String
    
    /// Optional URL to app icon for display in collapsed view
    let appIconUrl: String?
    
    /// URL to embed the app content (iframe source)
    let embedUrl: URL
    
    /// Optional authentication token for secure app access
    let authToken: String?
    
    /// Optional initial data/configuration to pass to the app
    let initialData: [String: Any]?
    
    /// Rendering mode for the app
    let renderMode: RenderMode
    
    /// Rendering mode options for OpenAI apps
    enum RenderMode: String, Codable {
        /// Embedded inline within the message bubble
        case inline
        
        /// Floating overlay (picture-in-picture)
        case popup
        
        /// Full screen takeover
        case fullscreen
        
        /// Default mode if not specified
        static let defaultMode: RenderMode = .inline
    }
    
    /// Initialize with all required and optional parameters
    init(
        appId: String,
        appName: String,
        appIconUrl: String? = nil,
        embedUrl: URL,
        authToken: String? = nil,
        initialData: [String: Any]? = nil,
        renderMode: RenderMode = .inline
    ) {
        self.appId = appId
        self.appName = appName
        self.appIconUrl = appIconUrl
        self.embedUrl = embedUrl
        self.authToken = authToken
        self.initialData = initialData
        self.renderMode = renderMode
    }
}

// MARK: - Parsing Extension

@available(iOS 15.0, *)
extension OpenAIAppData {
    /// Parse OpenAIAppData from a dictionary (typically from JSON)
    /// - Parameter dict: Dictionary containing app configuration
    /// - Returns: OpenAIAppData if valid, nil if required fields missing
    static func parse(from dict: [String: Any]) -> OpenAIAppData? {
        // Required fields
        guard let appId = dict["appId"] as? String,
              let appName = dict["appName"] as? String,
              let embedUrlString = dict["embedUrl"] as? String,
              let embedUrl = URL(string: embedUrlString) else {
            print("⚠️ OpenAIAppData: Failed to parse required fields (appId, appName, embedUrl)")
            return nil
        }
        
        // Optional fields
        let appIconUrl = dict["appIconUrl"] as? String
        let authToken = dict["authToken"] as? String
        let initialData = dict["initialData"] as? [String: Any]
        
        // Parse render mode with fallback to default
        let renderMode: RenderMode
        if let modeString = dict["renderMode"] as? String,
           let mode = RenderMode(rawValue: modeString) {
            renderMode = mode
        } else {
            renderMode = .defaultMode
        }
        
        return OpenAIAppData(
            appId: appId,
            appName: appName,
            appIconUrl: appIconUrl,
            embedUrl: embedUrl,
            authToken: authToken,
            initialData: initialData,
            renderMode: renderMode
        )
    }
}

// MARK: - CustomStringConvertible for Debugging

@available(iOS 15.0, *)
extension OpenAIAppData: CustomStringConvertible {
    public var description: String {
        return """
        OpenAIAppData(
            appId: \(appId),
            appName: \(appName),
            embedUrl: \(embedUrl),
            renderMode: \(renderMode.rawValue),
            hasIcon: \(appIconUrl != nil),
            hasAuth: \(authToken != nil),
            hasInitialData: \(initialData != nil)
        )
        """
    }
}

// MARK: - Diagnostic Logger

/// Generic diagnostic logger for AdaptiveCards SDK
/// Logs to both console and a persistent file in simulator/device
/// Usage from Swift: ACDiagnosticLogger.log("Message")
/// Usage from Obj-C: [ACDiagnosticLogger log:@"Message"];
@objc public class ACDiagnosticLogger: NSObject {
    private static var logBuffer: [String] = []
    private static let bufferLock = NSLock()
    private static let maxBufferSize = 10 // Flush every 10 messages
    private static var flushTimer: Timer?
    
    private static let logDirectory: URL = {
        let fileManager = FileManager.default
        // Use app support directory for simulator (works on device too)
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let logDir = appSupport.appendingPathComponent("AdaptiveCardsLogs", isDirectory: true)
        
        // Create directory if needed
        try? fileManager.createDirectory(at: logDir, withIntermediateDirectories: true)
        
        return logDir
    }()
    
    private static let logFile: URL = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "adaptivecards_session_\(timestamp).log"
        return logDirectory.appendingPathComponent(filename)
    }()
    
    /// Log a message to both console and file with optional category
    /// - Parameters:
    ///   - message: The message to log
    ///   - category: Optional category/tag (e.g., "OpenAIApp", "Rendering", "Network")
    ///   - file: Source file (auto-filled)
    ///   - function: Source function (auto-filled)
    ///   - line: Source line (auto-filled)
    @objc public static func log(_ message: String, category: String = "General", file: String = #file, function: String = #function, line: Int = #line) {
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] [\(category)] [\(filename):\(line)] \(function) - \(message)"
        
        // Print to console with emoji prefix based on category
        let emoji = emojiForCategory(category)
        print("\(emoji) AC: \(logMessage)")
        
        // Buffer write to file (reduces I/O overhead)
        bufferLogMessage(logMessage)
    }
    
    /// Objective-C compatible version with category
    @objc(logMessage:category:)
    public static func logObjC(_ message: String, category: String) {
        log(message, category: category)
    }
    
    /// Objective-C compatible version without category (uses "General")
    @objc(logMessage:)
    public static func logObjCSimple(_ message: String) {
        log(message, category: "General")
    }
    
    /// Get the current log file path
    @objc public static func getLogFilePath() -> String {
        return logFile.path
    }
    
    /// Get the log directory path
    @objc public static func getLogDirectory() -> String {
        return logDirectory.path
    }
    
    /// Flush buffered logs immediately
    @objc public static func flush() {
        bufferLock.lock()
        defer { bufferLock.unlock() }
        
        guard !logBuffer.isEmpty else { return }
        
        let batch = logBuffer.joined(separator: "\n") + "\n"
        logBuffer.removeAll()
        
        writeToFileDirectly(batch)
    }
    
    /// List all log files sorted by date (newest first)
    @objc public static func listLogFiles() -> [String] {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: logDirectory.path) else {
            return []
        }
        
        let logFiles = files
            .filter { $0.hasPrefix("adaptivecards_session_") && $0.hasSuffix(".log") }
            .sorted(by: >)
        
        return logFiles.map { logDirectory.appendingPathComponent($0).path }
    }
    
    private static func emojiForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "openaiapp", "openai": return "🤖"
        case "rendering", "render": return "🎨"
        case "network", "http": return "🌐"
        case "parsing", "json": return "📄"
        case "error": return "❌"
        case "warning": return "⚠️"
        case "success": return "✅"
        case "lifecycle": return "🔄"
        default: return "🔵"
        }
    }
    
    private static func bufferLogMessage(_ message: String) {
        bufferLock.lock()
        defer { bufferLock.unlock() }
        
        logBuffer.append(message)
        
        // Flush if buffer is full
        if logBuffer.count >= maxBufferSize {
            let batch = logBuffer.joined(separator: "\n") + "\n"
            logBuffer.removeAll()
            
            // Write async to avoid blocking
            DispatchQueue.global(qos: .utility).async {
                writeToFileDirectly(batch)
            }
        } else {
            // Schedule auto-flush after 2 seconds of inactivity
            flushTimer?.invalidate()
            flushTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                flush()
            }
        }
    }
    
    private static func writeToFileDirectly(_ content: String) {
        guard let data = content.data(using: .utf8) else { return }
        
        if FileManager.default.fileExists(atPath: logFile.path) {
            // Append to existing file
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            // Create new file
            try? data.write(to: logFile)
        }
    }
}
