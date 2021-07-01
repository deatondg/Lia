import XCTest
@testable import LiaLib

final class LiaLibTests: XCTestCase {
    let cache = unsafeWaitFor {
        try! await LiaCache(
            forNewDirectory: Path.temporaryDirectory(),
            swiftc: Path.executable(named: "swiftc"),
            libDirectory: libDirectory)
    }
    
    func testDescriptionCaching() async throws {
        let cacheDirectory = try Path.temporaryDirectory()
        let swiftc = try await Path.executable(named: "swiftc")
        
        var cache = try await LiaCache(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        let description1 = try await cache.run(RenderLiaDescription.self, from: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "FullDescription.swift"))

        try await cache.save()
        
        cache = try await LiaCache(forExistingDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        XCTAssertEqual(cache.cacheDirectory, cacheDirectory)
        XCTAssertEqual(cache.swiftc, swiftc)
        XCTAssertEqual(cache.libDirectory, libDirectory)
        
        let description2 = try await cache.run(RenderLiaDescription.self, from: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "FullDescription.swift"))

        XCTAssertEqual(description1, description2)
        //XCTAssertTrue(description2.fromCache)
    }
    
    func testTemplateCaching() async throws {
        let cacheDirectory = try Path.temporaryDirectory()
        let swiftc = try await Path.executable(named: "swiftc")
        
        var cache = try await LiaCache(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        let template1 = try await cache.run(RenderTemplateDescription.self, from: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift"))
        
        try await cache.save()
        
        cache = try await LiaCache(forExistingDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        XCTAssertEqual(cache.cacheDirectory, cacheDirectory)
        XCTAssertEqual(cache.swiftc, swiftc)
        XCTAssertEqual(cache.libDirectory, libDirectory)
        
        let template2 = try await cache.run(RenderTemplateDescription.self, from: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift"))

        XCTAssertEqual(template1, template2)
        //XCTAssertTrue(template2.fromCache)
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
    
    override class func setUp() {
        super.setUp()
        
        let xcodeTestVars = ["OS_ACTIVITY_DT_MODE", "XCTestSessionIdentifier", "XCTestBundlePath", "XCTestConfigurationFilePath"]
        if xcodeTestVars.contains(where: ProcessInfo.processInfo.environment.keys.contains) {
            unsafeWaitFor {
                try! await Path.executable(named: "swift").run(inDirectory: packageDirectory, withArguments: "build", tee: true)
            }
        }
    }
}
