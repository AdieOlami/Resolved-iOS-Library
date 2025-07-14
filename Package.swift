// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResolvedLibrary",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "ResolvedLibrary",
            targets: ["ResolvedLibrary"]),
    ],
    targets: [
        .target(
            name: "ResolvedLibrary",
            dependencies: ["Resolved"]
        ),
        .binaryTarget(
            name: "Resolved",
            path: "./Sources/Resolved.xcframework"
        ),
    ]
)
