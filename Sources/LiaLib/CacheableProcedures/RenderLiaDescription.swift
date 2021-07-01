import Foundation

enum RenderLiaDescription<Token: Codable, Enviornment: RenderEnviornment>: CacheableProcedure {
    typealias Input = Path
    typealias Context = Path.FileStats
    typealias Output = LocatedLiaDescription
    typealias Entry = Token
    
    enum Error: Swift.Error {
        case descriptionFileMustHaveSwiftExtension
        case noManifestCreated
    }
    
    static func context(for input: Input) throws -> Path.FileStats {
        try input.stats()
    }
    
    static func create<C>(from input: Input, in cacher: C) async throws -> (Token, () async throws -> LocatedLiaDescription) where C: CacheWriter, C.Token == Token, C.Enviornment == Enviornment {
        guard input.extension == "swift" else {
            throw Error.descriptionFileMustHaveSwiftExtension
        }
        
        print("Here")
        let manifestToken = await cacher.newToken(withExtension: ".json")
        
        let artifact = Path.temporaryFile()

        try await LiaBuild.build(swiftc: cacher.enviornment.swiftc, libDirectory: cacher.enviornment.libDirectory, libs: ["LiaSupport", "LiaDescription"], source: input, destination: artifact)

        let manifest = cacher.path(for: manifestToken)

        try await artifact.run(withArguments: "--liaDescriptionOutput", manifest.path).confirmEmpty()

        guard manifest.exists() else {
            throw Error.noManifestCreated
        }

        return (manifestToken, { try await create(from: input, with: manifestToken, in: cacher) })
    }
    
    static func create<C>(from input: Input, with entry: Token, in cacher: C) async throws -> LocatedLiaDescription where C : CacheReader, Token == C.Token {
        try JSONDecoder().decode(LocatedLiaDescription.self, from: try Data(contentsOf: cacher.path(for: entry)))
    }
}
