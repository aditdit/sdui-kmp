// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SDUI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SDUI",
            targets: ["SDUI"]),
    ],
    dependencies: [
        // The Shared KMM framework is handled as a local XCFramework reference in the app, 
        // or can be added here if distributed as a Swift Package.
    ],
    targets: [
        .target(
            name: "SDUI",
            dependencies: [
                .target(name: "Shared")
            ]),
        .binaryTarget(
            name: "Shared",
            path: "../../shared/build/XCFrameworks/release/Shared.xcframework"
        )
    ]
)
