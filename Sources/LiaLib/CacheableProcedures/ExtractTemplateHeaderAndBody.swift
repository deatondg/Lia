enum ExtractTemplateHeaderAndBodyEntryLocation<Token: Codable>: Codable {
    case cacheFile(Token)
    case inputFile
}
struct ExtractTemplateHeaderAndBodyEntry<Token: Codable>: Codable {
    typealias Location = ExtractTemplateHeaderAndBodyEntryLocation<Token>
    let header: Location?
    let body: Location
}

enum ExtractTemplateHeaderAndBody<Token: Codable, Enviornment>: CacheableProcedure {
    struct Input {
        let header: Path?
        let template: Path
        let allowInlineHeader: Bool
    }
    struct Context: Codable, Hashable {
        let template: Path.FileStats
        let includedHeader: Bool
        let allowInlineHeader: Bool
    }
    
    struct Output {
        let header: Path?
        let body: String
    }
    typealias Entry = ExtractTemplateHeaderAndBodyEntry<Token>
    
    static func context(for input: Input) throws -> Context {
        Context(template: try input.template.stats(), includedHeader: input.header != nil, allowInlineHeader: input.allowInlineHeader)
    }
    
    static func create<C>(from input: Input, in cacher: C) async throws -> (Entry, () async throws -> Output) where C : CacheWriter, Enviornment == C.Enviornment, Token == C.Token {
        if input.header != nil || !input.allowInlineHeader {
            let entry = Entry(header: .inputFile, body: .inputFile)
            return (entry, { try await create(from: input, with: entry, in: cacher) })
        } else {
            let string = try String(contentsOf: input.template)
            
            let header: String
            let body: String
            
            do {
                ((header, body), _) = try TemplateHeaderAndBodyParser().parse(from: string)
            } catch TemplateHeaderAndBodyParserFailure.noHeader {
                let entry = Entry(header: nil, body: .inputFile)
                return (entry, { try await create(from: input, with: entry, in: cacher) })
            }
            
            let headerToken = await cacher.newToken(withExtension: ".swift")
            let bodyToken = await cacher.newToken(withExtension: ".lia")
            
            try header.write(to: cacher.path(for: headerToken))
            try body.write(to: cacher.path(for: bodyToken))
            
            let entry = Entry(header: .cacheFile(headerToken), body: .cacheFile(bodyToken))
            let output = Output(header: cacher.path(for: headerToken), body: body)
            return (entry, { output })
        }
    }
    static func create<C>(from input: Input, with entry: Entry, in cacher: C) async throws -> Output where C : CacheReader, Token == C.Token {
        let header: Path?
        switch entry.header {
        case nil:
            header = nil
        case .inputFile:
            // We should only have .inputFile for an actual input file.
            assert(input.header != nil)
            header = input.header
        case .cacheFile(let token):
            header = cacher.path(for: token)
        }

        let bodyFile: Path
        switch entry.body {
        case .inputFile:
            bodyFile = input.template
        case .cacheFile(let token):
            bodyFile = cacher.path(for: token)
        }
        let body = try String(contentsOf: bodyFile)

        return Output(header: header, body: body)
    }
}
