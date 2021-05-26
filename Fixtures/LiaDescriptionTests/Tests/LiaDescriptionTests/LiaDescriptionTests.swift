import XCTest
import class Foundation.Bundle
@testable import LiaDescription
import LiaLib

final class LiaDescriptionTestTests: XCTestCase {
    
    func testFullEncodeDecode() throws {
        let binary = productsDirectory.appending(pathComponent: "FullDescription")

        let description = try renderDescription(binary: binary)

        XCTAssertEqual(description, fullDescriptionShouldBe)
    }
    
    func testEmptyEncodeDecode() throws {
        let binary = productsDirectory.appending(pathComponent: "EmptyDescription")

        let description = try renderDescription(binary: binary)
        
        let descriptionShouldBe = LiaDescription(actions: [], bundles: [])
        
        XCTAssertEqual(description, descriptionShouldBe)
    }
    
    func testRelativeEncodeDecode() throws {
        try Path.withCurrentWorkingDirectory(.temporaryDirectory) {
            let binary = productsDirectory.appending(pathComponent: "FullDescription")

            let description = try renderDescription(binary: binary, file: Path("LiaDescriptionTests.json"))

            XCTAssertEqual(description, fullDescriptionShouldBe)
        }
    }
 
    func testRenderNoargs() throws {
        let binary = productsDirectory.appending(pathComponent: "FullDescription")
        
        do {
            let _ = try renderDescription(binary: binary, noargs: true)
            XCTFail()
        } catch let error as NSError {
            XCTAssertEqual(error.code, 260)
            XCTAssertEqual((error.userInfo["NSUnderlyingError"] as? NSError)?.code, 2)
        }
    }
    
    func renderDescription(binary: Path, noargs: Bool = false, file: Path? = nil) throws -> LiaDescription {

        let jsonFile: Path
        if let file = file {
            jsonFile = file
        } else {
            jsonFile = Path.temporaryDirectory.appending(pathComponent: "LiaDescriptionTests.json")
        }
        if jsonFile.exists() {
            try! jsonFile.deleteFromFilesystem()
        }
        
        let arguments: [String]
        if noargs {
            arguments = []
        } else {
            arguments = ["--liaDescriptionOutput", jsonFile.path]
        }
        
        let output = try binary.runSync(withArguments: arguments).extractOutput()
        XCTAssertEqual(output, "")
                
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
}
