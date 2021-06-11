import LiaSupport

public enum IdentifierConversionMethod: Equatable, Codable {
    case replaceOrPrefixWithUnderscores(line: Int = #line, column: Int = #column)
    case deleteOrPrexfixWithUnderscores(line: Int = #line, column: Int = #column)
    case fail(line: Int = #line, column: Int = #column)
}
