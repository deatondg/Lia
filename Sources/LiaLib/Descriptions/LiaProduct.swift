enum LiaProduct {
    case sources
    case package(name: String)
    
    //case dylibs(DylibController)
}
/*
public struct DylibController: Equatable, Codable {
    public let name: String
    public let destination: String
    public let type: DylibControllerType
}
public enum DylibControllerType: String, Equatable, Codable {
    case sources
    case package
}
public enum DylibFormat: String, Equatable, Codable {
    case dylibs
    case package
}
*/
extension LocatedLiaProduct {
    var value: LiaProduct {
        switch self {
        case .sources(line: _, column: _):
            return .sources
        case .package(name: let name):
            return .package(name: name.value)
        }
    }
}
