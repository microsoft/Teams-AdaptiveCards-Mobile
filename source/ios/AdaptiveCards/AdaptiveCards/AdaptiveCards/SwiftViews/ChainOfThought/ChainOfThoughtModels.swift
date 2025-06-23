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
        guard let data = textContent.data(using: .utf8) else { return nil }
        
        do {
            let chainOfThought = try JSONDecoder().decode(ChainOfThoughtData.self, from: data)
            return chainOfThought
        } catch {
            print("Failed to decode Chain of Thought data: \(error)")
            return nil
        }
    }
}
