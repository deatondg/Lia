import XCTest
import class Foundation.Bundle
import LiaSupport
import LiaLib

final class LiaTests: XCTestCase {
    func testExample() throws {
        let lia = productsDirectory.appending(pathComponent: "lia")
        
        let output = try lia.runSync().extractOutput()

        XCTAssertEqual(output, "Hello, world!\n")
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
    
    /// Returns path package directory.
    var packageDirectory: Path {
        Path(#file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
