// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Moya",
  platforms: [.macOS(.v10_15), .iOS(.v17), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Moya",
      targets: ["Moya"]),
    .library(name: "CombineMoya", targets: ["CombineMoya"]),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
    .package(url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "4.0.0")), // dev
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.0.0")), // dev
    .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.0.0")) // dev
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Moya",
      dependencies: [
        .product(name: "Alamofire", package: "Alamofire")
      ]),
    .target(
      name: "CombineMoya",
      dependencies: [
        "Moya"
      ]
    ),
    .testTarget(
      name: "MoyaTests",
      dependencies: [
        "Moya",
        "CombineMoya", // dev
        .product(name: "Quick", package: "Quick"), // dev
        .product(name: "Nimble", package: "Nimble"), // dev
        .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs") // dev
      ]
    ),
  ]
)
