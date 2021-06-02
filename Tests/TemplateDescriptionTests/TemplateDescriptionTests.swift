import XCTest
@testable import TemplateDescription
import LiaLib

final class TemplateDescriptionTests: XCTestCase {
    func testFullEncodeDecode() throws {
        let file = packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift")

        let template = try renderDescription(file: file)
        
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
        let file = packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "PartialTemplate.swift")

        let template = try renderDescription(file: file)
        
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
        let file = packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "EmptyTemplate.swift")

        let template = try renderDescription(file: file)
        
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
        try Path.withCurrentWorkingDirectory(.sharedTemporaryDirectory) {
            let file = packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift")

            let template = try renderDescription(file: file, artifact: Path("TemplateDescriptionTests.artifact"), manifest: Path("TemplateDescriptionTests.json"))
            
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
        let file = packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift")
        
        do {
            let _ = try renderDescription(file: file, noargs: true)
            XCTFail()
        } catch let error as NSError {
            XCTAssertEqual(error.code, 260)
            XCTAssertEqual((error.userInfo["NSUnderlyingError"] as? NSError)?.code, 2)
        }
    }
    
    func renderDescription(file input: Path, noargs: Bool = false, artifact: Path? = nil, manifest: Path? = nil) throws -> Template {
        let artifact: Path = artifact ?? Path.sharedTemporaryDirectory.appending(component: "\(UUID()).artifact")
        let manifest: Path = manifest ?? Path.sharedTemporaryDirectory.appending(component: "\(UUID()).json")
        
        if artifact.exists() {
            try! artifact.deleteFromFilesystem()
        }
        if manifest.exists() {
            try! manifest.deleteFromFilesystem()
        }
        
        let swiftcArguments: [String] = [
            "-Xlinker", "-rpath",
            "-Xlinker", libDirectory.path,
            "-L", libDirectory.path,
            "-I", libDirectory.path,
            "-lTemplateDescription", "-lLiaSupport",
            input.path,
            "-o", artifact.path
        ]
        
        let swiftcOutput = try Path.executable(named: "swiftc").runSync(withArguments: swiftcArguments, tee: true).extractOutput()
        XCTAssertEqual(swiftcOutput, "")
        
        let artifactArguments = noargs ? [] : ["--liaTemplateOutput", manifest.path]
        
        let artifactOutput = try artifact.runSync(withArguments: artifactArguments, tee: false).extractOutput()
        XCTAssertEqual(artifactOutput, "")
        
        return try JSONDecoder().decode(Template.self, from: try Data(contentsOf: manifest))
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
