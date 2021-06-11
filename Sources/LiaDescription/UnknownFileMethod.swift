import LiaSupport

public enum UnknownFileMethod: Equatable, Codable {
    case ignore(line: Int = #line, column: Int = #column)
    case warn(line: Int = #line, column: Int = #column)
    case error(line: Int = #line, column: Int = #column)
    case useAsTemplate(line: Int = #line, column: Int = #column)
}
