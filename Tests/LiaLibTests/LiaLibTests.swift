import XCTest
@testable import LiaLib

final class LiaLibTests: XCTestCase {
    func testDescriptionCaching() async throws {
        let cacheDirectory = try Path.temporaryDirectory()
        let swiftc = try await Path.executable(named: "swiftc")
        
        var cache = try await LiaCache(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        let description1 = try await cache.renderLiaDescription(
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
        
        let description2 = try await cache.renderLiaDescription(
            descriptionFile: packageDirectory.appending(components: "Fixtures", "LiaDescriptions", "FullDescription.swift"),
            ignoreCache: false,
            saveHash: true,
            tee: true
        )
        
        XCTAssertEqual(description1.description, description2.description)
        XCTAssertTrue(description2.fromCache)
    }
    
    func testTemplateCaching() async throws {
        let cacheDirectory = try Path.temporaryDirectory()
        let swiftc = try await Path.executable(named: "swiftc")
        
        var cache = try await LiaCache(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        let template1 = try await cache.renderTemplateDescription(
            descriptionFile: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift"),
            ignoreCache: true,
            saveHash: true,
            tee: true
        )
        try cache.save()
        
        cache = try LiaCache(forExistingDirectory: cacheDirectory)
        XCTAssertEqual(cache.cacheDirectory, cacheDirectory)
        XCTAssertEqual(cache.swiftc, swiftc)
        XCTAssertEqual(cache.libDirectory, libDirectory)
        
        let template2 = try await cache.renderTemplateDescription(
            descriptionFile: packageDirectory.appending(components: "Fixtures", "TemplateDescriptions", "FullTemplate.swift"),
            ignoreCache: false,
            saveHash: true,
            tee: true
        )
        
        XCTAssertEqual(template1.template, template2.template)
        XCTAssertTrue(template2.fromCache)
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
            //try! Path.executable(named: "swift").run(inDirectory: packageDirectory, withArguments: "build", tee: true)
            fatalError()
        }
    }
}
