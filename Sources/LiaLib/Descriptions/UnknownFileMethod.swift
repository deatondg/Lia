public enum UnknownFileMethod: String, Equatable, Codable {
    case ignore
    case warn
    case error
    case useAsTemplate
}
extension LocatedUnknownFileMethod {
    var value: UnknownFileMethod {
        switch self {
        case .ignore(line: _, column: _):
            return .ignore
        case .warn(line: _, column: _):
            return .warn
        case .error(line: _, column: _):
            return .error
        case .useAsTemplate(line: _, column: _):
            return .useAsTemplate
        }
    }
}
