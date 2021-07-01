import Foundation

enum RenderTemplateDescription<Token: Codable, Enviornment: RenderEnviornment>: CacheableProcedure {
    typealias Input = Path
    typealias Context = Path.FileStats
    typealias Output = LocatedTemplateDescription
    typealias Entry = Token
    
    enum Error: Swift.Error {
        case descriptionFileMustHaveSwiftExtension
        case noManifestCreated
    }
    
    static func context(for input: Input) throws -> Path.FileStats {
        try input.stats()
    }
    
    static func create<C>(from input: Input, in cacher: C) async throws -> (Token, () async throws -> LocatedTemplateDescription) where C: CacheWriter, C.Token == Token, C.Enviornment == Enviornment {
        guard input.extension == "swift" else {
            throw Error.descriptionFileMustHaveSwiftExtension
        }
        
        print("Here")
        let manifestToken = await cacher.newToken(withExtension: ".json")
        
        let artifact = Path.temporaryFile()

        try await LiaBuild.build(swiftc: cacher.enviornment.swiftc, libDirectory: cacher.enviornment.libDirectory, libs: ["LiaSupport", "TemplateDescription"], source: input, destination: artifact)
        
        let manifest = cacher.path(for: manifestToken)

        try await artifact.run(withArguments: "--liaTemplateOutput", manifest.path).confirmEmpty()

        guard manifest.exists() else {
            throw Error.noManifestCreated
        }

        return (manifestToken, { try await create(from: input, with: manifestToken, in: cacher) })
    }
    
    static func create<C>(from input: Input, with entry: Token, in cacher: C) async throws -> LocatedTemplateDescription where C : CacheReader, Token == C.Token {
        try JSONDecoder().decode(LocatedTemplateDescription.self, from: try Data(contentsOf: cacher.path(for: entry)))
    }
}
