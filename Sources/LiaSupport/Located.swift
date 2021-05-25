public struct Located<T> {
    public let value: T
    public let line: Int
    public let column: Int
    
    public init(_ value: T, line: Int = #line, column: Int = #column) {
        self.value = value
        self.line = line
        self.column = column
    }
}

@resultBuilder
public enum LocatedBuilder {
    public static func buildBlock<T>(_ value: T, line: Int = #line, column: Int = #column) -> Located<T> {
        .init(value, line: line, column: column)
    }
    public static func buildBlock<T>(_ value: T, line: Int = #line, column: Int = #column) -> Located<T>? {
        .init(value, line: line, column: column)
    }
}

extension Located: Equatable where T: Equatable {}
extension Located: Codable where T: Codable {}
