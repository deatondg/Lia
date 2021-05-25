import XCTest
@testable import LiaDescription
import LiaSupport
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
    
    func testIsItEvenPossibleToMakeBundles() {
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            templateExtension: {"template_extension"},
            headerExtension: {"header_extension"}
        )
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            templateExtension: {"template_extension"},
            headerExtension: .none()
        )
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            templateExtension: .none(),
            headerExtension: {"header_extension"}
        )
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            templateExtension: .none(),
            headerExtension: .none()
        )
        
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            unknownFileMethod: .error(),
            identifierConversionMethod: .fail()
        )
        
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            headerExtension: {"header_extension"},
            unknownFileMethod: .error(),
            identifierConversionMethod: .fail()
        )
        let _ = TemplateBundle.bundle(
            name: {"bundle"},
            headerExtension: .none(),
            unknownFileMethod: .error(),
            identifierConversionMethod: .fail()
        )
    }
    
    func testIsItEvenPossibleToMakeLocatedStringArrays() {
        let _ = LiaDescription(
            actions: [
                .render(bundles: {"bundle1"}, toPath: {"render_path"})
            ],
            bundles: []
        )
        let _ = LiaDescription(
            actions: [
                .render(bundles: {"bundle1"; "bundle2"}, toPath: {"render_path"})
            ],
            bundles: []
        )
        let _ = LiaDescription(
            actions: [
                .render(
                    bundles: {
                        "bundle1"
                    },
                    toPath: {"render_path"})
            ],
            bundles: []
        )
        let _ = LiaDescription(
            actions: [
                .render(
                    bundles: {
                        "bundle1"
                        "bundle2"
                    },
                    toPath: {"render_path"})
            ],
            bundles: []
        )
    }
 
    /// Returns path package directory.
    var packageDirectory: Path {
        Path(#file).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    }
}
