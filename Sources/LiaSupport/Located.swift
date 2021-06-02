public struct Located<T> {
    public let value: T
    public let location: Location
    
    public init(_ value: T, line: Int = #line, column: Int = #column) {
        self.value = value
        self.location = .init(line: line, column: column)
    }
}
public struct Location: Equatable, Codable {
    public let line: Int
    public let column: Int
    public init(line: Int = #line, column: Int = #column) {
        self.line = line
        self.column = column
    }
}

@resultBuilder
public enum LocatedBuilder {
    public static func buildExpression<T>(_ value: T, line: Int = #line, column: Int = #column) -> Located<T> {
        .init(value, line: line, column: column)
    }
    public static func buildBlock<T>(_ component: Located<T>) -> Located<T> {
        component
    }
    public static func buildBlock<T>(_ component: Located<T>) -> Located<T>? {
        component
    }
    public static func buildBlock<T>(_ component: Located<T>) -> LiaOptional<T>? {
        .some(component)
    }
    public static func buildBlock<T>(_ components: Located<T>...) -> [Located<T>] {
        components
    }
}

extension Located: Equatable where T: Equatable {}
extension Located: Decodable where T: Decodable {}
extension Located: Encodable where T: Encodable {}

// TEMP
extension Location: Hashable {}
extension Located: Hashable where T: Hashable {}
