import LiaSupport
import PackageDescription

public struct TemplateBundle: Equatable, Codable {
    public let name: Located<String>
    public let path: Located<String>?
    /// Fuck. Why doesn't this conform to decodable?
    //public let dependencies: Located<[Target.Dependency]>?
    public let includeSources: Located<Bool>?
    public let allowInlineHeaders: Located<Bool>?
    public let templateExtension: Located<String>?
    public let headerExtension: Located<Optional<String>>?
    public let unknownFileMethod: Located<UnknownFileMethod>?
    public let ignoreDotFiles: Located<Bool>?
    public let invalidIdentifierCharacterMethod: Located<InvalidIdentifierCharacterMethod>?
    public let defaultParameters: Located<String>?
    public let defaultSyntax: Syntax
    
    public init(
        name: Located<String>,
        path: Located<String>?,
        dependencies: Located<[Target.Dependency]>?,
        includeSources: Located<Bool>?,
        allowInlineHeaders: Located<Bool>?,
        templateExtension: Located<String>?,
        headerExtension: Located<Optional<String>>?,
        unknownFileMethod: Located<UnknownFileMethod>?,
        ignoreDotFiles: Located<Bool>?,
        invalidIdentifierCharacterMethod: Located<InvalidIdentifierCharacterMethod>?,
        defaultParameters: Located<String>?,
        defaultSyntax: Syntax
    ) {
        self.name = name
        self.path = path
        //self.dependencies = dependencies
        self.includeSources = includeSources
        self.allowInlineHeaders = allowInlineHeaders
        self.templateExtension = templateExtension
        self.headerExtension = headerExtension
        self.unknownFileMethod = unknownFileMethod
        self.ignoreDotFiles = ignoreDotFiles
        self.invalidIdentifierCharacterMethod = invalidIdentifierCharacterMethod
        self.defaultParameters = defaultParameters
        self.defaultSyntax = defaultSyntax
    }
}

/// Possibly rename this
public enum InvalidIdentifierCharacterMethod: String, Codable {
    case replaceOrPrefixWithUnderscores
    case deleteOrPrexfixWithUnderscores
    case fail
}
public enum UnknownFileMethod: String, Codable {
    case ignore
    case warn
    case error
    case useAsTemplate
}
