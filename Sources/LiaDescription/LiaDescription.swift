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

