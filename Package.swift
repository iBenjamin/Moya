// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncMoya",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AsyncMoya",
            targets: ["AsyncMoya"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "13.0.0")), // dev
        .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "7.0.0")), // dev
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AsyncMoya"),
        .testTarget(
            name: "AsyncMoyaTests",
            dependencies: ["AsyncMoya",
                           .product(name: "Quick", package: "Quick"), // dev
                           .product(name: "Nimble", package: "Nimble"), // dev
            ]
        ),
    ]
)
