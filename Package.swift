// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.
// 1.1

import PackageDescription

let package = Package(
    name: "Calls",
    platforms: [
            .iOS(.v13),
            .macOS(.v10_15),
            .macCatalyst(.v14),
        ],
    products: [
        .library(
            name: "Calls-Swift",
            targets: ["Calls-Swift"]),
    ],
    dependencies: [
        ],
    targets: [
        .target(
            name: "Calls-Swift",
            dependencies: [
            ]
        )
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
