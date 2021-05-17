// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Lia",
    products: [
        .executable(
            name: "Lia",
            targets: ["Lia"]),
        .library(
            name: "LiaLib",
            targets: ["LiaLib"]),
        .library(
            name: "LiaDescription",
            targets: ["LiaDescription"]),
        .library(
            name: "TemplateDescription",
            targets: ["TemplateDescription"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "SwiftPM", url: "https://github.com/apple/swift-package-manager", .revision("swift-5.4-RELEASE"))
    ],
    targets: [
        .target(
            name: "Lia",
            dependencies: ["LiaLib"]),
        .target(
            name: "LiaLib",
            dependencies: []),
        .target(
            name: "LiaDescription",
            dependencies: [.product(name: "PackageDescription", package: "SwiftPM")]),
        .target(
            name: "TemplateDescription",
            dependencies: []),
        .testTarget(
            name: "LiaTests",
            dependencies: ["Lia"]),
        .testTarget(
            name: "LiaLibTests",
            dependencies: ["LiaLib"]),
        .testTarget(
            name: "LiaDescriptionTests",
            dependencies: ["LiaDescription"]),
        .testTarget(
            name: "TemplateDescriptionTests",
            dependencies: ["TemplateDescription"])
    ]
)
