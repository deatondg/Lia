import XCTest
@testable import LiaLib

final class LiaLibTests: XCTestCase {
    func testSwiftVersion() throws {
        let version = try Path.executable(named: "swift").runSync(withArguments: "--version").extractOutput()
        XCTAssert(version.starts(with: "Apple Swift version 5.4"))
    }
    
    /// Returns path package directory.
    var packageDirectory: Path {
        Path(#file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
