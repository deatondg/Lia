import XCTest
@testable import TemplateDescription
// TODO: Remove @testable
@testable import LiaLib

final class TemplateDescriptionTests: XCTestCase {
    func testFullEncodeDecode() async throws {
        let template = try await cache.run(RenderTemplateDescription.self, from: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift"))
        
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
    
    func testPartialEncodeDecode() async throws {
        let template = try await cache.run(RenderTemplateDescription.self, from: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "PartialTemplate.swift"))
        
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
    
    func testEmptyEncodeDecode() async throws {
        let template = try await cache.run(RenderTemplateDescription.self, from: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "EmptyTemplate.swift"))
        
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
    
//    func testRelativeEncodeDecode() async throws {
//        try Path.withCurrentWorkingDirectory(.sharedTemporaryDirectory) {
//            let cache = try await LiaCache(
//                forNewDirectory: Path(UUID().uuidString),
//                swiftc: Path.executable(named: "swiftc"),
//                libDirectory: libDirectory)
//
//            let template = try await cache.renderTemplateDescription(
//                descriptionFile: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift"),
//                ignoreCache: true,
//                saveHash: true,
//                tee: true
//            ).template
//
//            let templateShouldBe = Template(
//                parameters: .init("parameters", line: 4, column: 18),
//                key: .init("key", line: 5, column: 11),
//                identifier: .init("identifier", line: 6, column: 18),
//                syntax: .init(
//                    value: .init(open: .init("value.open", line: 8, column: 29), close: .init("value.close", line: 8, column: 52)),
//                    code: .init(open: .init("code.open", line: 9, column: 28), close: .init("code.close", line: 9, column: 50)),
//                    comment: .init(open: .init("comment.open", line: 10, column: 31), close: .init("comment.close", line: 10, column: 56))
//                )
//            )
//
//            XCTAssertEqual(template, templateShouldBe)
//        }
//    }
 
    func testRenderNoargs() async throws {
        let artifact = Path.temporaryFile()
        
        try await LiaBuild.build(
            swiftc: swiftc,
            libDirectory: libDirectory,
            libs: ["LiaSupport", "TemplateDescription"],
            source: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift"),
            destination: artifact
        )
        
        try await artifact.run().confirmEmpty()
    }
    
    static let cache: LiaCache = unsafeWaitFor {
        try! await LiaCache(
            forNewDirectory: try Path.temporaryDirectory(),
            swiftc: swiftc,
            libDirectory: libDirectory)
    }
    var cache: LiaCache {
        Self.cache
    }
    
    static let swiftc: Path = unsafeWaitFor {
        try! await Path.executable(named: "swiftc")
    }
    var swiftc: Path {
        Self.swiftc
    }
    
    /// Returns path package directory.
    var packageDirectory: Path {
        Self.packageDirectory
    }
    static var packageDirectory: Path {
        Path(#file).deletingLastComponent().deletingLastComponent().deletingLastComponent()
    }
    
    /// Returns the path to the libraries built by SwiftPM
    var libDirectory: Path {
        Self.libDirectory
    }
    static var libDirectory: Path {
        packageDirectory.appending(components: ".build", "debug")
    }
    
    /// If we are running in Xcode, make sure that the SwiftPM package has been built traditionally so that the dylibs are built.
    /// Prime the static variables
    override class func setUp() {
        super.setUp()
        
        if xcodeTestVars.contains(where: ProcessInfo.processInfo.environment.keys.contains) {
            unsafeWaitFor {
                try! await Path.executable(named: "swift").run(inDirectory: packageDirectory, withArguments: "build", tee: true)
            }
        }
        let _ = swiftc
        let _ = cache
    }
}
