import LiaSupport
import Foundation

public actor LiaCache {
    typealias FileToken = String
    struct Enviornment {
        private let cache: LiaCache
        
        init(_ cache: LiaCache) {
            self.cache = cache
        }
        
        var swiftc: Path { cache.swiftc }
        var libDirectory: Path { cache.libDirectory }
    }
    
    let cacheDirectory: Path

    let swiftc: Path
    let swiftVersion: SwiftVersion

    let libDirectory: Path
    let liaVersion: LiaVersion

    var cacheTable: CacheTable
    
    var savedFiles: Set<FileToken>
    var activeCachers: Set<Cacher>
    
    var occupiedFiles: Set<FileToken> {
        activeCachers.map(\.files).reduce(into: savedFiles, { $0.formUnion($1) })
    }
    
    // Handle the . correctly
    func newToken(withExtension `extension`: String? = nil) -> FileToken {
        let occupiedFiles = self.occupiedFiles
        
        var token: FileToken
        repeat {
            token = UUID().uuidString + (`extension` ?? "")
        } while occupiedFiles.contains(token)
        
        // TODO: Confirm file does not exist yet?
        return token
    }
    
    nonisolated func path(for token: FileToken) -> Path {
        cacheDirectory.appending(component: token)
    }
    
    class Cacher: CacheWriter, Hashable {
        typealias Token = FileToken
        typealias Enviornment = LiaCache.Enviornment
        
        let cache: LiaCache
        var files: Set<FileToken>
        
        init(_ cache: LiaCache) {
            self.cache = cache
            self.files = []
        }
        
        var enviornment: Enviornment { Enviornment(self.cache) }
        
        func newToken() async -> LiaCache.FileToken {
            await cache.newToken()
        }
        func newToken(withExtension `extension`: String) async -> FileToken {
            await cache.newToken(withExtension: `extension`)
        }
        
        func path(for token: FileToken) -> Path {
            cache.path(for: token)
        }
        
        static func == (lhs: Cacher, rhs: Cacher) -> Bool {
            lhs === rhs
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }
    }
    
    // TODO: ignoreCache, saveToCache
    // TODO: Remove nonisolated
    nonisolated
    func run<P>(_: P.Type, from input: P.Input) async throws -> P.Output where P: CacheableProcedure, P.Token == FileToken, P.Enviornment == Cacher.Enviornment {
        let context = try P.context(for: input)
        
        switch await cacheTable[P.self, context] {
        case nil:
            let cacher = Cacher(self)
            await self.insertCacher(cacher)
//            self.activeCachers.insert(cacher)
            defer { self.activeCachers.remove(cacher) }

            let entryTask = Task.detached { () async throws -> (P.Entry, Task<P.Output, Error>) in
                let (entry, continuation) = try await P.create(from: input, in: cacher)
                let task = Task.detached {
                    try await continuation()
                }
                return (entry, task)
            }

            await self.setCache(P.self, context: context, value: .stage0(entryTask))
            //cacheTable[P.self, context] = .stage0(entryTask)

            let (entry, task) = try await entryTask.value

            await self.setCache(P.self, context: context, value: .stage1(entry, task))
//            cacheTable[P.self, context] = .stage1(entry, task)

            let output = try await task.value

            await self.setCache(P.self, context: context, value: .ready(entry, output))
            await self.commitCacher(cacher)
//            cacheTable[P.self, context] = .ready(entry, output)
//            self.savedFiles.formUnion(cacher.files)

            return output
        case .saved(let entry):
            let cacher = Cacher(self)
            await self.insertCacher(cacher)
//            self.activeCachers.insert(cacher)
            defer { self.activeCachers.remove(cacher) }

            let task = Task.detached {
                try await P.create(from: input, with: entry, in: cacher)
            }

            await self.setCache(P.self, context: context, value: .stage1(entry, task))
//            cacheTable[P.self, context] = .stage1(entry, task)

            let output = try await task.value

            await self.setCache(P.self, context: context, value: .ready(entry, output))
            await self.commitCacher(cacher)
//            cacheTable[P.self, context] = .ready(entry, output)
//            self.savedFiles.formUnion(cacher.files)

            return output
        case .stage0(let task):
            let (_, task) = try await task.value
            return try await task.value
        case .stage1(_, let task):
            return try await task.value
        case .ready(_, let output):
            return output
        }
    }
    
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

        async let swiftVersion = try await SwiftVersion(ofExecutable: swiftc)
        async let liaVersion = timeIt(name: "liaVersion") { try await LiaVersion(ofLibDirectory: libDirectory, swiftc: swiftc) }
       
        self.swiftVersion = try await swiftVersion
        self.liaVersion = try await liaVersion

        self.cacheTable = CacheTable()
        
        self.savedFiles = []
        self.activeCachers = []
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
        
        self.cacheTable = CacheTable(dataModel.cacheTable)

        self.savedFiles = dataModel.savedFiles
        self.activeCachers = []
    }
//    public convenience init(forNewOrExistingDirectory cacheDirectory: Path, swiftc: Path, libDirectory: Path) async throws {
//        do {
//            try await self.init(forNewDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
//        } catch {
//            try await self.init(forExistingDirectory: cacheDirectory, swiftc: swiftc, libDirectory: libDirectory)
//        }
//    }
    
    static var cacheFileName: String = "LiaCache.json"
    static func cacheFile(forCacheDirectory cacheDirectory: Path) -> Path { cacheDirectory.appending(component: LiaCache.cacheFileName) }
    var cacheFile: Path { LiaCache.cacheFile(forCacheDirectory: self.cacheDirectory) }

    public func save() throws {
        let dataModel = LiaCacheDataModel(
            swiftVersion: self.swiftVersion,
            liaVersion: self.liaVersion,
            cacheTable: self.cacheTable.dataModel,
            savedFiles: self.savedFiles
        )

        try JSONEncoder().encode(dataModel).write(to: self.cacheFile)
    }
}

public class LiaCacheDataModel: Codable {
    let swiftVersion: SwiftVersion
    
    let liaVersion: LiaVersion
   
    let cacheTable: CacheTableDataModel
    
    let savedFiles: Set<String>
    
    init(
        swiftVersion: SwiftVersion,
        liaVersion: LiaVersion,
        cacheTable: CacheTableDataModel,
        savedFiles: Set<String>
    ) {
        self.swiftVersion = swiftVersion
        self.liaVersion = liaVersion
        self.cacheTable = cacheTable
        self.savedFiles = savedFiles
    }
}
