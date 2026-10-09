// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Pollux",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "Pollux",
            targets: ["Pollux"]
        ),
    ],
    targets: [
        .target(
            name: "Pollux",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "PolluxTests",
            dependencies: ["Pollux"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
