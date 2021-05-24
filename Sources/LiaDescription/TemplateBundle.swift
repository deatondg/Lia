import LiaSupport
import PackageDescription

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
