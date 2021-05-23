import XCTest
@testable import TemplateDescription
import LiaLib

final class TemplateDescriptionTests: XCTestCase {
    func testFromFixtures() throws {
        let fixture = packageDirectory + "Fixtures/TemplateDescriptionTests"
        let result = try Path("/bin/sh").runSync(inDirectory: fixture, withArguments: "-c", "swift test", tee: true)
        guard let stderr = result.error, result.terminationReason == .exit, result.terminationStatus == 0, result.output != nil else { XCTFail("\(result)"); return }
        XCTAssert(stderr.split(separator: "\n").dropLast().last!.starts(with: "Test Suite \'All tests\' passed"))
    }
    
    /// Returns path package directory.
    var packageDirectory: Path {
        Path(#file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
