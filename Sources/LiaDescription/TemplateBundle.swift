import LiaSupport
//import PackageDescription

public struct TemplateBundle: Equatable, Codable {
    public let name: Located<String>
    public let path: Located<String>?
    /// Fuck. Why doesn't this conform to decodable?
    //public let dependencies: Located<[Target.Dependency]>?
    public let includeSources: Located<Bool>?
    public let allowInlineHeaders: Located<Bool>?
    public let templateExtension: LiaOptional<String>?
    public let headerExtension: LiaOptional<String>?
    public let unknownFileMethod: UnknownFileMethod?
    public let ignoreDotFiles: Located<Bool>?
    public let identifierConversionMethod: IdentifierConversionMethod?
    public let defaultParameters: Located<String>?
    public let defaultSyntax: Syntax
    
    /// We need 2^(# of LiaOptional arguments) factory methods because each LiaOptional argument can either be given as a LocatedBuilder or as a regular value.
    public static func bundle(
        @LocatedBuilder name: () -> Located<String>,
        @LocatedBuilder path: () -> Located<String>? = { nil },
        //@LocatedBuilder dependencies: () -> Located<[Target.Dependency]>?,
        @LocatedBuilder includeSources: () -> Located<Bool>? = { nil },
        @LocatedBuilder allowInlineHeaders: () -> Located<Bool>? = { nil },
        @LocatedBuilder templateExtension: () -> LiaOptional<String>? = { nil },
        @LocatedBuilder headerExtension: () -> LiaOptional<String>? = { nil },
        unknownFileMethod: UnknownFileMethod? = nil,
        @LocatedBuilder ignoreDotFiles: () -> Located<Bool>? = { nil },
        identifierConversionMethod: IdentifierConversionMethod? = nil,
        @LocatedBuilder defaultParameters: () -> Located<String>? = { nil },
        defaultSyntax: Syntax = Syntax()
    ) -> TemplateBundle {
        return .init(
            name: name(),
            path: path(),
            //dependencies: dependencies(),
            includeSources: includeSources(),
            allowInlineHeaders: allowInlineHeaders(),
            templateExtension: templateExtension(),
            headerExtension: headerExtension(),
            unknownFileMethod: unknownFileMethod,
            ignoreDotFiles: ignoreDotFiles(),
            identifierConversionMethod: identifierConversionMethod,
            defaultParameters: defaultParameters(),
            defaultSyntax: defaultSyntax)
    }
    public static func bundle(
        @LocatedBuilder name: () -> Located<String>,
        @LocatedBuilder path: () -> Located<String>? = { nil },
        //@LocatedBuilder dependencies: () -> Located<[Target.Dependency]>?,
        @LocatedBuilder includeSources: () -> Located<Bool>? = { nil },
        @LocatedBuilder allowInlineHeaders: () -> Located<Bool>? = { nil },
        @LocatedBuilder templateExtension: () -> LiaOptional<String>? = { nil },
        headerExtension: LiaOptional<String>,
        unknownFileMethod: UnknownFileMethod? = nil,
        @LocatedBuilder ignoreDotFiles: () -> Located<Bool>? = { nil },
        identifierConversionMethod: IdentifierConversionMethod? = nil,
        @LocatedBuilder defaultParameters: () -> Located<String>? = { nil },
        defaultSyntax: Syntax = Syntax()
    ) -> TemplateBundle {
        return .init(
            name: name(),
            path: path(),
            //dependencies: dependencies(),
            includeSources: includeSources(),
            allowInlineHeaders: allowInlineHeaders(),
            templateExtension: templateExtension(),
            headerExtension: headerExtension,
            unknownFileMethod: unknownFileMethod,
            ignoreDotFiles: ignoreDotFiles(),
            identifierConversionMethod: identifierConversionMethod,
            defaultParameters: defaultParameters(),
            defaultSyntax: defaultSyntax)
    }
    public static func bundle(
        @LocatedBuilder name: () -> Located<String>,
        @LocatedBuilder path: () -> Located<String>? = { nil },
        //@LocatedBuilder dependencies: () -> Located<[Target.Dependency]>?,
        @LocatedBuilder includeSources: () -> Located<Bool>? = { nil },
        @LocatedBuilder allowInlineHeaders: () -> Located<Bool>? = { nil },
        templateExtension: LiaOptional<String>,
        @LocatedBuilder headerExtension: () -> LiaOptional<String>? = { nil },
        unknownFileMethod: UnknownFileMethod? = nil,
        @LocatedBuilder ignoreDotFiles: () -> Located<Bool>? = { nil },
        identifierConversionMethod: IdentifierConversionMethod? = nil,
        @LocatedBuilder defaultParameters: () -> Located<String>? = { nil },
        defaultSyntax: Syntax = Syntax()
    ) -> TemplateBundle {
        return .init(
            name: name(),
            path: path(),
            //dependencies: dependencies(),
            includeSources: includeSources(),
            allowInlineHeaders: allowInlineHeaders(),
            templateExtension: templateExtension,
            headerExtension: headerExtension(),
            unknownFileMethod: unknownFileMethod,
            ignoreDotFiles: ignoreDotFiles(),
            identifierConversionMethod: identifierConversionMethod,
            defaultParameters: defaultParameters(),
            defaultSyntax: defaultSyntax)
    }
    public static func bundle(
        @LocatedBuilder name: () -> Located<String>,
        @LocatedBuilder path: () -> Located<String>? = { nil },
        //@LocatedBuilder dependencies: () -> Located<[Target.Dependency]>?,
        @LocatedBuilder includeSources: () -> Located<Bool>? = { nil },
        @LocatedBuilder allowInlineHeaders: () -> Located<Bool>? = { nil },
        templateExtension: LiaOptional<String>,
        headerExtension: LiaOptional<String>,
        unknownFileMethod: UnknownFileMethod? = nil,
        @LocatedBuilder ignoreDotFiles: () -> Located<Bool>? = { nil },
        identifierConversionMethod: IdentifierConversionMethod? = nil,
        @LocatedBuilder defaultParameters: () -> Located<String>? = { nil },
        defaultSyntax: Syntax = Syntax()
    ) -> TemplateBundle {
        return .init(
            name: name(),
            path: path(),
            //dependencies: dependencies(),
            includeSources: includeSources(),
            allowInlineHeaders: allowInlineHeaders(),
            templateExtension: templateExtension,
            headerExtension: headerExtension,
            unknownFileMethod: unknownFileMethod,
            ignoreDotFiles: ignoreDotFiles(),
            identifierConversionMethod: identifierConversionMethod,
            defaultParameters: defaultParameters(),
            defaultSyntax: defaultSyntax)
    }
}
