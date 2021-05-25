public enum UnknownFileMethod: String, Equatable, Codable {
    case ignore
    case warn
    case error
    case useAsTemplate
}
