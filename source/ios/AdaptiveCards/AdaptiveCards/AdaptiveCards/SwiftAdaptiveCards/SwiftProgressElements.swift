//
//  SwiftProgressElements.swift
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 1/21/26.
//  Copyright © 2026 Microsoft. All rights reserved.
//

import Foundation

// MARK: - Badge

/// Represents a Badge element in an Adaptive Card.
/// Badges are used to display short status information with optional icons.
public class SwiftBadge: SwiftBaseCardElement {
    
    // MARK: - Properties
    
    /// The text displayed in the badge.
    public var text: String
    
    /// The icon displayed in the badge (fluent icon name).
    public var badgeIcon: String?
    
    /// The tooltip shown on hover.
    public var tooltip: String?
    
    /// The style of the badge.
    public var badgeStyle: SwiftBadgeStyle
    
    /// The shape of the badge.
    public var shape: SwiftShape
    
    /// The size of the badge.
    public var badgeSize: SwiftBadgeSize
    
    /// The appearance of the badge (filled or tint).
    public var badgeAppearance: SwiftBadgeAppearance
    
    /// The position of the icon relative to the text.
    public var iconPosition: SwiftIconPosition
    
    /// Horizontal alignment of the badge.
    public var horizontalAlignment: SwiftHorizontalAlignment?
    
    // MARK: - Codable Keys
    
    private enum CodingKeys: String, CodingKey {
        case text
        case icon
        case tooltip
        case style
        case shape
        case size
        case appearance
        case iconPosition
        case horizontalAlignment
    }
    
    // MARK: - Initializers
    
    public init(
        text: String = "",
        badgeIcon: String? = nil,
        tooltip: String? = nil,
        badgeStyle: SwiftBadgeStyle = .default,
        shape: SwiftShape = .rounded,
        badgeSize: SwiftBadgeSize = .medium,
        badgeAppearance: SwiftBadgeAppearance = .filled,
        iconPosition: SwiftIconPosition = .before,
        horizontalAlignment: SwiftHorizontalAlignment? = nil,
        id: String? = nil
    ) {
        self.text = text
        self.badgeIcon = badgeIcon
        self.tooltip = tooltip
        self.badgeStyle = badgeStyle
        self.shape = shape
        self.badgeSize = badgeSize
        self.badgeAppearance = badgeAppearance
        self.iconPosition = iconPosition
        self.horizontalAlignment = horizontalAlignment
        super.init(type: .badge, id: id ?? "")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        self.badgeIcon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.tooltip = try container.decodeIfPresent(String.self, forKey: .tooltip)
        
        // Decode style with case insensitive handling
        if let styleString = try container.decodeIfPresent(String.self, forKey: .style) {
            self.badgeStyle = SwiftBadgeStyle.fromString(styleString) ?? .default
        } else {
            self.badgeStyle = .default
        }
        
        // Decode shape
        if let shapeString = try container.decodeIfPresent(String.self, forKey: .shape) {
            self.shape = SwiftShape.fromString(shapeString) ?? .rounded
        } else {
            self.shape = .rounded
        }
        
        // Decode size
        if let sizeString = try container.decodeIfPresent(String.self, forKey: .size) {
            self.badgeSize = SwiftBadgeSize.fromString(sizeString) ?? .medium
        } else {
            self.badgeSize = .medium
        }
        
        // Decode appearance
        if let appearanceString = try container.decodeIfPresent(String.self, forKey: .appearance) {
            self.badgeAppearance = SwiftBadgeAppearance.fromString(appearanceString) ?? .filled
        } else {
            self.badgeAppearance = .filled
        }
        
        // Decode icon position
        if let iconPosString = try container.decodeIfPresent(String.self, forKey: .iconPosition) {
            self.iconPosition = SwiftIconPosition.fromString(iconPosString) ?? .before
        } else {
            self.iconPosition = .before
        }
        
        // Decode horizontal alignment
        if let alignmentString = try container.decodeIfPresent(String.self, forKey: .horizontalAlignment) {
            self.horizontalAlignment = SwiftHorizontalAlignment.caseInsensitiveValue(from: alignmentString)
        } else {
            self.horizontalAlignment = nil
        }
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(badgeIcon, forKey: .icon)
        try container.encodeIfPresent(tooltip, forKey: .tooltip)
        try container.encode(badgeStyle, forKey: .style)
        try container.encode(shape, forKey: .shape)
        try container.encode(badgeSize, forKey: .size)
        try container.encode(badgeAppearance, forKey: .appearance)
        try container.encode(iconPosition, forKey: .iconPosition)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        json["type"] = SwiftCardElementType.badge.rawValue
        json["text"] = text
        
        if let icon = badgeIcon, !icon.isEmpty {
            json["icon"] = icon
        }
        
        if let tooltip = tooltip, !tooltip.isEmpty {
            json["tooltip"] = tooltip
        }
        
        if badgeStyle != .default {
            json["style"] = badgeStyle.rawValue
        }
        
        if shape != .rounded {
            json["shape"] = shape.rawValue
        }
        
        if badgeSize != .medium {
            json["size"] = badgeSize.rawValue
        }
        
        if badgeAppearance != .filled {
            json["appearance"] = badgeAppearance.rawValue
        }
        
        if iconPosition != .before {
            json["iconPosition"] = iconPosition.rawValue
        }
        
        if let alignment = horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        return json
    }
}

// MARK: - ProgressBar

/// Represents a ProgressBar element in an Adaptive Card.
/// Progress bars show completion progress with a linear indicator.
public class SwiftProgressBar: SwiftBaseCardElement {
    
    // MARK: - Properties
    
    /// The color of the progress bar.
    public var color: SwiftProgressBarColor
    
    /// The maximum value of the progress bar.
    public var max: Double
    
    /// The current value of the progress bar. If nil, shows indeterminate state.
    public var value: Double?
    
    /// Horizontal alignment of the progress bar.
    public var horizontalAlignment: SwiftHorizontalAlignment?
    
    // MARK: - Codable Keys
    
    private enum CodingKeys: String, CodingKey {
        case color
        case max
        case value
        case horizontalAlignment
    }
    
    // MARK: - Initializers
    
    public init(
        color: SwiftProgressBarColor = .accent,
        max: Double = 100.0,
        value: Double? = nil,
        horizontalAlignment: SwiftHorizontalAlignment? = nil,
        id: String? = nil
    ) {
        self.color = color
        self.max = max
        self.value = value
        self.horizontalAlignment = horizontalAlignment
        super.init(type: .progressBar, id: id ?? "")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode color
        if let colorString = try container.decodeIfPresent(String.self, forKey: .color) {
            self.color = SwiftProgressBarColor.fromString(colorString) ?? .accent
        } else {
            self.color = .accent
        }
        
        self.max = try container.decodeIfPresent(Double.self, forKey: .max) ?? 100.0
        self.value = try container.decodeIfPresent(Double.self, forKey: .value)
        
        // Decode horizontal alignment
        if let alignmentString = try container.decodeIfPresent(String.self, forKey: .horizontalAlignment) {
            self.horizontalAlignment = SwiftHorizontalAlignment.caseInsensitiveValue(from: alignmentString)
        } else {
            self.horizontalAlignment = nil
        }
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(color, forKey: .color)
        try container.encode(max, forKey: .max)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        json["type"] = SwiftCardElementType.progressBar.rawValue
        
        if color != .accent {
            json["color"] = color.rawValue
        }
        
        if max != 100.0 {
            json["max"] = max
        }
        
        if let value = value {
            json["value"] = value
        }
        
        if let alignment = horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        return json
    }
}

// MARK: - ProgressRing

/// Represents a ProgressRing element in an Adaptive Card.
/// Progress rings show completion progress with a circular indicator.
public class SwiftProgressRing: SwiftBaseCardElement {
    
    // MARK: - Properties
    
    /// The label text displayed with the progress ring.
    public var label: String
    
    /// The position of the label relative to the ring.
    public var labelPosition: SwiftLabelPosition
    
    /// The size of the progress ring.
    public var size: SwiftProgressSize
    
    /// Horizontal alignment of the progress ring.
    public var horizontalAlignment: SwiftHorizontalAlignment?
    
    // MARK: - Codable Keys
    
    private enum CodingKeys: String, CodingKey {
        case label
        case labelPosition
        case size
        case horizontalAlignment
    }
    
    // MARK: - Initializers
    
    public init(
        label: String = "",
        labelPosition: SwiftLabelPosition = .below,
        size: SwiftProgressSize = .medium,
        horizontalAlignment: SwiftHorizontalAlignment? = nil,
        id: String? = nil
    ) {
        self.label = label
        self.labelPosition = labelPosition
        self.size = size
        self.horizontalAlignment = horizontalAlignment
        super.init(type: .progressRing, id: id ?? "")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
        
        // Decode label position
        if let positionString = try container.decodeIfPresent(String.self, forKey: .labelPosition) {
            self.labelPosition = SwiftLabelPosition.fromString(positionString) ?? .below
        } else {
            self.labelPosition = .below
        }
        
        // Decode size
        if let sizeString = try container.decodeIfPresent(String.self, forKey: .size) {
            self.size = SwiftProgressSize.fromString(sizeString) ?? .medium
        } else {
            self.size = .medium
        }
        
        // Decode horizontal alignment
        if let alignmentString = try container.decodeIfPresent(String.self, forKey: .horizontalAlignment) {
            self.horizontalAlignment = SwiftHorizontalAlignment.caseInsensitiveValue(from: alignmentString)
        } else {
            self.horizontalAlignment = nil
        }
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(label, forKey: .label)
        try container.encode(labelPosition, forKey: .labelPosition)
        try container.encode(size, forKey: .size)
        try container.encodeIfPresent(horizontalAlignment, forKey: .horizontalAlignment)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        json["type"] = SwiftCardElementType.progressRing.rawValue
        
        if !label.isEmpty {
            json["label"] = label
        }
        
        if labelPosition != .below {
            json["labelPosition"] = labelPosition.rawValue
        }
        
        if size != .medium {
            json["size"] = size.rawValue
        }
        
        if let alignment = horizontalAlignment {
            json["horizontalAlignment"] = alignment.rawValue
        }
        
        return json
    }
}
