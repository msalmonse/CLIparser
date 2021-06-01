// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CLIparser",
    products: [
        .library(
            name: "CLIparser",
            targets: ["CLIparser"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CLIparser",
            dependencies: []
        ),
        .testTarget(
            name: "CLIparserTests",
            dependencies: ["CLIparser"]
        ),
    ]
)
