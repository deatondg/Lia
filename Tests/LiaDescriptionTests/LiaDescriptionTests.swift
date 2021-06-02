import XCTest
@testable import LiaDescription
import LiaSupport
import LiaLib

final class LiaDescriptionTests: XCTestCase {
    func testIsItEvenPossibleToMakeBundles() {
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            templateExtension: {"template_extension"},
            headerExtension: {"header_extension"}
        )
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            templateExtension: {"template_extension"},
            headerExtension: .none()
        )
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            templateExtension: .none(),
            headerExtension: {"header_extension"}
        )
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            templateExtension: .none(),
            headerExtension: .none()
        )
        
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            unknownFileMethod: .error(),
            identifierConversionMethod: .fail()
        )
        
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            headerExtension: {"header_extension"},
            unknownFileMethod: .error(),
            identifierConversionMethod: .fail()
        )
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            headerExtension: .none(),
            unknownFileMethod: .error(),
            identifierConversionMethod: .fail()
        )
    }
    
    func testIsItEvenPossibleToMakeLocatedStringArrays() {
        let _ = LiaDescription(
            actions: [
                .render(bundles: {"bundle1"}, toPath: {"render_path"})
            ],
            bundles: []
        )
        let _ = LiaDescription(
            actions: [
                .render(bundles: {"bundle1"; "bundle2"}, toPath: {"render_path"})
            ],
            bundles: []
        )
        let _ = LiaDescription(
            actions: [
                .render(
                    bundles: {
                        "bundle1"
                    },
                    toPath: {"render_path"})
            ],
            bundles: []
        )
        let _ = LiaDescription(
            actions: [
                .render(
                    bundles: {
                        "bundle1"
                        "bundle2"
                    },
                    toPath: {"render_path"})
            ],
            bundles: []
        )
    }
    
    func testFullEncodeDecode() throws {
        let cache = try LiaCache(forNewDirectory: Path.temporaryDirectory(),
                                 swiftc: Path.executable(named: "swiftc"),
                                 libDirectory: libDirectory
        )
        
        let description = try cache.renderLiaDescription(
            descriptionFile: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "FullDescription.swift"),
            ignoreCache: true,
            saveHash: true,
            tee: true
        ).description
        
        XCTAssertEqual(description, fullDescriptionShouldBe)
    }
    
    func testEmptyEncodeDecode() throws {
        let cache = try LiaCache(forNewDirectory: Path.temporaryDirectory(),
                                 swiftc: Path.executable(named: "swiftc"),
                                 libDirectory: libDirectory
        )
        
        let description = try cache.renderLiaDescription(
            descriptionFile: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "EmptyDescription.swift"),
            ignoreCache: true,
            saveHash: true,
            tee: true
        ).description
        
        let descriptionShouldBe = LiaDescription(actions: [], bundles: [])
        
        XCTAssertEqual(description, descriptionShouldBe)
    }
    
    func testRelativeEncodeDecode() throws {
        try Path.withCurrentWorkingDirectory(.sharedTemporaryDirectory) {
            let cache = try LiaCache(forNewDirectory: Path(UUID().uuidString),
                                     swiftc: Path.executable(named: "swiftc"),
                                     libDirectory: libDirectory
            )
            
            let description = try cache.renderLiaDescription(
                descriptionFile: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "FullDescription.swift"),
                ignoreCache: true,
                saveHash: true,
                tee: true
            ).description
            
            XCTAssertEqual(description, fullDescriptionShouldBe)
        }
    }

    func testRenderNoargs() throws {
        let artifact = Path.temporaryFile()
        
        try LiaBuild.build(
            swiftc: Path.executable(named: "swiftc"),
            libDirectory: libDirectory,
            libs: ["LiaSupport", "LiaDescription"],
            source: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "FullDescription.swift"),
            destination: artifact
        )
        
        try artifact.runSync().confirmEmpty()
    }
    
    var fullDescriptionShouldBe: LiaDescription {
        LiaDescription(
            actions: [
                LiaAction(
                    bundles: [
                            .init("render_bundle", line: 7, column: 17),
                            .init("shared_bundle", line: 8, column: 17)
                    ],
                    destination: .init("render_path", line: 10, column: 22), type: .render
                ),
                LiaAction(
                    bundles: [
                        .init("package_bundle", line: 12, column: 17),
                        .init("shared_bundle", line: 13, column: 17)
                    ],
                    destination: .init("package_path", line: 15, column: 22), type: .build(.package(name: .init("package_name", line: 16, column: 33)))
                ),
                LiaAction(
                    bundles: [
                        .init("package_bundle", line: 18, column: 17),
                        .init("shared_bundle", line: 19, column: 17)
                    ],
                    destination: .init("sources_path", line: 21, column: 22), type: .build(.sources(line: 22, column: 25))
                )
            ],
            bundles: [
                TemplateBundle(
                    name: .init("render_bundle", line: 26, column: 20),
                    path: .init("render_bundle_path", line: 27, column: 20),
                    includeSources: .init(false, line: 28, column: 30),
                    allowInlineHeaders: .init(false, line: 29, column: 34),
                    templateExtension: .init(.init("render_template_extension", line: 30, column: 33)),
                    headerExtension: .init(.init("render_header_extension", line: 31, column: 31)),
                    unknownFileMethod: .error(line: 32, column: 38),
                    ignoreDotFiles: .init(false, line: 33, column: 30),
                    identifierConversionMethod: .fail(line: 34, column: 46),
                    defaultParameters: .init("render_default_parameters", line: 35, column: 33),
                    defaultSyntax: .init(
                        value: .init(open: .init("render_value_open", line: 37, column: 37), close: .init("render_value_close", line: 37, column: 67)),
                        code: .init(open: .init("render_code_open", line: 38, column: 36), close: .init("render_code_close", line: 38, column: 65)),
                        comment: .init(open: .init("render_comment_open", line: 39, column: 39), close: .init("render_comment_close", line: 39, column: 71))
                    )
                ),
                TemplateBundle(
                    name: .init("package_bundle", line: 43, column: 20),
                    path: .init("package_bundle_path", line: 44, column: 20),
                    includeSources: .init(true, line: 45, column: 30),
                    allowInlineHeaders: .init(true, line: 46, column: 34),
                    templateExtension: .init(.init("package_template_extension", line: 47, column: 33)),
                    headerExtension: .init(.init("package_header_extension", line: 48, column: 31)),
                    unknownFileMethod: .ignore(line: 49, column: 39),
                    ignoreDotFiles: .init(true, line: 50, column: 30),
                    identifierConversionMethod: .replaceOrPrefixWithUnderscores(line: 51, column: 72),
                    defaultParameters: .init("package_default_parameters", line: 52, column: 33),
                    defaultSyntax: .init(
                        value: .init(open: .init("package_value_open", line: 54, column: 37), close: .init("package_value_close", line: 54, column: 68)),
                        code: .init(open: .init("package_code_open", line: 55, column: 36), close: .init("package_code_close", line: 55, column: 66)),
                        comment: .init(open: .init("package_comment_open", line: 56, column: 39), close: .init("package_comment_close", line: 56, column: 72))
                    )
                ),
                TemplateBundle(
                    name: .init("shared_bundle", line: 60, column: 20),
                    path: .init("shared_bundle_path", line: 61, column: 20),
                    includeSources: .init(true, line: 62, column: 30),
                    allowInlineHeaders: .init(false, line: 63, column: 34),
                    templateExtension: .none(line: 64, column: 37),
                    headerExtension: .none(line: 65, column: 35),
                    unknownFileMethod: .error(line: 66, column: 38),
                    ignoreDotFiles: .init(true, line: 67, column: 30),
                    identifierConversionMethod: .fail(line: 68, column: 46),
                    defaultParameters: .init("shared_default_parameters", line: 69, column: 33),
                    defaultSyntax: .init(
                        value: .init(open: .init("shared_value_open", line: 71, column: 37), close: .init("shared_value_close", line: 71, column: 67)),
                        code: .init(open: .init("shared_code_open", line: 72, column: 36), close: .init("shared_code_close", line: 72, column: 65)),
                        comment: .init(open: .init("shared_comment_open", line: 73, column: 39), close: .init("shared_comment_close", line: 73, column: 71))
                    )
                ),
            ]
        )
    }
 
    /// Returns path package directory.
    var packageDirectory: Path {
        Self.packageDirectory
    }
    class var packageDirectory: Path {
        Path(#file).deletingLastComponent().deletingLastComponent().deletingLastComponent()
    }
    
    /// Returns the path to the libraries built by SwiftPM
    var libDirectory: Path {
        packageDirectory.appending(components: ".build", "debug")
    }
    
    override class func setUp() {
        super.setUp()
        
        let xcodeTestVars = ["OS_ACTIVITY_DT_MODE", "XCTestSessionIdentifier", "XCTestBundlePath", "XCTestConfigurationFilePath"]
        if xcodeTestVars.contains(where: ProcessInfo.processInfo.environment.keys.contains) {
            try! Path.executable(named: "swift").runSync(inDirectory: packageDirectory, withArguments: "build", tee: true)
        }
    }
}
