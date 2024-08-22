// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Calls",
    platforms: [
            .iOS(.v13),
            .macOS(.v10_15),
            .macCatalyst(.v14),
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Calls-Swift",
            targets: ["Calls-Swift"]),
    ],
    dependencies: [
            // LK-Prefixed Dynamic WebRTC XCFramework
            .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
            .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
            .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Calls-Swift",
            dependencies: [
               .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
               .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .testTarget(
            name: "Calls-SwiftTests",
            dependencies: ["Calls-Swift"]),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
