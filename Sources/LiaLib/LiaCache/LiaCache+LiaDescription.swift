import Foundation

extension LiaCache {
    typealias LiaDescriptionContext = Path.FileStats
    
    public enum LiaDescriptionError: Error {
        case descriptionFileMustHaveSwiftExtension
        case noManifestCreated
    }
    public func renderLiaDescription(
        descriptionFile: Path,
        ignoreCache: Bool
    ) async throws -> (description: LocatedLiaDescription, fromCache: Bool) {
        guard descriptionFile.extension == "swift" else {
            throw LiaDescriptionError.descriptionFileMustHaveSwiftExtension
        }
        
        let context = try descriptionFile.stats()
        
        let fromCache: Bool
        let manifestName: String
        
        if !ignoreCache, let cachedDescription = self.liaDescriptionCache[context] {
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
                    
                    try await LiaBuild.build(swiftc: swiftc, libDirectory: libDirectory, libs: ["LiaSupport", "LiaDescription"], source: descriptionFile, destination: artifact)
                    
                    let manifest = cacheDirectory.appending(components: manifestName)
                    
                    try await artifact.run(withArguments: "--liaDescriptionOutput", manifest.path).confirmEmpty()
                    
                    guard manifest.exists() else {
                        throw LiaDescriptionError.noManifestCreated
                    }
                    
                    return manifestName
                } catch {
                    self.deleteFile(manifestName)
                    throw error
                }
            }
            
            self.liaDescriptionCache[context] = .inProgress(handle)
            
            manifestName = try await handle.get()
            
            self.liaDescriptionCache[context] = .ready(manifestName)
            
            fromCache = false
        }
        
        let manifest = cacheDirectory.appending(component: manifestName)
        
        let description = try JSONDecoder().decode(LocatedLiaDescription.self, from: try Data(contentsOf: manifest))
        
        return (description, fromCache)
    }
}
