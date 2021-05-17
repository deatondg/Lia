import Foundation
import PackageDescription

public struct LiaDescription {
    let actions: [LiaAction]
    let dependencies: [Package.Dependency]
    let bundles: [TemplateBundle]
}

enum LiaAction {
    case render(
            bundles: [TemplateBundle],
            destination: String)
    case build(
            product: LiaProduct)
}

enum LiaProduct {
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

enum DylibController {
    case sources(
            moduleName: String,
            destination: String)
    case package(
            moduleName: String,
            destination: String)
}

struct TemplateBundle {
    let name: String
    let path: String
    let dependencies: [Target.Dependency]
}
