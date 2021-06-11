public enum LiaOptional<T> {
    case some(Located<T>)
    case none(line: Int = #line, column: Int = #column)
    
    public init(_ value: Located<T>) {
        self = .some(value)
    }
    public var value: T? {
        switch self {
        case .some(let locatedValue):
            return locatedValue.value
        case .none:
            return nil
        }
    }
    public var location: Location {
        switch self {
        case .some(let locatedValue):
            return locatedValue.location
        case let .none(line: line, column: column):
            return .init(line: line, column: column)
        }
    }
}

extension LiaOptional: Equatable where T: Equatable {}
extension LiaOptional: Decodable where T: Decodable {}
extension LiaOptional: Encodable where T: Encodable {}

/*
extension LiaOptional: ExpressibleByUnicodeScalarLiteral where T: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: T.UnicodeScalarLiteralType) {
        self.init(T(unicodeScalarLiteral: value))
    }
}
extension LiaOptional: ExpressibleByExtendedGraphemeClusterLiteral where T: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: T.ExtendedGraphemeClusterLiteralType) {
        self.init(T(extendedGraphemeClusterLiteral: value))
    }
}
extension LiaOptional: ExpressibleByStringLiteral where T: ExpressibleByStringLiteral {
    public init(stringLiteral value: T.StringLiteralType) {
        self.init(T(stringLiteral: value))
    }
}
*/
