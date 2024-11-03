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
      .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
          name: "AsyncMoya", dependencies: [
            .product(name: "Alamofire", package: "Alamofire")
          ]),
        .testTarget(
            name: "AsyncMoyaTests",
            dependencies: ["AsyncMoya"]
        ),
    ]
)
