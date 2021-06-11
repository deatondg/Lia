import LiaSupport
import Foundation

public actor LiaCache {
    let cacheDirectory: Path
    
    let swiftc: Path
    let swiftVersion: SwiftVersion
    
    let libDirectory: Path
    let liaVersion: LiaVersion
    
    var usedFiles: Set<String>
    
    enum CacheEntry<T> {
        case inProgress(Task.Handle<T,Error>)
        case ready(T)
    }
    var liaDescriptionCache: [LiaDescriptionContext: CacheEntry<String>]
    var templateDescriptionCache: [TemplateDescriptionContext: CacheEntry<String>]
    var templateHeaderAndBodyCache: [TemplateHeaderAndBodyContext: CacheEntry<TemplateHeaderAndBodyLocation>]

    
    static var cacheFileName: String = "LiaCache.json"
    static func cacheFile(forCacheDirectory cacheDirectory: Path) -> Path { cacheDirectory.appending(component: LiaCache.cacheFileName) }
    var cacheFile: Path { LiaCache.cacheFile(forCacheDirectory: self.cacheDirectory) }
    
    
    public enum LiaCacheError: Error {
        case missingCacheFile
        case cacheDirectoryNotEmpty
        case outdatedCache
        case cannotSaveWhileCacheInProgress
    }
    public init(forNewDirectory cacheDirectory: Path, swiftc: Path, libDirectory: Path) async throws {
        try cacheDirectory.createDirectory(withIntermediateDirectories: true)
        self.cacheDirectory = cacheDirectory
        
        guard try cacheDirectory.children().isEmpty else {
            throw LiaCacheError.cacheDirectoryNotEmpty
        }
        
        self.swiftc = swiftc
        self.libDirectory = libDirectory
        
        async let swiftVersion = SwiftVersion(ofExecutable: swiftc)
        async let liaVersion = LiaVersion(ofLibDirectory: libDirectory, swiftc: swiftc)
        
        self.swiftVersion = try await swiftVersion
        self.liaVersion = try await liaVersion
        
        self.usedFiles = []
        
        self.liaDescriptionCache = [:]
        self.templateDescriptionCache = [:]
        self.templateHeaderAndBodyCache = [:]
    }
    public init(forExistingDirectory cacheDirectory: Path, swiftc: Path, libDirectory: Path) async throws {
        let cacheFile = LiaCache.cacheFile(forCacheDirectory: cacheDirectory)
        guard cacheFile.exists() else {
            throw LiaCacheError.missingCacheFile
        }
        
        self.cacheDirectory = cacheDirectory
        self.swiftc = swiftc
        self.libDirectory = libDirectory
        
        async let swiftVersion = SwiftVersion(ofExecutable: swiftc)
        async let liaVersion = LiaVersion(ofLibDirectory: libDirectory, swiftc: swiftc)
        
        let dataModel = try JSONDecoder().decode(LiaCacheDataModel.self, from: Data(contentsOf: cacheFile))
        
        self.swiftVersion = try await swiftVersion
        self.liaVersion = try await liaVersion
        
        guard self.swiftVersion == dataModel.swiftVersion,
              self.liaVersion == dataModel.liaVersion
        else {
            // TODO: More info in this error, maybe recovery
            throw LiaCacheError.outdatedCache
        }
        
        self.usedFiles = dataModel.usedFiles
        self.liaDescriptionCache = dataModel.liaDescriptionCache.mapValues(CacheEntry.ready)
        self.templateDescriptionCache = dataModel.templateDescriptionCache.mapValues(CacheEntry.ready)
        self.templateHeaderAndBodyCache = dataModel.templateHeaderAndBodyCache.mapValues(CacheEntry.ready)
    }
    public convenience init(forNewOrExistingDirectory cacheDirectory: Path, swiftc: Path, libDirectory: Path) async throws {
        do {
            try await self.init(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        } catch {
            try await self.init(forExistingDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
        }
    }
    
    public func save() throws {
        let dataModel = LiaCacheDataModel(
            swiftVersion: self.swiftVersion,
            liaVersion: self.liaVersion,
            usedFiles: self.usedFiles,
            liaDescriptionCache: try self.liaDescriptionCache
                .mapValues({
                    guard case let .ready(cachedResult) = $0 else {
                        throw LiaCacheError.cannotSaveWhileCacheInProgress
                    }
                    return cachedResult
                }),
            templateDescriptionCache: try self.templateDescriptionCache
                .mapValues({
                    guard case let .ready(cachedResult) = $0 else {
                        throw LiaCacheError.cannotSaveWhileCacheInProgress
                    }
                    return cachedResult
                }),
            templateHeaderAndBodyCache: try self.templateHeaderAndBodyCache
                .mapValues({
                    guard case let .ready(cachedResult) = $0 else {
                        throw LiaCacheError.cannotSaveWhileCacheInProgress
                    }
                    return cachedResult
                })
        )
        
        try JSONEncoder().encode(dataModel).write(to: self.cacheFile)
    }
}
