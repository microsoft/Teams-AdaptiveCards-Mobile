//
//  SwiftActionElements.swift
//  SwiftAdaptiveCards
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

/// Represents a base action in an Adaptive Card.
/// This class is now decoupled from BaseCardElement.
class SwiftBaseActionElement: SwiftBaseElement, SwiftAdaptiveCardElementProtocol {
    // MARK: - Properties
    let title: String
    let iconUrl: String
    let style: String
    let tooltip: String
    let mode: SwiftMode
    let isEnabled: Bool
    let role: SwiftActionRole?
    
    override var typeString: String {
        get { super.typeString }
        set { super.typeString = newValue }
    }
    
    // MARK: - Initializer
    
    /// Initializes a BaseActionElement using an ActionType.
    /// Default property values are provided so that the synthesized Codable methods can work without additional custom initializers.
    init(type: SwiftActionType,
         id: String? = nil,
         title: String = "",
         iconUrl: String = "",
         style: String = "default",
         tooltip: String = "",
         mode: SwiftMode = .primary,
         isEnabled: Bool = true,
         role: SwiftActionRole? = nil) {
        
        // Compute role if not provided.
        let computedRole: SwiftActionRole? = role ?? (type == .openUrl ? .link : .button)
        self.title = title
        self.iconUrl = iconUrl
        self.style = style
        self.tooltip = tooltip
        self.mode = mode
        self.isEnabled = isEnabled
        self.role = computedRole
        super.init(typeString: type.rawValue, id: id)
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case title, iconUrl, style, tooltip, mode, isEnabled, role
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl) ?? ""
        self.style = try container.decodeIfPresent(String.self, forKey: .style) ?? "default"
        self.tooltip = try container.decodeIfPresent(String.self, forKey: .tooltip) ?? ""
        self.mode = try container.decodeIfPresent(SwiftMode.self, forKey: .mode) ?? .primary
        self.isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.role = try container.decodeIfPresent(SwiftActionRole.self, forKey: .role)
        try super.init(from: decoder)
        
        // Legacy support: Filter out keys already represented by properties.
        if var additional = self.additionalProperties {
            let knownKeys = Set(["title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"])
            additional = additional.filter { !knownKeys.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(iconUrl, forKey: .iconUrl)
        try container.encode(style, forKey: .style)
        try container.encode(tooltip, forKey: .tooltip)
        try container.encode(mode, forKey: .mode)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(role, forKey: .role)
        try super.encode(to: encoder)
    }
    
    // MARK: - JSON Conversion
    
    /// Converts this action into a JSON dictionary.
    override func toJSON() -> [String: Any] {
        var json: [String: Any] = ["type": typeString]
        if let additionalProps = additionalProperties {
            for (key, value) in additionalProps {
                json[key] = value.value
            }
        }
        return json
    }
    
    /// Serializes the action into a JSON object.
    override func serializeToJsonValue() throws -> [String: Any] {
        return toJSON()
    }
}

// Utility extension for debugging (can remain here or be moved if desired).
extension Dictionary where Key == String, Value == Any {
    func debugPrint(label: String) {
        print("\n=== \(label) ===")
        for (key, value) in self {
            print("\(key): \(value)")
        }
        print("================")
    }
}

/// Represents a Submit Action in an Adaptive Card.
class SwiftSubmitAction: SwiftBaseActionElement {
    // MARK: - Properties
    var dataJson: Any?
    var associatedInputs: SwiftAssociatedInputs
    var conditionallyEnabled: Bool
    
    // Known properties to filter out extra keys.
    static let knownProperties: Set<String> = [
        "data", "associatedInputs", "conditionallyEnabled",
        "title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"
    ]
    
    /// Designated initializer.
    init(dataJson: Any? = nil,
         associatedInputs: SwiftAssociatedInputs = .auto,
         conditionallyEnabled: Bool = false,
         title: String? = nil,
         iconUrl: String? = nil,
         style: String? = "default",
         tooltip: String? = nil,
         mode: SwiftMode = .primary,
         isEnabled: Bool = true,
         role: SwiftActionRole? = nil,
         id: String? = nil) {
        self.dataJson = dataJson
        self.associatedInputs = associatedInputs
        self.conditionallyEnabled = conditionallyEnabled
        // Base properties such as title, iconUrl, etc. are assumed to be handled in SwiftBaseActionElement.
        super.init(type: .submit, id: id)
    }
    
    // MARK: - Codable Implementation
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SubmitActionCodingKeys.self)
        
        // Try decoding "data" as a String first; if that fails, try decoding as a dictionary.
        if let dataString = try? container.decode(String.self, forKey: .dataJson) {
            self.dataJson = dataString
        } else if let dataDict = try? container.decode([String: AnyCodable].self, forKey: .dataJson) {
            self.dataJson = dataDict.mapValues { $0.value }
        } else {
            self.dataJson = nil
        }
        
        self.associatedInputs = try container.decodeIfPresent(SwiftAssociatedInputs.self, forKey: .associatedInputs) ?? .auto
        self.conditionallyEnabled = try container.decodeIfPresent(Bool.self, forKey: .conditionallyEnabled) ?? false
        
        try super.init(from: decoder)
        
        // Filter out known keys from additionalProperties.
        if var additional = self.additionalProperties {
            additional = additional.filter { !Self.knownProperties.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: SubmitActionCodingKeys.self)
        
        // Encode dataJson based on its type.
        if let dataJson = self.dataJson {
            if let stringData = dataJson as? String {
                try container.encode(stringData, forKey: .dataJson)
            } else if let dictData = dataJson as? [String: Any] {
                let encodableDict = dictData.mapValues { AnyCodable($0) }
                try container.encode(encodableDict, forKey: .dataJson)
            }
        }
        
        if associatedInputs != .auto {
            try container.encode(associatedInputs, forKey: .associatedInputs)
        }
        try container.encode(conditionallyEnabled, forKey: .conditionallyEnabled)
    }
    
    enum SubmitActionCodingKeys: String, CodingKey {
        case dataJson = "data"
        case associatedInputs
        case conditionallyEnabled
    }
    
    /// Serializes the action into a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        return try SwiftSubmitActionLegacySupport.serializeToJsonValue(self, superResult: super.serializeToJsonValue())
    }
}
 
/// Represents an OpenUrl action element in an adaptive card.
class SwiftOpenUrlAction: SwiftBaseActionElement {
    // MARK: - Properties
    let url: String

    // MARK: - Codable Implementation

    private enum CodingKeys: String, CodingKey {
        case url
    }

    /// Decodes OpenUrlAction-specific properties and then defers to the base class.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        try super.init(from: decoder)
    }

    /// Encodes OpenUrlAction-specific properties after encoding the base properties.
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
    }
}

/// Represents an action that displays a card when triggered.
class SwiftShowCardAction: SwiftBaseActionElement {
    // MARK: - Properties
    var card: SwiftAdaptiveCard?

    // MARK: - Initializers

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.card = try container.decodeIfPresent(SwiftAdaptiveCard.self, forKey: .card)
        try super.init(from: decoder)
        
        // Filter out known keys so that additionalProperties becomes empty if no extra keys were provided.
        if var additional = self.additionalProperties {
            let knownKeys: Set<String> = [
                "card",
                "title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"
            ]
            additional = additional.filter { !knownKeys.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(card, forKey: .card)
        try super.encode(to: encoder)
    }
    // MARK: - Coding Keys

    private enum CodingKeys: String, CodingKey {
        case card = "card"
    }
}

/// Represents an action to toggle visibility of elements in an Adaptive Card.
class SwiftToggleVisibilityAction: SwiftBaseActionElement {
    // MARK: - Properties
    var targetElements: [SwiftToggleVisibilityTarget]
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case targetElements
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targetElements = try container.decodeIfPresent([SwiftToggleVisibilityTarget].self, forKey: .targetElements) ?? []
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !targetElements.isEmpty {
            try container.encode(targetElements, forKey: .targetElements)
        }
    }
}

/// Enum representing visibility states for an element in Adaptive Cards.
enum SwiftIsVisible: String, Codable {
    case toggle = "toggle"
    case visible = "true"
    case hidden = "false"
}

/// Represents a target element for the `ToggleVisibilityAction`.
struct SwiftToggleVisibilityTarget: Codable {
    /// The ID of the target element whose visibility will be toggled.
    let elementId: String
    /// The visibility state of the target element.
    let isVisible: SwiftIsVisible
}


/// Represents the execute action element.
final class SwiftExecuteAction: SwiftBaseActionElement {
    // MARK: - Properties
    var dataJson: [String: AnyCodable]?
    var verb: String
    var associatedInputs: SwiftAssociatedInputs
    var conditionallyEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case dataJson = "data"
        case verb
        case associatedInputs
        case conditionallyEnabled
    }

    // MARK: - Initializers

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.dataJson = try container.decodeIfPresent([String: AnyCodable].self, forKey: .dataJson)
        self.verb = try container.decodeIfPresent(String.self, forKey: .verb) ?? ""
        self.associatedInputs = try container.decodeIfPresent(SwiftAssociatedInputs.self, forKey: .associatedInputs) ?? .auto
        self.conditionallyEnabled = try container.decodeIfPresent(Bool.self, forKey: .conditionallyEnabled) ?? false
        try super.init(from: decoder)
        
        // Filter additionalProperties to remove known keys.
        if var additional = self.additionalProperties {
            let knownKeys: Set<String> = [
                "data", "verb", "associatedInputs", "conditionallyEnabled",
                "title", "iconUrl", "style", "tooltip", "mode", "isEnabled", "role", "type", "id"
            ]
            additional = additional.filter { !knownKeys.contains($0.key) }
            self.additionalProperties = additional.isEmpty ? nil : additional
        }
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(dataJson, forKey: .dataJson)
        try container.encode(verb, forKey: .verb)
        try container.encode(associatedInputs, forKey: .associatedInputs)
        try container.encode(conditionallyEnabled, forKey: .conditionallyEnabled)
    }
}

/// Represents a refresh action in an adaptive card.
struct SwiftRefresh: Codable {
    // MARK: - Properties
    let action: SwiftBaseActionElement?
    let userIds: [String]
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case action, userIds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Deserialize action if present
        if container.contains(.action) {
            let actionDict = try container.decode([String: AnyCodable].self, forKey: .action)
            let dict = actionDict.mapValues { $0.value }
            action = try SwiftBaseActionElement.deserializeAction(from: dict)
        } else {
            action = nil
        }
        
        // Deserialize userIds
        userIds = try container.decodeIfPresent([String].self, forKey: .userIds) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode action if present
        if let action = action {
            try container.encode(AnyCodable(action.toJSON()), forKey: .action)
        }
        
        // Only encode userIds if not empty
        if !userIds.isEmpty {
            try container.encode(userIds, forKey: .userIds)
        }
    }
    
    // MARK: - Initialization with Default Values
    init(action: SwiftBaseActionElement? = nil, userIds: [String] = []) {
        self.action = action
        self.userIds = userIds
    }
    
    // MARK: - Serialization to JSON
    func serializeToJson() -> [String: Any] {
        return SwiftRefreshLegacySupport.serializeToJson(self)
    }
    
    // MARK: - Utility
    var shouldSerialize: Bool {
        return action != nil || !userIds.isEmpty
    }
}

struct SwiftValueChangedAction: Codable {
    // MARK: - Properties
    let targetInputIds: [String]
    let valueChangedActionType: SwiftValueChangedActionType
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case targetInputIds
        case valueChangedActionType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        targetInputIds = try container.decodeIfPresent([String].self, forKey: .targetInputIds) ?? []
        valueChangedActionType = try container.decodeIfPresent(SwiftValueChangedActionType.self, forKey: .valueChangedActionType) ?? .resetInputs
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(targetInputIds, forKey: .targetInputIds)
        try container.encode(valueChangedActionType, forKey: .valueChangedActionType)
    }
}

final class SwiftUnknownAction: SwiftBaseActionElement {
    // Store the original type string from JSON.
    private var originalTypeString: String

    override var typeString: String {
        get {
            // Special handling: if the original type is "Action.Invalid",
            // return the standardized unknown action type.
            if originalTypeString == "Action.Invalid" {
                return SwiftActionType.unknownAction.rawValue
            }
            return originalTypeString
        }
        set { originalTypeString = newValue }
    }
    
    /// Designated initializer.
    init(type: String) {
        self.originalTypeString = type
        super.init(type: .unknownAction)
    }
    
    /// Custom decoder that captures all JSON properties.
    required init(from decoder: Decoder) throws {
        // Use dynamic coding keys to iterate over all keys.
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        
        // Retrieve the original type from the JSON.
        guard let typeKey = container.allKeys.first(where: { $0.stringValue == "type" }),
              let typeString = try? container.decode(String.self, forKey: typeKey) else {
            throw DecodingError.dataCorruptedError(
                forKey: DynamicCodingKeys(stringValue: "type")!,
                in: container,
                debugDescription: "Type is required"
            )
        }
        self.originalTypeString = typeString
        
        // Decode all properties into a dictionary.
        var properties = [String: AnyCodable]()
        for key in container.allKeys {
            properties[key.stringValue] = try container.decode(AnyCodable.self, forKey: key)
        }
        
        super.init(type: .unknownAction)
        self.additionalProperties = properties
    }
    
    /// Encode additional properties using dynamic keys.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        if let additionalProperties = additionalProperties {
            for (key, value) in additionalProperties {
                try container.encode(value, forKey: DynamicCodingKeys(stringValue: key)!)
            }
        }
    }
    
    /// Legacy serialization: returns all captured properties.
    override func serializeToJsonValue() throws -> [String: Any] {
        return additionalProperties?.mapValues { $0.value } ?? [:]
    }
}
