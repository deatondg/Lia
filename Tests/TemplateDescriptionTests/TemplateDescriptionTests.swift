import XCTest
@testable import TemplateDescription
import LiaLib

final class TemplateDescriptionTests: XCTestCase {
    func testFromFixtures() throws {
        let fixture = packageDirectory + "Fixtures/TemplateDescriptionTests"
        let result = try Path.executable(named: "swift").runSync(inDirectory: fixture, withArguments: "test", tee: true)
        if let stderr = result.error,
              result.terminationReason == .exit,
              result.terminationStatus == 0,
              result.output != nil,
              stderr.split(separator: "\n").dropLast().last?.starts(with: "Test Suite \'All tests\' passed") == true
        { }
        else {
            XCTFail()
        }
    }
    
    /// Returns path package directory.
    var packageDirectory: Path {
        Path(#file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
