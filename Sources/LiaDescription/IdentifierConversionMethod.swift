import LiaSupport

public enum IdentifierConversionMethod: Equatable {
    case replaceOrPrefixWithUnderscores(line: Int = #line, column: Int = #column)
    case deleteOrPrexfixWithUnderscores(line: Int = #line, column: Int = #column)
    case fail(line: Int = #line, column: Int = #column)
}
extension IdentifierConversionMethod: Codable {
    enum CodingKeys: String, CodingKey {
        case replaceOrPrefixWithUnderscores
        case deleteOrPrexfixWithUnderscores
        case fail
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard container.allKeys.count == 1 else {
            if container.allKeys.count > 1 {
                throw DecodingError.multipleKeys
            } else {
                throw DecodingError.noKeys
            }
        }
        if let location = try container.decodeIfPresent(Location.self, forKey: .replaceOrPrefixWithUnderscores) {
            self = .replaceOrPrefixWithUnderscores(line: location.line, column: location.column)
            return
        } else if let location = try container.decodeIfPresent(Location.self, forKey: .deleteOrPrexfixWithUnderscores) {
            self = .deleteOrPrexfixWithUnderscores(line: location.line, column: location.column)
            return
        } else if let location = try container.decodeIfPresent(Location.self, forKey: .fail) {
            self = .fail(line: location.line, column: location.column)
            return
        }
        fatalError() // Impossible, there is a key.
    }
    enum DecodingError: Error {
        case multipleKeys
        case noKeys
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .replaceOrPrefixWithUnderscores(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .replaceOrPrefixWithUnderscores)
        case let .deleteOrPrexfixWithUnderscores(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .deleteOrPrexfixWithUnderscores)
        case let .fail(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .fail)
        }
    }
}
