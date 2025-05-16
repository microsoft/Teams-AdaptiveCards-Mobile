import Foundation
/**
 * This class serves as an entry point for integrating SwiftAdaptiveCards
 * into the existing Objective-C framework without using runtime hacks
 * or dynamic loading.
 */
@objc(SwiftAdaptiveCardParserSwift)
public class SwiftAdaptiveCardParserSwift: NSObject {
    
    // Use a static property to track if the Swift parser is enabled
    private static var swiftParserEnabled = false
    
    /**
     * Checks if the Swift parser is enabled
     */
    @objc public static func isSwiftParserEnabled() -> Bool {
        return swiftParserEnabled
    }
    
    /**
     * Enables or disables the Swift parser
     */
    @objc public static func enableSwiftParser(_ enabled: Bool) {
        swiftParserEnabled = enabled
    }
    
    /**
     * Parses an Adaptive Card from JSON string
     */
    @objc public static func parseWithPayload(_ payload: String) -> SwiftAdaptiveCardParseResultSwift? {
        // Create a result object
        let result = SwiftAdaptiveCardParseResultSwift()
        
        do {
            // Parse JSON string into data
            guard let jsonData = payload.data(using: .utf8) else {
                throw NSError(domain: "SwiftAdaptiveCardParser", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"])
            }
            
            // Parse the JSON data into a dictionary
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let jsonDict = jsonObject as? [String: Any] else {
                throw NSError(domain: "SwiftAdaptiveCardParser", code: 1002, userInfo: [NSLocalizedDescriptionKey: "JSON is not a dictionary"])
            }
            
            // In a real implementation, we would deserialize this into a SwiftAdaptiveCard object
            // For now, we're just returning a successful result with sample data
            let parseResult = SwiftParseResult(statusCode: 0, adaptiveCard: nil)
            result.parseResult = parseResult
            result.warnings = []
            
        } catch let error as NSError {
            result.errors = [error]
            result.warnings = []
        }
        
        return result
    }
}
