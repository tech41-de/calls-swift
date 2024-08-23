// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Calls",
    platforms: [
            .iOS(.v13),
            .macOS(.v10_15)
        ],
    products: [
        .library(
            name: "Calls-Swift",
            targets: ["Calls-Swift"]),
    ],
    targets: [
        .target(
            name: "Calls-Swift"
        )
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)


