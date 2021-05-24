import LiaDescription
import Foundation

public enum TemplateBundleError: Error {
    case cannotCreateEnumerator
    case invalidName
}
public struct TemplateBundle {
    let description: LocatedTemplateBundleDescription
    
    var name: String { description.name }
    let path: Path
    
    let sources: [Path]
    let templates: [Path]
    let headers: [Path]
    let unknowns: [Path]
    
    public init(from description: LocatedTemplateBundleDescription) throws {
        self.description = description
        
        let name = description.name
        guard !name.contains("/"), ![".", "..", "~"].contains(name) else {
            throw TemplateBundleError.invalidName
        }
        
        if let path = description.path {
            self.path = path
        } else {
            self.path = Path("Templates/").appending(pathComponent: name)
        }
        
        guard let enumerator = FileManager.default.enumerator(at: self.path.url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs) else {
            throw TemplateBundleError.cannotCreateEnumerator
        }
        
        var sources: [Path] = []
        var templates: [Path] = []
        var headers: [Path] = []
        var unknowns: [Path] = []
        
        for case let file as URL in enumerator {
            guard !file.hasDirectoryPath else { continue }
            let path = Path(unchecked: file)
            switch file.pathExtension {
            case "swift":
                sources.append(path)
            case "lia":
                templates.append(path)
            case "liah":
                headers.append(path)
            default:
                unknowns.append(path)
            }
        }
        
        self.sources = sources
        self.templates = templates
        self.headers = headers
        self.unknowns = unknowns
    }
}
