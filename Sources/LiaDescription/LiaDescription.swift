import LiaSupport
import Foundation
import PackageDescription

public struct LiaDescription {
    public let actions: [LiaAction]
    public let dependencies: [Package.Dependency]
    public let bundles: [TemplateBundle]
}

public enum LiaAction {
    case render(
            bundles: [TemplateBundle],
            destination: String)
    case build(
            product: LiaProduct)
}

public enum LiaProduct {
    case sources(
            moduleName: String,
            bundles: [TemplateBundle],
            destination: String)
    case package(
            moduleName: String,
            bundles: [TemplateBundle],
            destination: String)
    case dylibs(
            controller: DylibController,
            bundles: [TemplateBundle],
            dylibDestination: String)
}

public enum DylibController {
    case sources(
            moduleName: String,
            destination: String)
    case package(
            moduleName: String,
            destination: String)
}

public struct TemplateBundle {
    public let name: String
    public let path: Path?
    public let dependencies: [Target.Dependency]
    
    public init(name: String, path: Path? = nil, dependencies: [Target.Dependency] = []) {
        self.name = name
        self.path = path
        self.dependencies = dependencies
    }
}
