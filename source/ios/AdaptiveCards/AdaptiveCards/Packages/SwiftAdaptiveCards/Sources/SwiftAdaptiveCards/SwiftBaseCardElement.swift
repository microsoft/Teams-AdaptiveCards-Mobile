//
//  SwiftBaseCardElement.swift
//  SwiftAdaptiveCards
//
//  Created by Rahul Pinjani on 9/18/24.
//

import Foundation

/// A protocol that represents an adaptive card element.
/// Both card and action elements must provide these basic properties.
protocol SwiftAdaptiveCardElementProtocol: Codable {
    var typeString: String { get set }
    var id: String? { get set }
}

/// Represents a base element in an Adaptive Card.
class SwiftBaseCardElement: SwiftBaseElement, SwiftAdaptiveCardElementProtocol {
    // MARK: - Properties
    let type: SwiftCardElementType
    var spacing: SwiftSpacing?
    var height: SwiftHeightType?
    var targetWidth: SwiftTargetWidthType?
    var separator: Bool?
    var isVisible: Bool = true
    var areaGridName: String?
    var parentalId: SwiftInternalId?
    
    override var typeString: String {
        get { return type.rawValue }
        set { /* Optionally update type if needed */ }
    }
    
    /// Returns the element type as a CardElementType (or .unknown if it can't be parsed)
    var elementTypeVal: SwiftCardElementType {
        // Use the normal conversion
        let baseType = SwiftCardElementType.fromString(self.typeString) ?? .unknown
        // But if this is a TableRow or TableCell that came in as an orphan, return .unknown.
        if baseType == .tableRow || baseType == .tableCell {
            return .unknown
        }
        return baseType
    }

    // MARK: - Initializers
    init(
        type: SwiftCardElementType,
        spacing: SwiftSpacing? = nil,
        height: SwiftHeightType? = nil,
        targetWidth: SwiftTargetWidthType? = nil,
        separator: Bool? = nil,
        isVisible: Bool = true,
        areaGridName: String? = nil,
        parentalId: SwiftInternalId? = nil,
        id: String? = nil
    ) {
        self.type = type
        self.spacing = spacing
        self.height = height
        self.targetWidth = targetWidth
        self.separator = separator
        self.isVisible = isVisible
        self.areaGridName = areaGridName
        self.parentalId = parentalId
        super.init(typeString: type.rawValue, id: id)
    }

    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case type
        case spacing
        case height
        case targetWidth
        case separator
        case isVisible
        case areaGridName
        case parentalId
    }

    /// Deserializes a BaseCardElement from JSON.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the local properties.
        let typeRaw = try container.decode(String.self, forKey: .type)
        let decodedType: SwiftCardElementType
        
        if typeRaw.hasPrefix("Action.") {
            // For actions, map to a generic type (e.g. .custom)
            decodedType = .custom
        } else if let validType = SwiftCardElementType(rawValue: typeRaw) {
            decodedType = validType
        } else {
            throw AdaptiveCardParseError.invalidType
        }
        
        self.type = decodedType
        self.spacing = try container.decodeIfPresent(String.self, forKey: .spacing).flatMap { SwiftSpacing(rawValue: $0) }
        self.height = try container.decodeIfPresent(String.self, forKey: .height).flatMap { SwiftHeightType(rawValue: $0) }
        self.targetWidth = try container.decodeIfPresent(String.self, forKey: .targetWidth).flatMap { SwiftTargetWidthType(rawValue: $0) }
        self.separator = try container.decodeIfPresent(Bool.self, forKey: .separator)
        self.isVisible = try container.decodeIfPresent(Bool.self, forKey: .isVisible) ?? true
        self.areaGridName = try container.decodeIfPresent(String.self, forKey: .areaGridName)
        self.parentalId = try container.decodeIfPresent(SwiftInternalId.self, forKey: .parentalId)
        
        // Decode the BaseElement properties.
        try super.init(from: decoder)
    }
    
    /// Serializes the BaseCardElement into JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encodeIfPresent(spacing?.rawValue, forKey: .spacing)
        try container.encodeIfPresent(height?.rawValue, forKey: .height)
        try container.encodeIfPresent(targetWidth?.rawValue, forKey: .targetWidth)
        try container.encodeIfPresent(separator, forKey: .separator)
        try container.encode(isVisible, forKey: .isVisible)
        try container.encodeIfPresent(areaGridName, forKey: .areaGridName)
        try container.encodeIfPresent(parentalId, forKey: .parentalId)
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        // Ensure type is set correctly
        json["type"] = typeString
        
        // Add optional properties
        if let spacing = spacing {
            json["spacing"] = spacing.rawValue
        }
        
        if let height = height {
            json["height"] = height.rawValue
        }
        
        if let targetWidth = targetWidth {
            json["targetWidth"] = targetWidth.rawValue
        }
        
        if let separator = separator {
            json["separator"] = separator
        }
        
        if !isVisible {
            json["isVisible"] = isVisible
        }
        
        if let areaGridName = areaGridName {
            json["areaGridName"] = areaGridName
        }
        
        if let parentalId = parentalId {
            json["parentalId"] = parentalId
        }
        
        return json
    }
    
    /// Convenience serialize method that returns a JSON string.
    public func serialize() throws -> String {
        return try SwiftParseUtil.jsonToString(self.serializeToJsonValue())
    }
}
