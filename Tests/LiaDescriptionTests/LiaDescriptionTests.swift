import XCTest
@testable import LiaDescription
import LiaLib

final class LiaDescriptionTests: XCTestCase {
    func testFromFixtures() throws {
        let fixture = packageDirectory + "Fixtures/LiaDescriptionTests"
        let result = try Path.executable(named: "swift").runSync(inDirectory: fixture, withArguments: "test", tee: true)
        if let stderr = result.error,
              result.terminationReason == .exit,
              result.terminationStatus == 0,
              result.output != nil,
              stderr.split(separator: "\n").dropLast().last!.starts(with: "Test Suite \'All tests\' passed")
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
