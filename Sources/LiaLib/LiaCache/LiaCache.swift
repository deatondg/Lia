import LiaSupport
import Foundation

public final class LiaCache: Codable {
    let cacheDirectory: Path
    
    let swiftc: Path
    let swiftVersion: SwiftVersion
    
    let libDirectory: Path
    let liaVersion: LiaVersion
    
    private var usedFiles: Set<String>
    private func newFile(withExtension extension: String) -> String {
        var fileName: String
        repeat {
            fileName = UUID().uuidString + ".extension"
        } while usedFiles.contains(fileName)
        usedFiles.insert(fileName)
        // TODO: Confirm file does not exist yet
        return fileName
    }
    private func deleteFile(_ fileName: String) {
        if let _ = usedFiles.remove(fileName) {
            let path = cacheDirectory.appending(component: fileName)
            if path.exists() {
                // TODO: Is this a good idea?
                try! cacheDirectory.appending(component: fileName).deleteFromFilesystem()
            }
        }
    }
    
    private static var cacheFileName: String = "LiaCache.json"
    private static func cacheFile(forCacheDirectory cacheDirectory: Path) -> Path { cacheDirectory.appending(component: LiaCache.cacheFileName) }
    private var cacheFile: Path { LiaCache.cacheFile(forCacheDirectory: self.cacheDirectory) }
    
    public enum LiaCacheError: Error {
        case missingCacheFile
        case cacheDirectoryNotEmpty
        case outdatedCache
    }
    public init(forNewDirectory cacheDirectory: Path, swiftc: Path, libDirectory: Path) async throws {
        try cacheDirectory.createDirectory(withIntermediateDirectories: true)
        self.cacheDirectory = cacheDirectory
        
        guard try cacheDirectory.children().isEmpty else {
            throw LiaCacheError.cacheDirectoryNotEmpty
        }
        
        self.swiftc = swiftc
        self.swiftVersion = try await SwiftVersion(ofExecutable: swiftc)
        
        self.libDirectory = libDirectory
        self.liaVersion = try await LiaVersion(ofLibDirectory: libDirectory, swiftc: swiftc)
        
        self.usedFiles = []
        
        self.liaDescriptionCache = [:]
        self.templateDescriptionCache = [:]
        self.templateHeaderAndBodyCache = [:]
    }
    public convenience init(forExistingDirectory cacheDirectory: Path) throws {
        let cacheFile = LiaCache.cacheFile(forCacheDirectory: cacheDirectory)
        guard cacheFile.exists() else {
            throw LiaCacheError.missingCacheFile
        }
        
        try self.init(from: Data(contentsOf: cacheFile))
        
        guard self.cacheDirectory == cacheDirectory else {
            print(self.cacheDirectory)
            print(cacheDirectory)
            throw LiaCacheError.outdatedCache
        }
    }
    public convenience init(forNewOrExistingDirectory cacheDirectory: Path, swiftc: Path, libDirectory: Path) async throws {
        do {
            try await self.init(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        } catch {
            try self.init(forExistingDirectory: cacheDirectory)
            guard
                self.swiftc == swiftc,
                try await self.swiftVersion == SwiftVersion(ofExecutable: swiftc),
                self.libDirectory == libDirectory,
                try await self.liaVersion == LiaVersion(ofLibDirectory: libDirectory, swiftc: swiftc)
            else {
                // TODO: More info in this error, maybe recovery
                throw LiaCacheError.outdatedCache
            }
        }
    }
    
    private typealias LiaDescriptionContext = Path.FileStats
    private var liaDescriptionCache: [LiaDescriptionContext: String]
    
    public enum LiaDescriptionError: Error {
        case descriptionFileMustHaveSwiftExtension
        case noManifestCreated
    }
    public func renderLiaDescription(
        descriptionFile: Path,
        ignoreCache: Bool,
        saveHash: Bool,
        tee: Bool = false
    ) async throws -> (description: LocatedLiaDescription, fromCache: Bool) {
        guard descriptionFile.extension == "swift" else {
            throw LiaDescriptionError.descriptionFileMustHaveSwiftExtension
        }
        
        let context = try descriptionFile.stats()
        
        if let cachedDescription = self.liaDescriptionCache[context], !ignoreCache {
            return (try JSONDecoder().decode(LocatedLiaDescription.self, from: Data(contentsOf: cacheDirectory.appending(component: cachedDescription))), fromCache: true)
        } else {
            let manifestName = self.newFile(withExtension: "json")
            do {
                let artifact = Path.temporaryFile()
                
                try await LiaBuild.build(swiftc: swiftc, libDirectory: libDirectory, libs: ["LiaSupport", "LiaDescription"], source: descriptionFile, destination: artifact)
                
                let manifest = cacheDirectory.appending(components: manifestName)
                
                try await artifact.run(withArguments: "--liaDescriptionOutput", manifest.path).confirmEmpty()
                
                let description = try JSONDecoder().decode(LocatedLiaDescription.self, from: try Data(contentsOf: manifest))
                
                if saveHash {
                    liaDescriptionCache[context] = manifestName
                } else {
                    self.deleteFile(manifestName)
                }
                
                return (description, fromCache: false)
            } catch {
                self.deleteFile(manifestName)
                throw error
            }
        }
    }
    
    private typealias TemplateDescriptionContext = Path.FileStats
    private var templateDescriptionCache: [TemplateDescriptionContext: String]
    
    public enum TemplateDescriptionError: Error {
        case descriptionFileMsutHaveSwiftExtension
        case noManifestCreated
    }
    public func renderTemplateDescription(
        descriptionFile: Path,
        ignoreCache: Bool,
        saveHash: Bool,
        tee: Bool = false
    ) async throws -> (template: LocatedTemplateDescription, fromCache: Bool) {
        guard descriptionFile.extension == "swift" else {
            throw TemplateDescriptionError.descriptionFileMsutHaveSwiftExtension
        }
        
        let context = try descriptionFile.stats()
        
        if let cachedDescription = self.templateDescriptionCache[context], !ignoreCache {
            return (try JSONDecoder().decode(LocatedTemplateDescription.self, from: Data(contentsOf: cacheDirectory.appending(component: cachedDescription))), fromCache: true)
        } else {
            let manifestName = self.newFile(withExtension: "json")
            do {
                let artifact = Path.temporaryFile()
                
                try await LiaBuild.build(swiftc: swiftc, libDirectory: libDirectory, libs: ["LiaSupport", "TemplateDescription"], source: descriptionFile, destination: artifact)
                
                let manifest = cacheDirectory.appending(component: manifestName)
                
                try await artifact.run(withArguments: "--liaTemplateOutput", manifest.path).confirmEmpty()
                
                let description = try JSONDecoder().decode(LocatedTemplateDescription.self, from: try Data(contentsOf: manifest))
                
                if saveHash {
                    templateDescriptionCache[context] = manifestName
                } else {
                    self.deleteFile(manifestName)
                }
                
                return (description, fromCache: true)
            } catch {
                self.deleteFile(manifestName)
                throw error
            }
        }
    }
    
    private struct TemplateHeaderAndBodyContext: Hashable, Codable {
        let header: Path.FileStats?
        let template: Path.FileStats
        let allowInlineHeaders: Bool
    }
    private struct TemplateHeaderAndBodyLocation: Hashable, Codable {
        enum Location: Hashable, Codable {
            case cacheFile(String)
            case inputFile
        }
        let header: Location?
        let body: Location
    }
    private var templateHeaderAndBodyCache: [TemplateHeaderAndBodyContext: TemplateHeaderAndBodyLocation]
    
    public func extractTemplateHeaderAndBody(
        headerFile: Path?,
        templateFile: Path,
        allowInlineHeaders: Bool,
        ignoreCache: Bool,
        saveHash: Bool
    ) throws -> (header: Path?, body: Path) {
        let context = TemplateHeaderAndBodyContext(
            header: try headerFile?.stats(),
            template: try templateFile.stats(),
            allowInlineHeaders: allowInlineHeaders
        )
        
        if let cachedResult = templateHeaderAndBodyCache[context], !ignoreCache {
            let header: Path?
            switch cachedResult.header {
            case nil:
                header = nil
            case .cacheFile(let fileName):
                header = cacheDirectory.appending(component: fileName)
            case .inputFile:
                // We should only have cached .inputFile for an actual input file.
                assert(headerFile != nil)
                header = headerFile
            }
            
            let body: Path
            switch cachedResult.body {
            case .cacheFile(let fileName):
                body = cacheDirectory.appending(component: fileName)
            case .inputFile:
                body = templateFile
            }
            
            return (header, body)
        } else {
            fatalError()
        }
    }
    
    public func save() throws {
        try JSONEncoder().encode(self).write(to: self.cacheFile)
    }
}
