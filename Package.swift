// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Lia",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.3.1")),
        .package(url: "https://github.com/kylef/PathKit", .upToNextMinor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "Lia",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "PathKit",
            ]),
        .testTarget(
            name: "LiaTests",
            dependencies: ["Lia"]),
    ]
)
