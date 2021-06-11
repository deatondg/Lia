import Foundation

extension LiaCache {
    typealias TemplateDescriptionContext = Path.FileStats
    
    public enum TemplateDescriptionError: Error {
        case descriptionFileMustHaveSwiftExtension
        case noManifestCreated
    }
    public func renderTemplateDescription(
        descriptionFile: Path,
        ignoreCache: Bool
    ) async throws -> (template: LocatedTemplateDescription, fromCache: Bool) {
        guard descriptionFile.extension == "swift" else {
            throw TemplateDescriptionError.descriptionFileMustHaveSwiftExtension
        }
        
        let context = try descriptionFile.stats()
        
        let fromCache: Bool
        let manifestName: String
        
        if !ignoreCache, let cachedDescription = self.templateDescriptionCache[context] {
            switch cachedDescription {
            case .inProgress(let handle):
                manifestName = try await handle.get()
            case .ready(let _manifestName):
                manifestName = _manifestName
            }
            
            fromCache = true
        } else {
            let handle = async { () -> String in
                let manifestName = self.newFile(withExtension: "json")
                do {
                    let artifact = Path.temporaryFile()
                    
                    try await LiaBuild.build(swiftc: swiftc, libDirectory: libDirectory, libs: ["LiaSupport", "TemplateDescription"], source: descriptionFile, destination: artifact)
                    
                    let manifest = cacheDirectory.appending(component: manifestName)
                    
                    try await artifact.run(withArguments: "--liaTemplateOutput", manifest.path).confirmEmpty()
                    
                    guard manifest.exists() else {
                        throw LiaDescriptionError.noManifestCreated
                    }

                    return manifestName
                } catch {
                    self.deleteFile(manifestName)
                    throw error
                }
            }
            
            templateDescriptionCache[context] = .inProgress(handle)
            
            manifestName = try await handle.get()
            
            templateDescriptionCache[context] = .ready(manifestName)
            
            fromCache = false
        }
        
        let manifest = cacheDirectory.appending(component: manifestName)
        
        let description = try JSONDecoder().decode(LocatedTemplateDescription.self, from: try Data(contentsOf: manifest))
        
        return (description, fromCache)
    }
}
