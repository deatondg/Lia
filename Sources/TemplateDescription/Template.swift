import LiaSupport
import Foundation

public struct Template: Equatable, Codable {
    public let parameters: Located<String>?
    public let key: Located<String>?
    public let identifier: Located<String>?
    public let syntax: Syntax
    
    /// If the command line arguments are `--liaTemplateOutput <path>`, print the template JSON to `path` at exit.
    /// Only do this for the most recently created template.
    /// Loosly based on `swift-package-manager/Sources/PackageDescription/PackageDescription.swift`.
    private static var dumpInfo: (template: Template, path: String)?
    private func registerExitHandler() {
        guard CommandLine.arguments.count == 3 else { return }
        guard CommandLine.arguments[1] == "--liaTemplateOutput" else { return }
        let path: String = CommandLine.arguments[2]
        
        if Template.dumpInfo == nil {
            atexit {
                guard let (template, path) = Template.dumpInfo else { return }
                try! JSONEncoder().encode(template).write(to: URL(fileURLWithPath: path))
            }
        }
        
        Template.dumpInfo = (self, path)
    }
    
    init(
        parameters: Located<String>?,
        key: Located<String>?,
        identifier: Located<String>?,
        syntax: Syntax
    ) {
        self.parameters = parameters
        self.key = key
        self.identifier = identifier
        self.syntax = syntax
        registerExitHandler()
    }
    
    public init(
        @LocatedBuilder parameters: () -> Located<String>? = { nil },
        @LocatedBuilder key: () -> Located<String>? = { nil },
        @LocatedBuilder identifier: () -> Located<String>? = { nil },
        syntax: Syntax = Syntax()
    ) {
        self.init(
            parameters: parameters(),
            key: key(),
            identifier: identifier(),
            syntax: syntax
        )
    }
}
