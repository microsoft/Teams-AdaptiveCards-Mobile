import Foundation

/// Represents an input element in an Adaptive Card. This class inherits from BaseCardElement and adds additional
/// properties specific to input elements.
class SwiftBaseInputElement: SwiftBaseCardElement {
    // MARK: - Properties
    /// The text label for the input element.
    let label: String?
    /// Indicates whether a value is required.
    let isRequired: Bool
    /// The error message to display if the input is invalid.
    let errorMessage: String?
    /// An action to execute when the input's value changes.
    let valueChangedAction: SwiftValueChangedAction?

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case label
        case isRequired
        case errorMessage
        case valueChangedAction
    }

    /// Decodes properties from the given decoder.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        label = try container.decodeIfPresent(String.self, forKey: .label)
        isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired) ?? false
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        valueChangedAction = try container.decodeIfPresent(SwiftValueChangedAction.self, forKey: .valueChangedAction)
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }

    /// Encodes properties into the given encoder.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encodeIfPresent(errorMessage, forKey: .errorMessage)
        try container.encodeIfPresent(valueChangedAction, forKey: .valueChangedAction)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    /// Serializes the BaseInputElement to a JSON dictionary.
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    func populateKnownPropertiesSet() {
        self.knownProperties.insert("label")
        self.knownProperties.insert("isRequired")
        self.knownProperties.insert("errorMessage")
        self.knownProperties.insert("valueChangedAction")
    }
}


/// Represents a toggle input field in an Adaptive Card.
class SwiftToggleInput: SwiftBaseInputElement {
    // MARK: - Properties
    /// The display title for the toggle.
    let title: String?
    
    /// The default value of the toggle.
    let value: String?
    
    /// The value representing an "off" state.
    let valueOff: String
    
    /// The value representing an "on" state.
    let valueOn: String
    
    /// Whether the title should wrap.
    let wrap: Bool

    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case title
        case value
        case valueOff
        case valueOn
        case wrap
    }

    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        title = try container.decodeIfPresent(String.self, forKey: .title)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        valueOff = try container.decodeIfPresent(String.self, forKey: .valueOff) ?? "false"
        valueOn = try container.decodeIfPresent(String.self, forKey: .valueOn) ?? "true"
        wrap = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        
        // Call super's decoding initializer
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }

    /// Encodes a `ToggleInput` to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(value, forKey: .value)
        
        // Only encode non-default values
        if valueOff != "false" {
            try container.encode(valueOff, forKey: .valueOff)
        }
        if valueOn != "true" {
            try container.encode(valueOn, forKey: .valueOn)
        }
        if wrap {
            try container.encode(wrap, forKey: .wrap)
        }
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("title")
        self.knownProperties.insert("value")
        self.knownProperties.insert("valueOff")
        self.knownProperties.insert("valueOn")
        self.knownProperties.insert("wrap")
    }
}

/// Represents a time input field in an Adaptive Card.
class SwiftTimeInput: SwiftBaseInputElement {
    // MARK: - Properties
    let max: String?
    let min: String?
    let placeholder: String?
    let value: String?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case max, min, placeholder, value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        max = try container.decodeIfPresent(String.self, forKey: .max)
        min = try container.decodeIfPresent(String.self, forKey: .min)
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("max")
        self.knownProperties.insert("min")
        self.knownProperties.insert("placeholder")
        self.knownProperties.insert("value")
    }
}

/// Represents a ChoiceSetInput in an Adaptive Card.
class SwiftChoiceSetInput: SwiftBaseInputElement {
    // MARK: - Properties
    let isMultiSelect: Bool
    let choiceSetStyle: SwiftChoiceSetStyle
    let choices: [SwiftChoiceInput]
    let choicesData: SwiftChoicesData?
    let value: String
    let wrap: Bool
    let placeholder: String

    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case isMultiSelect  = "isMultiSelect"
        case choiceSetStyle = "style"
        case choices        = "choices"
        case choicesData    = "choicesData"
        case value          = "value"
        case wrap           = "wrap"
        case placeholder    = "placeholder"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        isMultiSelect  = try container.decodeIfPresent(Bool.self, forKey: .isMultiSelect) ?? false
        choiceSetStyle = try container.decodeIfPresent(SwiftChoiceSetStyle.self, forKey: .choiceSetStyle) ?? .compact
        choices        = try container.decodeIfPresent([SwiftChoiceInput].self, forKey: .choices) ?? []
        choicesData    = try container.decodeIfPresent(SwiftChoicesData.self, forKey: .choicesData)
        value          = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
        wrap           = try container.decodeIfPresent(Bool.self, forKey: .wrap) ?? false
        placeholder    = try container.decodeIfPresent(String.self, forKey: .placeholder) ?? ""
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isMultiSelect, forKey: .isMultiSelect)
        try container.encode(choiceSetStyle, forKey: .choiceSetStyle)
        try container.encode(choices, forKey: .choices)
        try container.encodeIfPresent(choicesData, forKey: .choicesData)
        try container.encode(value, forKey: .value)
        try container.encode(wrap, forKey: .wrap)
        try container.encode(placeholder, forKey: .placeholder)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("isMultiSelect")
        self.knownProperties.insert("style")
        self.knownProperties.insert("choices")
        self.knownProperties.insert("choicesData")
        self.knownProperties.insert("value")
        self.knownProperties.insert("wrap")
        self.knownProperties.insert("placeholder")
    }
}

/// Represents a number input element in an Adaptive Card.
class SwiftNumberInput: SwiftBaseInputElement {
    // MARK: - Properties
    let placeholder: String?
    let value: Double?
    let min: Double?
    let max: Double?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case placeholder, value, min, max
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        
        // For numeric values, we might need to handle both String and Number formats
        if let valueDouble = try? container.decodeIfPresent(Double.self, forKey: .value) {
            value = valueDouble
        } else if let valueString = try? container.decodeIfPresent(String.self, forKey: .value),
                  let valueDouble = Double(valueString) {
            value = valueDouble
        } else {
            value = nil
        }
        
        // Same for min/max
        if let minDouble = try? container.decodeIfPresent(Double.self, forKey: .min) {
            min = minDouble
        } else if let minString = try? container.decodeIfPresent(String.self, forKey: .min),
                  let minDouble = Double(minString) {
            min = minDouble
        } else {
            min = nil
        }
        
        if let maxDouble = try? container.decodeIfPresent(Double.self, forKey: .max) {
            max = maxDouble
        } else if let maxString = try? container.decodeIfPresent(String.self, forKey: .max),
                  let maxDouble = Double(maxString) {
            max = maxDouble
        } else {
            max = nil
        }
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(max, forKey: .max)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("placeholder")
        self.knownProperties.insert("value")
        self.knownProperties.insert("min")
        self.knownProperties.insert("max")
    }
}

/// Represents a text input element in an Adaptive Card.
class SwiftTextInput: SwiftBaseInputElement {
    // MARK: - Properties
    /// Placeholder text displayed when the input is empty.
    let placeholder: String?
    
    /// The default value of the input field.
    let value: String?
    
    /// Whether the input field is multiline.
    let isMultiline: Bool
    
    /// Maximum length of the input field.
    let maxLength: UInt
    
    /// Style of the text input.
    let style: SwiftTextInputStyle?
    
    /// Optional inline action associated with the input.
    let inlineAction: SwiftBaseActionElement?
    
    /// Regular expression for validation.
    let regex: String?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case placeholder, value, isMultiline, maxLength, style, inlineAction, regex
    }
    
    /// Required initializer for decoding.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        isMultiline = try container.decodeIfPresent(Bool.self, forKey: .isMultiline) ?? false
        maxLength = try container.decodeIfPresent(UInt.self, forKey: .maxLength) ?? 0
        style = try container.decodeIfPresent(SwiftTextInputStyle.self, forKey: .style)
        regex = try container.decodeIfPresent(String.self, forKey: .regex)
        
        // Handle inlineAction separately
        if container.contains(.inlineAction) {
            let actionDict = try container.decode([String: AnyCodable].self, forKey: .inlineAction)
            let dict = actionDict.mapValues { $0.value }
            inlineAction = try SwiftBaseActionElement.deserializeAction(from: dict)
        } else {
            inlineAction = nil
        }
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    /// Encodes a `TextInput` to JSON.
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        try container.encode(isMultiline, forKey: .isMultiline)
        try container.encode(maxLength, forKey: .maxLength)
        try container.encodeIfPresent(style, forKey: .style)
        try container.encodeIfPresent(regex, forKey: .regex)
        
        if let action = inlineAction {
            try container.encode(AnyCodable(try action.serializeToJsonValue()), forKey: .inlineAction)
        }
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("placeholder")
        self.knownProperties.insert("value")
        self.knownProperties.insert("isMultiline")
        self.knownProperties.insert("maxLength")
        self.knownProperties.insert("style")
        self.knownProperties.insert("inlineAction")
        self.knownProperties.insert("regex")
    }
}

/// Represents a date input element in an Adaptive Card.
class SwiftDateInput: SwiftBaseInputElement {
    // MARK: - Properties
    let max: String?
    let min: String?
    let placeholder: String?
    let value: String?
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case max, min, placeholder, value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties before super.init
        max = try container.decodeIfPresent(String.self, forKey: .max)
        min = try container.decodeIfPresent(String.self, forKey: .min)
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        value = try container.decodeIfPresent(String.self, forKey: .value)
        
        // Call super.init after initializing all properties
        try super.init(from: decoder)
        
        // Set up known properties
        populateKnownPropertiesSet()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encodeIfPresent(value, forKey: .value)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization to JSON
    override func serializeToJsonValue() throws -> [String: Any] {
        let json = try super.serializeToJsonValue()
        return try serializeToLegacyJsonFormat(superResult: json)
    }
    
    override func populateKnownPropertiesSet() {
        self.knownProperties.insert("max")
        self.knownProperties.insert("min")
        self.knownProperties.insert("placeholder")
        self.knownProperties.insert("value")
    }
}

/// Represents a choice input in an Adaptive Card.
struct SwiftChoiceInput: Codable {
    // MARK: - Properties
    let title: String
    let value: String
}
