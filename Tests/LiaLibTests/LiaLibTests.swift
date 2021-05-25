import XCTest
@testable import LiaLib

final class LiaLibTests: XCTestCase {
    func testSwiftVersion() throws {
        let version = try Path.executable(named: "swift").runSync(withArguments: "--version").extractOutput()
        XCTAssert(version.starts(with: "Apple Swift version 5.4"))
    }
    
    func testTemplateBundle() throws {
        let _ = try TemplateBundle.init(fromDescription: .init(name: .init("test"), path: nil, dependencies: nil, includeSources: nil, allowInlineHeaders: nil, templateExtension: nil, headerExtension: nil, unknownFileMethod: nil, ignoreDotFiles: nil, invalidIdentifierCharacterMethod: nil, defaultParameters: nil, defaultSyntax: .init()))
    }
    
    /// Returns path package directory.
    var packageDirectory: Path {
        Path(#file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
