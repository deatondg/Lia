// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Lia",
    platforms: [
        .macOS("12")
    ],
    products: [
        /// The front-end invoked by `lia`
        .executable(
            name: "lia",
            targets: ["Lia"]),
        /// The majority of functionaliy for `lia` is here. This way, it can be tested individually.
        /// Some tests also import LiaLib to use some of its functionality.
        .library(
            name: "LiaLib",
            targets: ["LiaLib"]),
        /// Renames some Description types so that LiaLib can reuse them.
        /// It is very frustrating to me that I must do this.
        .library(
            name: "LiaShims",
            targets: ["LiaShims"]),
        /// The description of a `Lia.swift` file.
        .library(
            name: "LiaDescription",
            type: .dynamic,
            targets: ["LiaDescription"]),
        /// The description of a `.lia` file.
        .library(
            name: "TemplateDescription",
            type: .dynamic,
            targets: ["TemplateDescription"]),
        /// Code shared by `LiaDescription` and `TemplateDescription`.
        .library(
            name: "LiaSupport",
            type: .dynamic,
            targets: ["LiaSupport"]),
    ],
    dependencies: [
        .package(name: "Parsers", url: "../Parsers.swift", .branch("main")),
        .package(name: "tee", url: "https://github.com/deatondg/tee.swift", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "0.2.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "1.1.6")
        //.package(name: "SwiftPM", url: "https://github.com/apple/swift-package-manager", .revision("swift-5.4-RELEASE"))
    ],
    targets: [
        .executableTarget(
            name: "Lia",
            dependencies: ["LiaLib"]),
        .target(
            name: "LiaLib",
            dependencies: ["LiaShims", "LiaDescription", "TemplateDescription", "LiaSupport",
                           "Parsers",
                           "tee",
                           .product(name: "Crypto", package: "swift-crypto"),
                           .product(name: "Algorithms", package: "swift-algorithms")
            ],
            resources: [
                .copy("Resources")
            ]),
        .target(
            name: "LiaShims",
            dependencies: ["LiaDescription", "TemplateDescription", "LiaSupport"]),
        .target(
            name: "LiaDescription",
            dependencies: ["LiaSupport",
                           //.product(name: "PackageDescription", package: "SwiftPM")
            ]),
        .target(
            name: "TemplateDescription",
            dependencies: ["LiaSupport"]),
        .target(
            name: "LiaSupport",
            dependencies: []),
        
        .testTarget(
            name: "LiaTests",
            dependencies: ["Lia", "LiaLib"]),
        .testTarget(
            name: "LiaLibTests",
            dependencies: ["LiaLib"]),
        .testTarget(
            name: "LiaDescriptionTests",
            dependencies: ["LiaLib", "LiaDescription"]),
        .testTarget(
            name: "TemplateDescriptionTests",
            dependencies: ["LiaLib", "TemplateDescription"]),
        .testTarget(
            name: "LiaSupportTests",
            dependencies: ["LiaSupport"]),
    ]
)
