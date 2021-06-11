extension LiaCache {
    struct TemplateHeaderAndBodyContext: Hashable, Codable {
        let template: Path.FileStats
        let includedHeader: Bool
        let allowInlineHeader: Bool
    }
    struct TemplateHeaderAndBodyLocation: Hashable, Codable {
        enum Location: Hashable, Codable {
            case cacheFile(String)
            case inputFile
        }
        let header: Location?
        let body: Location
    }
    
    public func extractTemplateHeaderAndBody(
        headerFile: Path?,
        templateFile: Path,
        allowInlineHeader: Bool,
        ignoreCache: Bool
    ) async throws -> (header: Path?, body: Path, fromCache: Bool) {
        let context = TemplateHeaderAndBodyContext(
            template: try templateFile.stats(),
            includedHeader: headerFile != nil,
            allowInlineHeader: allowInlineHeader
        )
        
        let location: TemplateHeaderAndBodyLocation
        let fromCache: Bool
        
        if !ignoreCache, let cachedResult = templateHeaderAndBodyCache[context] {
            switch cachedResult {
            case .inProgress(let handle):
                location = try await handle.get()
            case .ready(let _location):
                location = _location
            }
            
            fromCache = true
        } else {
        innerIf:
            if headerFile != nil || !allowInlineHeader {
                location = .init(header: .inputFile, body: .inputFile)
            } else {
                let string = try String(contentsOf: templateFile)
                let header: String
                let body: String
                do {
                    ((header, body), _) = try TemplateHeaderAndBodyParser().parse(from: string)
                } catch TemplateHeaderAndBodyParserFailure.noHeader {
                    location = .init(header: nil, body: .inputFile)
                    break innerIf
                }
                let headerName = self.newFile(withExtension: ".swift")
                let bodyName = self.newFile(withExtension: ".lia")
                
                do {
                    try header.write(to: cacheDirectory.appending(component: headerName))
                    try body.write(to: cacheDirectory.appending(component: bodyName))
                } catch {
                    self.deleteFile(headerName)
                    self.deleteFile(bodyName)
                    throw error
                }
                
                location = .init(header: .cacheFile(headerName), body: .cacheFile(bodyName))
            }
            
            self.templateHeaderAndBodyCache[context] = .ready(location)
            fromCache = false
        }
        
        let header: Path?
        switch location.header {
        case nil:
            header = nil
        case .cacheFile(let headerName):
            header = cacheDirectory.appending(component: headerName)
        case .inputFile:
            // We should only have .inputFile for an actual input file.
            assert(headerFile != nil)
            header = headerFile
        }
        
        let body: Path
        switch location.body {
        case .cacheFile(let bodyName):
            body = cacheDirectory.appending(component: bodyName)
        case .inputFile:
            body = templateFile
        }
        
        return (header, body, fromCache)
    }
}
