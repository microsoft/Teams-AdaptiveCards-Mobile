import Foundation

/// Data models for Chain of Thought UX
struct ChainOfThoughtData: Codable {
    let entries: [ChainOfThoughtEntry]
    let state: String
    let isDone: Bool
}

struct ChainOfThoughtEntry: Codable, Identifiable {
    let id = UUID()
    let header: String
    let content: String
    let appInfo: AppInfo?
    
    private enum CodingKeys: String, CodingKey {
        case header, content, appInfo
    }
}

struct AppInfo: Codable {
    let name: String
    let icon: String
}

/// Extension to parse Chain of Thought data from text element content
extension ChainOfThoughtData {
    static func from(textContent: String) -> ChainOfThoughtData? {
        // Clean the text content first - remove any potential HTML entities or encoding issues
        let cleanedText = textContent
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
        
        // Check if it looks like JSON (starts with { and ends with })
        guard cleanedText.hasPrefix("{") && cleanedText.hasSuffix("}") else {
            return nil
        }
        
        guard let data = cleanedText.data(using: .utf8) else { return nil }
        
        do {
            let chainOfThought = try JSONDecoder().decode(ChainOfThoughtData.self, from: data)
            return chainOfThought
        } catch {
            print("Failed to decode Chain of Thought data: \(error)")
            // Try with more aggressive cleaning if first attempt fails
            let leftQuote = "\u{201C}"  // "
            let rightQuote = "\u{201D}" // "
            let leftSingleQuote = "\u{2018}"  // '
            let rightSingleQuote = "\u{2019}" // '
            
            let moreCleanedText = cleanedText
                .replacingOccurrences(of: leftQuote, with: "\"")
                .replacingOccurrences(of: rightQuote, with: "\"")
                .replacingOccurrences(of: leftSingleQuote, with: "'")
                .replacingOccurrences(of: rightSingleQuote, with: "'")
            
            if let retryData = moreCleanedText.data(using: .utf8) {
                do {
                    let chainOfThought = try JSONDecoder().decode(ChainOfThoughtData.self, from: retryData)
                    return chainOfThought
                } catch {
                    print("Failed to decode Chain of Thought data after cleaning: \(error)")
                    return nil
                }
            }
            return nil
        }
    }
}
