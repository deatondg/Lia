import XCTest
@testable import LiaLib

final class LiaLibTests: XCTestCase {
    func testDescriptionCaching() throws {
        let cacheDirectory = try Path.temporaryDirectory()
        let swiftc = try Path.executable(named: "swiftc")
        
        var cache = try LiaCache(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        let description1 = try cache.renderLiaDescription(
            descriptionFile: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "FullDescription.swift"),
            ignoreCache: true,
            saveHash: true,
            tee: true
        )
        try cache.save()
        
        cache = try LiaCache(forExistingDirectory: cacheDirectory)
        XCTAssertEqual(cache.cacheDirectory, cacheDirectory)
        XCTAssertEqual(cache.swiftc, swiftc)
        XCTAssertEqual(cache.libDirectory, libDirectory)
        
        let description2 = try cache.renderLiaDescription(
            descriptionFile: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "FullDescription.swift"),
            ignoreCache: false,
            saveHash: true,
            tee: true
        )
        
        XCTAssertEqual(description1.description, description2.description)
        XCTAssertTrue(description2.fromCache)
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
