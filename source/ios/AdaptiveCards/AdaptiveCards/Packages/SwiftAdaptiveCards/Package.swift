// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftAdaptiveCards",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftAdaptiveCards",
            targets: ["SwiftAdaptiveCards"]),
    ],
    dependencies: [
        // Dependencies go here
        // Example: .package(url: "https://github.com/SVGKit/SVGKit.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftAdaptiveCards",
            dependencies: []),
        .testTarget(
            name: "SwiftAdaptiveCardsTests",
            dependencies: ["SwiftAdaptiveCards"]),
    ]
)
