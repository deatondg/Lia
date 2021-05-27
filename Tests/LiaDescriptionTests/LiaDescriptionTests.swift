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
        let descriptionFile = packageDirectory + "Fixtures/LiaDescriptions/FullDescription.swift"

        let description = try renderDescription(file: descriptionFile)

        XCTAssertEqual(description, fullDescriptionShouldBe)
    }
    
    func testEmptyEncodeDecode() throws {
        let descriptionFile = packageDirectory + "Fixtures/LiaDescriptions/EmptyDescription.swift"

        let description = try renderDescription(file: descriptionFile)
        
        let descriptionShouldBe = LiaDescription(actions: [], bundles: [])
        
        XCTAssertEqual(description, descriptionShouldBe)
    }
    
    func testRelativeEncodeDecode() throws {
        try Path.withCurrentWorkingDirectory(.temporaryDirectory) {
            let descriptionFile = packageDirectory + "Fixtures/LiaDescriptions/FullDescription.swift"

            let description = try renderDescription(file: descriptionFile, manifest: Path("LiaDescriptionTests.manifest"), jsonFile: Path("LiaDescriptionTests.json"))

            XCTAssertEqual(description, fullDescriptionShouldBe)
        }
    }

    func testRenderNoargs() throws {
        let descriptionFile = packageDirectory + "Fixtures/LiaDescriptions/FullDescription.swift"
        
        do {
            let _ = try renderDescription(file: descriptionFile, noargs: true)
            XCTFail()
        } catch let error as NSError {
            XCTAssertEqual(error.code, 260)
            XCTAssertEqual((error.userInfo["NSUnderlyingError"] as? NSError)?.code, 2)
        }
    }
    
    func renderDescription(file input: Path, noargs: Bool = false, manifest: Path? = nil, jsonFile: Path? = nil) throws -> LiaDescription {
        let jsonFile: Path = jsonFile ?? Path.temporaryDirectory.appending(pathComponent: "\(UUID()).json")
        let manifest: Path = manifest ?? Path.temporaryDirectory.appending(pathComponent: "\(UUID()).manifest")
        
        if jsonFile.exists() {
            try! jsonFile.deleteFromFilesystem()
        }
        if manifest.exists() {
            try! manifest.deleteFromFilesystem()
        }
        
        let libDirectory = Path("/Users/davisdeaton/Developer/Projects/Lia/.build/debug")
        
        let swiftcArguments: [String] = [
            "-Xlinker", "-rpath",
            "-Xlinker", libDirectory.path,
            "-L", libDirectory.path,
            "-I", libDirectory.path,
            "-lLiaDescription", "-lLiaSupport",
            input.path,
            "-o", manifest.path
        ]
        
        let swiftcOutput = try Path.executable(named: "swiftc").runSync(withArguments: swiftcArguments, tee: true).extractOutput()
        XCTAssertEqual(swiftcOutput, "")
        
        let manifestArguments = noargs ? [] : ["--liaDescriptionOutput", jsonFile.path]
        
        let manifestOutput = try manifest.runSync(withArguments: manifestArguments, tee: false).extractOutput()
        XCTAssertEqual(manifestOutput, "")
        
        return try JSONDecoder().decode(LiaDescription.self, from: try Data(contentsOf: jsonFile))
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
    
    /// Returns path to the built products directory.
    var productsDirectory: Path {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.path.extension == "xctest" {
            return bundle.path.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.path
      #endif
    }
 
    /// Returns path package directory.
    var packageDirectory: Path {
        Path(#file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
