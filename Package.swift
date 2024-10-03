// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SmartSpectraIosSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SmartSpectraIosSDK",
            targets: ["SmartSpectraIosSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.28.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SmartSpectraIosSDK",
            dependencies: [
                "PresagePreprocessing",
                .product(name: "SwiftProtobuf", package: "swift-protobuf")
                ],
            path: "Sources/SmartSpectraIosSDK",
            resources: [.process("Resources")]
        ),
        .binaryTarget(
            name: "PresagePreprocessing",
            path: "Sources/Frameworks/PresagePreprocessing.xcframework"
        )
    ]
)
