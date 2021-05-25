import LiaSupport
import Foundation
//import PackageDescription

public struct LiaDescription: Equatable, Codable {
    public let actions: [LiaAction]
    //public let dependencies: [Package.Dependency]
    public let bundles: [TemplateBundle]
    
    /// If the command line arguments are `--liaDescriptionOutput <path>`, print the template JSON to `path` at exit.
    /// Only do this for the most recently created template.
    /// Loosly based on `swift-package-manager/Sources/PackageDescription/PackageDescription.swift`.
    private static var dumpInfo: (description: LiaDescription, path: String)?
    private func registerExitHandler() {
        guard CommandLine.arguments.count == 3 else { return }
        guard CommandLine.arguments[1] == "--liaDescriptionOutput" else { return }
        let path: String = CommandLine.arguments[2]
        
        if LiaDescription.dumpInfo == nil {
            atexit {
                guard let (description, path) = LiaDescription.dumpInfo else { return }
                try! JSONEncoder().encode(description).write(to: URL(fileURLWithPath: path))
            }
        }
        
        LiaDescription.dumpInfo = (self, path)
    }
    
    public init(
        actions: [LiaAction],
        //dependencies: [Package.Dependency],
        bundles: [TemplateBundle]
    ) {
        self.actions = actions
        //self.dependencies = dependencies
        self.bundles = bundles
        registerExitHandler()
    }
}



