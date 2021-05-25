import XCTest
import class Foundation.Bundle
@testable import TemplateDescription
import LiaLib

final class TemplateDescriptionTests: XCTestCase {
    
    func testFullEncodeDecode() throws {
        let binary = productsDirectory.appending(pathComponent: "FullTemplate")

        let template = try renderTemplate(binary: binary)
        
        let templateShouldBe = Template(
            parameters: .init("parameters", line: 4, column: 18),
            key: .init("key", line: 5, column: 11),
            identifier: .init("identifier", line: 6, column: 18),
            syntax: .init(
                value: .init(open: .init("value.open", line: 8, column: 29), close: .init("value.close", line: 8, column: 52)),
                code: .init(open: .init("code.open", line: 9, column: 28), close: .init("code.close", line: 9, column: 50)),
                comment: .init(open: .init("comment.open", line: 10, column: 31), close: .init("comment.close", line: 10, column: 56))
            )
        )

        XCTAssertEqual(template, templateShouldBe)
    }
    
    func testPartialEncodeDecode() throws {
        let binary = productsDirectory.appending(pathComponent: "PartialTemplate")

        let template = try renderTemplate(binary: binary)
        
        let templateShouldBe = Template(
            parameters: .init("parameters", line: 4, column: 18),
            key: .init("key", line: 5, column: 11),
            identifier: nil,
            syntax: .init(
                value: nil,
                code: nil,
                comment: .init(open: .init("comment.open", line: 7, column: 31), close: .init("comment.close", line: 7, column: 56))
            )
        )
        
        XCTAssertEqual(template, templateShouldBe)
    }
    
    func testEmptyEncodeDecode() throws {
        let binary = productsDirectory.appending(pathComponent: "EmptyTemplate")

        let template = try renderTemplate(binary: binary)
        
        let templateShouldBe = Template(
            parameters: nil,
            key: nil,
            identifier: nil,
            syntax: .init(
                value: nil,
                code: nil,
                comment: nil
            )
        )
        
        let templateAlsoShouldBe = Template()
        
        XCTAssertEqual(template, templateShouldBe)
        XCTAssertEqual(template, templateAlsoShouldBe)
    }
    
    func testRelativeEncodeDecode() throws {
        try Path.withCurrentWorkingDirectory(.temporaryDirectory) {
            let binary = productsDirectory.appending(pathComponent: "FullTemplate")

            let template = try renderTemplate(binary: binary, file: Path("TemplateDescriptionTests.json"))
            
            let templateShouldBe = Template(
                parameters: .init("parameters", line: 4, column: 18),
                key: .init("key", line: 5, column: 11),
                identifier: .init("identifier", line: 6, column: 18),
                syntax: .init(
                    value: .init(open: .init("value.open", line: 8, column: 29), close: .init("value.close", line: 8, column: 52)),
                    code: .init(open: .init("code.open", line: 9, column: 28), close: .init("code.close", line: 9, column: 50)),
                    comment: .init(open: .init("comment.open", line: 10, column: 31), close: .init("comment.close", line: 10, column: 56))
                )
            )

            XCTAssertEqual(template, templateShouldBe)
        }
    }
 
    func testRenderNoargs() {
        let binary = productsDirectory.appending(pathComponent: "FullTemplate")
        
        do {
            let _ = try renderTemplate(binary: binary, noargs: true)
            XCTFail()
        } catch let error as NSError {
            XCTAssertEqual(error.code, 260)
            XCTAssertEqual((error.userInfo["NSUnderlyingError"] as? NSError)?.code, 2)
        }
    }
    
    func renderTemplate(binary: Path, noargs: Bool = false, file: Path? = nil) throws -> Template {

        let jsonFile: Path
        if let file = file {
            jsonFile = file
        } else {
            jsonFile = Path.temporaryDirectory.appending(pathComponent: "TemplateDescriptionTests.json")
        }
        if jsonFile.exists() {
            try! jsonFile.deleteFromFilesystem()
        }
        
        let arguments: [String]
        if noargs {
            arguments = []
        } else {
            arguments = ["--liaTemplateOutput", jsonFile.path]
        }
        
        let output = try binary.runSync(withArguments: arguments).extractOutput()
        XCTAssertEqual(output, "")

        return try JSONDecoder().decode(Template.self, from: try Data(contentsOf: jsonFile))
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
