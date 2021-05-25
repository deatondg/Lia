// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LiaDescriptionTest",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "FullDescription",
            targets: ["FullDescription"]),
        .executable(
            name: "PartialDescription",
            targets: ["PartialDescription"]),
        .executable(
            name: "EmptyDescription",
            targets: ["EmptyDescription"])
    ],
    dependencies: [
        .package(name: "Lia", path: "../..")
    ],
    targets: [
        .target(
            name: "FullDescription",
            dependencies: [.product(name: "LiaDescription", package: "Lia")]),
        .target(
            name: "PartialDescription",
            dependencies: [.product(name: "LiaDescription", package: "Lia")]),
        .target(
            name: "EmptyDescription",
            dependencies: [.product(name: "LiaDescription", package: "Lia")]),
        .testTarget(
            name: "LiaDescriptionTests",
            dependencies: [.product(name: "LiaDescription", package: "Lia"), .product(name: "LiaLib", package: "Lia"),
                           "FullDescription", "PartialDescription", "EmptyDescription"]),
    ]
)
