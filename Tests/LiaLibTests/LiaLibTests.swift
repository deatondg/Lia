import XCTest
@testable import LiaLib
import LiaDescription

final class LiaLibTests: XCTestCase {
    func testSwiftVersion() throws {
        let version = try Path.executable(named: "swift").runSync(withArguments: "--version").extractOutput()
        XCTAssert(version.starts(with: "Apple Swift version 5.4"))
    }
    
    func testTemplateBundle() throws {
        let testTemplateBundlePath = packageDirectory + "Fixtures/TestTemplateBundle"
        let testTemplateBundleDescription = TemplateBundle(name: "TestTemplateBundle", path: testTemplateBundlePath)
        let testTemplateBundle = try TemplateBundle(from: testTemplateBundleDescription)
        print(testTemplateBundle)
        //fatalError()
    }
    
    /// Returns path package directory.
    var packageDirectory: Path {
        Path(#file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
