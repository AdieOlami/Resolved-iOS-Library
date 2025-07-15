// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResolvedLibrary",
    platforms: [.iOS(.v17)], // Consider lowering to support more devices
    products: [
        .library(
            name: "ResolvedLibrary",
            targets: ["ResolvedLibrary"]
        ),
    ],
    dependencies: [
//        .package(url: "https://github.com/facebook/lexical-ios", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "ResolvedLibrary",
            dependencies: [
                "Resolved",
//                .product(name: "Lexical", package: "lexical-ios")
            ],
            path: "./Sources/ResolvedLibrary"
        ),
        .binaryTarget(
            name: "Resolved",
            path: "./Sources/Resolved.xcframework"
        ),
    ]
)
