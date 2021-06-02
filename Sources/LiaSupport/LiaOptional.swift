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
extension LiaOptional {
    enum CodingKeys: String, CodingKey {
        case some
        case none
    }
}
extension LiaOptional: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard container.allKeys.count == 1 else {
            if container.allKeys.count > 1 {
                throw DecodingError.multipleKeys
            } else {
                throw DecodingError.noKeys
            }
        }
        if let value = try container.decodeIfPresent(Located<T>.self, forKey: .some) {
            self = .some(value)
            return
        } else if let location =  try container.decodeIfPresent(Location.self, forKey: .none) {
            self = .none(line: location.line, column: location.column)
            return
        }
        fatalError() // Impossible, there is a key.
    }
    enum DecodingError: Error {
        case multipleKeys
        case noKeys
    }
}
extension LiaOptional: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .some(let value):
            try container.encode(value, forKey: .some)
            return
        case let .none(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .none)
            return
        }
    }
}

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

// TEMP
extension LiaOptional: Hashable where T: Hashable {}
