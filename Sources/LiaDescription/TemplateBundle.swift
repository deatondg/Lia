import LiaSupport
//import PackageDescription

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
    public let identifierConversionMethod: Located<IdentifierConversionMethod>?
    public let defaultParameters: Located<String>?
    public let defaultSyntax: Syntax
    
    public init(
        name: Located<String>,
        path: Located<String>?,
        //dependencies: Located<[Target.Dependency]>?,
        includeSources: Located<Bool>?,
        allowInlineHeaders: Located<Bool>?,
        templateExtension: Located<String>?,
        headerExtension: Located<Optional<String>>?,
        unknownFileMethod: Located<UnknownFileMethod>?,
        ignoreDotFiles: Located<Bool>?,
        identifierConversionMethod: Located<IdentifierConversionMethod>?,
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
        self.identifierConversionMethod = identifierConversionMethod
        self.defaultParameters = defaultParameters
        self.defaultSyntax = defaultSyntax
    }
    
    public static func bundle(
        @LocatedBuilder name: () -> Located<String>,
        @LocatedBuilder path: () -> Located<String>? = { nil },
        //@LocatedBuilder dependencies: () -> Located<[Target.Dependency]>?,
        @LocatedBuilder includeSources: () -> Located<Bool>? = { nil },
        @LocatedBuilder allowInlineHeaders: () -> Located<Bool>? = { nil },
        @LocatedBuilder templateExtension: () -> Located<String>? = { nil },
        @LocatedBuilder headerExtension: () -> Located<Optional<String>>? = { nil },
        @LocatedBuilder unknownFileMethod: () -> Located<UnknownFileMethod>? = { nil },
        @LocatedBuilder ignoreDotFiles: () -> Located<Bool>? = { nil },
        @LocatedBuilder identifierConversionMethod: () -> Located<IdentifierConversionMethod>? = { nil },
        @LocatedBuilder defaultParameters: () -> Located<String>? = { nil },
        defaultSyntax: Syntax
    ) -> TemplateBundle {
        return .init(
            name: name(),
            path: path(),
            //dependencies: dependencies(),
            includeSources: includeSources(),
            allowInlineHeaders: allowInlineHeaders(),
            templateExtension: templateExtension(),
            headerExtension: headerExtension(),
            unknownFileMethod: unknownFileMethod(),
            ignoreDotFiles: ignoreDotFiles(),
            identifierConversionMethod: identifierConversionMethod(),
            defaultParameters: defaultParameters(),
            defaultSyntax: defaultSyntax)
    }
}
