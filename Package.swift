// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncRequest",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "AsyncRequest",
            targets: ["AsyncRequest"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble", from: "10.0.0"),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", from: "9.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AsyncRequest",
            dependencies: []),
        .testTarget(
            name: "AsyncRequestTests",
            dependencies: [
                "AsyncRequest",
                "Nimble",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ]),
    ]
)
