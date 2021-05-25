import LiaSupport
import LiaDescription
//import PackageDescription
import Foundation

enum TemplateBundleError: Error {
    case nameMustBeNonempty(LocatedTemplateBundleDescription)
    case pathMustBeSpecifiedWhenNameIsInvalidPathComponent(LocatedTemplateBundleDescription)
    case templateExtensionCannotBeSwiftWhenSourcesAreIncluded(LocatedTemplateBundleDescription)
    case headerExtensionCannotBeSwiftWhenSourcesAreIncluded(LocatedTemplateBundleDescription)
    case templateExtensionAndHeaderExtensionMustDiffer(LocatedTemplateBundleDescription)
    case extraWhitespaceInDefaultParameters(LocatedTemplateBundleDescription)
    case defaultSyntaxError(Error, LocatedTemplateBundleDescription)
}
struct TemplateBundle {
    let originalDescription: LocatedTemplateBundleDescription?
    
    let name: String
    let path: Path
    //let dependencies: [Target.Dependency]
    let includeSources: Bool
    let allowInlineHeaders: Bool
    let templateExtension: String
    let headerExtension: String?
    let unknownFileMethod: UnknownFileMethod
    let ignoreDotFiles: Bool
    let identifierConversionMethod: IdentifierConversionMethod
    let defaultParameters: String
    let defaultSyntax: Syntax
    
    init(name: String,
         path: Path,
         //dependencies: [Target.Dependency],
         includeSources: Bool,
         allowInlineHeaders: Bool,
         templateExtension: String,
         headerExtension: String?,
         unknownFileMethod: UnknownFileMethod,
         ignoreDotFiles: Bool,
         identifierConversionMethod: IdentifierConversionMethod,
         defaultParameters: String,
         defaultSyntax: Syntax
    ) {
        self.originalDescription = nil
        self.name = name
        self.path = path
        //self.dependencies = dependencies
        self.includeSources = includeSources
        self.allowInlineHeaders = allowInlineHeaders
        self.templateExtension = templateExtension
        self.headerExtension = headerExtension
        self.unknownFileMethod = unknownFileMethod
        self.ignoreDotFiles = ignoreDotFiles
        self.identifierConversionMethod = identifierConversionMethod
        self.defaultParameters = defaultParameters
        self.defaultSyntax = defaultSyntax
    }
    
    init(fromDescription description: LocatedTemplateBundleDescription) throws {
        self.originalDescription = description
        
        let name = description.name.value
        guard !name.isEmpty else {
            throw TemplateBundleError.nameMustBeNonempty(description)
        }
        self.name = name
        
        if let pathString = description.path?.value {
            self.path = Path(pathString)
        } else {
            guard !name.contains("/"), !["", ".", "..", "~"].contains(name) else {
                throw TemplateBundleError.pathMustBeSpecifiedWhenNameIsInvalidPathComponent(description)
            }
            self.path = Path("Templates").appending(pathComponent: name)
        }
        
        self.allowInlineHeaders = description.allowInlineHeaders?.value ?? true
        
        let includeSources = description.includeSources?.value ?? true
        self.includeSources = includeSources
        
        let templateExtension = description.templateExtension?.value ?? "lia"
        let headerExtension: String?
        if let locatedHeaderExtension = description.headerExtension {
            headerExtension = locatedHeaderExtension.value
        } else {
            headerExtension = "liah"
        }
        
        if includeSources {
            guard templateExtension != "swift" else {
                throw TemplateBundleError.templateExtensionCannotBeSwiftWhenSourcesAreIncluded(description)
            }
            guard headerExtension != "swift" else {
                throw TemplateBundleError.headerExtensionCannotBeSwiftWhenSourcesAreIncluded(description)
            }
        }
        guard templateExtension != headerExtension else {
            throw TemplateBundleError.templateExtensionAndHeaderExtensionMustDiffer(description)
        }
        
        self.templateExtension = templateExtension
        self.headerExtension = headerExtension
        
        self.unknownFileMethod = description.unknownFileMethod?.value ?? .error
        self.ignoreDotFiles = description.ignoreDotFiles?.value ?? true
        
        self.identifierConversionMethod = description.identifierConversionMethod?.value ?? .replaceOrPrefixWithUnderscores
        
        self.defaultParameters = ""
        guard defaultParameters.trimmingCharacters(in: .whitespacesAndNewlines) == defaultParameters else {
            throw TemplateBundleError.extraWhitespaceInDefaultParameters(description)
        }
                
        do {
            self.defaultSyntax = try Syntax(fromDescription: description.defaultSyntax,
                                            defaultSyntax: Syntax(
                                                value: .init(open: "{{", close: "}}"),
                                                code: .init(open: "{%", close: "%}"),
                                                comment: .init(open: "{#", close: "#}")))
        } catch {
            throw TemplateBundleError.defaultSyntaxError(error, description)
        }
    }
}

/*
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
*/
