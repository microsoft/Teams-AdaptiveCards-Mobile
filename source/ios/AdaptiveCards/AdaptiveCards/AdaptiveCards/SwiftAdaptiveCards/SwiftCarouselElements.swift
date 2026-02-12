//
//  SwiftCarouselElements.swift
//  AdaptiveCards
//
//  Created by Hugo Gonzalez on 1/21/26.
//  Copyright © 2026 Microsoft. All rights reserved.
//

import Foundation

// MARK: - CarouselPage

/// Represents a CarouselPage element in an Adaptive Card.
/// CarouselPage is a styled collection element that contains items for a single page of a carousel.
public class SwiftCarouselPage: SwiftStyledCollectionElement, SwiftCollectionCoreElement {
    
    // MARK: - Properties
    
    /// The items contained within this carousel page.
    var items: [SwiftBaseCardElement]
    
    /// Layout configurations for the carousel page.
    var layouts: [SwiftLayout]
    
    /// Right-to-left text direction.
    public var rtl: Bool?
    
    // MARK: - Codable Keys
    
    private enum CodingKeys: String, CodingKey {
        case items
        case layouts
        case rtl
    }
    
    // MARK: - Initializers
    
    init(
        items: [SwiftBaseCardElement] = [],
        layouts: [SwiftLayout] = [],
        rtl: Bool? = nil,
        style: SwiftContainerStyle = .none,
        verticalContentAlignment: SwiftVerticalContentAlignment? = nil,
        minHeight: UInt = 0,
        bleed: Bool = false,
        backgroundImage: SwiftBackgroundImage? = nil,
        selectAction: SwiftBaseActionElement? = nil,
        id: String? = nil
    ) {
        self.items = items
        self.layouts = layouts
        self.rtl = rtl
        super.init(
            type: .carouselPage,
            style: style,
            verticalContentAlignment: verticalContentAlignment,
            minHeight: minHeight,
            hasBleed: bleed,
            backgroundImage: backgroundImage,
            selectAction: selectAction,
            id: id
        )
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode items using raw JSON and factory method
        if let rawItems = try container.decodeIfPresent([[String: SwiftAnyCodable]].self, forKey: .items) {
            self.items = try rawItems.map { rawElement in
                let dict = rawElement.mapValues { $0.value }
                return try SwiftBaseCardElement.deserialize(from: dict)
            }
        } else {
            self.items = []
        }
        
        self.layouts = try container.decodeIfPresent([SwiftLayout].self, forKey: .layouts) ?? []
        self.rtl = try container.decodeIfPresent(Bool.self, forKey: .rtl)
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(items, forKey: .items)
        if !layouts.isEmpty {
            try container.encode(layouts, forKey: .layouts)
        }
        try container.encodeIfPresent(rtl, forKey: .rtl)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        json["type"] = SwiftCardElementType.carouselPage.rawValue
        json["items"] = try items.map { try $0.serializeToJsonValue() }
        
        if !layouts.isEmpty {
            json["layouts"] = layouts.map { $0.serializeToJsonValue() }
        }
        
        if let rtl = rtl {
            json["rtl"] = rtl
        }
        
        return json
    }
    
    // MARK: - SwiftCollectionCoreElement Conformance
    
    func deserializeChildren(from json: [String: Any]) throws {
        // Children are deserialized in init(from:)
    }
    
    // MARK: - Resource Information
    
    func getCarouselPageResourceInformation() -> [SwiftRemoteResourceInformation] {
        var resources: [SwiftRemoteResourceInformation] = []
        for item in items {
            resources.append(contentsOf: item.getResourceInformation())
        }
        return resources
    }
}

// MARK: - Carousel

/// Represents a Carousel element in an Adaptive Card.
/// A Carousel contains multiple CarouselPage elements with configurable animation.
public class SwiftCarousel: SwiftStyledCollectionElement, SwiftCollectionCoreElement {
    
    // MARK: - Properties
    
    /// The animation type for page transitions.
    public var pageAnimation: SwiftPageAnimation
    
    /// The pages contained within this carousel.
    var pages: [SwiftCarouselPage]
    
    // MARK: - Codable Keys
    
    private enum CodingKeys: String, CodingKey {
        case pageAnimation
        case pages
    }
    
    // MARK: - Initializers
    
    init(
        pages: [SwiftCarouselPage] = [],
        pageAnimation: SwiftPageAnimation = .slide,
        style: SwiftContainerStyle = .none,
        verticalContentAlignment: SwiftVerticalContentAlignment? = nil,
        minHeight: UInt = 0,
        bleed: Bool = false,
        backgroundImage: SwiftBackgroundImage? = nil,
        selectAction: SwiftBaseActionElement? = nil,
        id: String? = nil
    ) {
        self.pages = pages
        self.pageAnimation = pageAnimation
        super.init(
            type: .carousel,
            style: style,
            verticalContentAlignment: verticalContentAlignment,
            minHeight: minHeight,
            hasBleed: bleed,
            backgroundImage: backgroundImage,
            selectAction: selectAction,
            id: id
        )
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.pageAnimation = try container.decodeIfPresent(SwiftPageAnimation.self, forKey: .pageAnimation) ?? .slide
        self.pages = try container.decodeIfPresent([SwiftCarouselPage].self, forKey: .pages) ?? []
        
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(pageAnimation, forKey: .pageAnimation)
        try container.encode(pages, forKey: .pages)
        
        try super.encode(to: encoder)
    }
    
    // MARK: - Serialization
    
    override func serializeToJsonValue() throws -> [String: Any] {
        var json = try super.serializeToJsonValue()
        
        json["type"] = SwiftCardElementType.carousel.rawValue
        json["pages"] = try pages.map { try $0.serializeToJsonValue() }
        
        if pageAnimation != .slide {
            json["pageAnimation"] = pageAnimation.rawValue
        }
        
        return json
    }
    
    // MARK: - SwiftCollectionCoreElement Conformance
    
    func deserializeChildren(from json: [String: Any]) throws {
        // Children are deserialized in init(from:)
    }
    
    // MARK: - Resource Information
    
    func getCarouselResourceInformation() -> [SwiftRemoteResourceInformation] {
        var resources: [SwiftRemoteResourceInformation] = []
        for page in pages {
            resources.append(contentsOf: page.getCarouselPageResourceInformation())
        }
        return resources
    }
}
