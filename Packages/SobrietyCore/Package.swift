// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SobrietyCore",
    defaultLocalization: "pl",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SobrietyCore",
            targets: ["SobrietyCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SobrietyCore",
            dependencies: [],
            path: "Sources/SobrietyCore",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SobrietyCoreTests",
            dependencies: ["SobrietyCore"],
            path: "Tests/SobrietyCoreTests",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
    ]
)
