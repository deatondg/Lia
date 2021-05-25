extension Identifier {
    public enum ConversionMethod {
        case replaceOrPrefixWithUnderscores
        case deleteOrPrexfixWithUnderscores
        case fail
    }
}
extension LocatedIdentifierConversionMethod {
    var value: Identifier.ConversionMethod {
        switch self {
        case .replaceOrPrefixWithUnderscores(line: _, column: _):
            return .replaceOrPrefixWithUnderscores
        case .deleteOrPrexfixWithUnderscores(line: _, column: _):
            return .deleteOrPrexfixWithUnderscores
        case .fail(line: _, column: _):
            return .fail
        }
    }
}
