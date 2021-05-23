// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "TemplateDescriptionTest",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(name: "Lia", path: "../..")
    ],
    targets: [
        .target(
            name: "FullTemplate",
            dependencies: [.product(name: "TemplateDescription", package: "Lia")]),
        .target(
            name: "PartialTemplate",
            dependencies: [.product(name: "TemplateDescription", package: "Lia")]),
        .target(
            name: "EmptyTemplate",
            dependencies: [.product(name: "TemplateDescription", package: "Lia")]),
        .testTarget(
            name: "TemplateDescriptionTests",
            dependencies: [.product(name: "TemplateDescription", package: "Lia"), .product(name: "LiaLib", package: "Lia"),
                           "FullTemplate", "PartialTemplate", "EmptyTemplate"]),
    ]
)