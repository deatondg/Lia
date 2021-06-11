import LiaSupport

public enum LiaProduct: Equatable, Codable {
    case sources(line: Int = #line, column: Int = #column)
    case package(name: Located<String>)
    //case dylibs(DylibController)
    
    public static func package(@LocatedBuilder name: () -> Located<String>) -> LiaProduct {
        .package(name: name())
    }
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
