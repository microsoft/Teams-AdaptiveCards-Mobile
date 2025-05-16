// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdaptiveCardsSwift",
    platforms: [
        .iOS(.v15) // Updated to iOS 15 to match SwiftAdaptiveCards dependency requirements
    ],
    products: [
        // Single library product for simplicity during development
        .library(
            name: "AdaptiveCardsSwift",
            targets: ["AdaptiveCardsSwift"])
    ],
    dependencies: [
        // Local dependency on SwiftAdaptiveCards - with absolute path to ensure correct resolution
        .package(name: "SwiftAdaptiveCards", path: "../AdaptiveCards/AdaptiveCards/Packages/SwiftAdaptiveCards")
    ],
    targets: [
        // Main Swift implementation target
        .target(
            name: "AdaptiveCardsSwift",
            dependencies: [
                .product(name: "SwiftAdaptiveCards", package: "SwiftAdaptiveCards")
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ]
        ),
        
        // Tests target
        .testTarget(
            name: "AdaptiveCardsSwiftTests",
            dependencies: ["AdaptiveCardsSwift"]),
    ]
)
