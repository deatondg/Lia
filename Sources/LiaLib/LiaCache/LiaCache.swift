import LiaSupport
import Foundation
import Crypto

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
    public init(forNewDirectory cacheDirectory: Path, swiftc: Path, libDirectory: Path) throws {
        try cacheDirectory.createDirectory(withIntermediateDirectories: true)
        self.cacheDirectory = cacheDirectory
        
        guard try cacheDirectory.children().isEmpty else {
            throw LiaCacheError.cacheDirectoryNotEmpty
        }
        
        self.swiftc = swiftc
        self.swiftVersion = try SwiftVersion(ofExecutable: swiftc)
        
        self.libDirectory = libDirectory
        self.liaVersion = try LiaVersion(ofLibDirectory: libDirectory, swiftc: swiftc)
        
        self.usedFiles = []
        
        self.liaDescriptions = [:]
        self.templateDescriptions = [:]
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
    public convenience init(forNewOrExistingDirectory cacheDirectory: Path, swiftc: Path, libDirectory: Path) throws {
        do {
            try self.init(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        } catch {
            try self.init(forExistingDirectory: cacheDirectory)
            guard
                self.swiftc == swiftc,
                try self.swiftVersion == SwiftVersion(ofExecutable: swiftc),
                self.libDirectory == libDirectory,
                try self.liaVersion == LiaVersion(ofLibDirectory: libDirectory, swiftc: swiftc)
            else {
                // TODO: More info in this error, maybe recovery
                throw LiaCacheError.outdatedCache
            }
        }
    }
    
    private struct LiaDescriptionContext: Hashable, Codable {
        let fileSize: Int
        let fileHash: LiaHash
    }
    private var liaDescriptions: [LiaDescriptionContext: String]
    
    public enum LiaDescriptionError: Error {
        case descriptionFileMustHaveSwiftExtension
        case noManifestCreated
    }
    public func renderLiaDescription(
        descriptionFile: Path,
        ignoreCache: Bool,
        saveHash: Bool,
        tee: Bool = false
    ) throws -> (description: LocatedLiaDescription, fromCache: Bool) {
        guard descriptionFile.extension == "swift" else {
            throw LiaDescriptionError.descriptionFileMustHaveSwiftExtension
        }
        
        let fileSizeAndHash = try descriptionFile.fileSizeAndHash()
        let context = LiaDescriptionContext(fileSize: fileSizeAndHash.size, fileHash: fileSizeAndHash.hash)
        
        if let cachedDescription = self.liaDescriptions[context], !ignoreCache {
            return (try JSONDecoder().decode(LocatedLiaDescription.self, from: Data(contentsOf: cacheDirectory.appending(component: cachedDescription))), fromCache: true)
        } else {
            let manifestName = self.newFile(withExtension: "json")
            do {
                let artifact = Path.temporaryFile()
                
                try LiaBuild.build(swiftc: swiftc, libDirectory: libDirectory, libs: ["LiaSupport", "LiaDescription"], source: descriptionFile, destination: artifact)
                
                let manifest = cacheDirectory.appending(components: manifestName)
                
                try artifact.runSync(withArguments: "--liaDescriptionOutput", manifest.path).confirmEmpty()
                
                let description = try JSONDecoder().decode(LocatedLiaDescription.self, from: try Data(contentsOf: manifest))
                
                if saveHash {
                    liaDescriptions[context] = manifestName
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
    
    private struct TemplateDescriptionContext: Hashable, Codable {
        let fileSize: Int
        let fileHash: LiaHash
    }
    private var templateDescriptions: [TemplateDescriptionContext: String]
    
    public enum TemplateDescriptionError: Error {
        case descriptionFileMsutHaveSwiftExtension
        case noManifestCreated
    }
    public func renderTemplateDescription(
        descriptionFile: Path,
        ignoreCache: Bool,
        saveHash: Bool,
        tee: Bool = false
    ) throws -> (template: LocatedTemplateDescription, fromCache: Bool) {
        guard descriptionFile.extension == "swift" else {
            throw TemplateDescriptionError.descriptionFileMsutHaveSwiftExtension
        }
        
        let fileSizeAndHash = try descriptionFile.fileSizeAndHash()
        let context = TemplateDescriptionContext(fileSize: fileSizeAndHash.size, fileHash: fileSizeAndHash.hash)
        
        if let cachedDescription = self.templateDescriptions[context], !ignoreCache {
            return (try JSONDecoder().decode(LocatedTemplateDescription.self, from: Data(contentsOf: cacheDirectory.appending(component: cachedDescription))), fromCache: true)
        } else {
            let manifestName = self.newFile(withExtension: "json")
            do {
                let artifact = Path.temporaryFile()
                
                try LiaBuild.build(swiftc: swiftc, libDirectory: libDirectory, libs: ["LiaSupport", "TemplateDescription"], source: descriptionFile, destination: artifact)
                
                let manifest = cacheDirectory.appending(component: manifestName)
                
                try artifact.runSync(withArguments: "--liaTemplateOutput", manifest.path).confirmEmpty()
                
                let description = try JSONDecoder().decode(LocatedTemplateDescription.self, from: try Data(contentsOf: manifest))
                
                if saveHash {
                    templateDescriptions[context] = manifestName
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
    
    public func save() throws {
        try JSONEncoder().encode(self).write(to: self.cacheFile)
    }
}
