import LiaSupport

public enum UnknownFileMethod: Equatable {
    case ignore(line: Int = #line, column: Int = #column)
    case warn(line: Int = #line, column: Int = #column)
    case error(line: Int = #line, column: Int = #column)
    case useAsTemplate(line: Int = #line, column: Int = #column)
}
extension UnknownFileMethod: Codable {
    enum CodingKeys: String, CodingKey {
        case ignore
        case warn
        case error
        case useAsTemplate
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
        if let location = try container.decodeIfPresent(Location.self, forKey: .ignore) {
            self = .ignore(line: location.line, column: location.column)
            return
        } else if let location = try container.decodeIfPresent(Location.self, forKey: .warn) {
            self = .warn(line: location.line, column: location.column)
            return
        } else if let location = try container.decodeIfPresent(Location.self, forKey: .error) {
            self = .error(line: location.line, column: location.column)
            return
        } else if let location = try container.decodeIfPresent(Location.self, forKey: .useAsTemplate) {
            self = .useAsTemplate(line: location.line, column: location.column)
            return
        }
        fatalError() // Impossible, there is a key
    }
    enum DecodingError: Error {
        case multipleKeys
        case noKeys
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .ignore(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .ignore)
        case let .warn(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .warn)
        case let .error(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .error)
        case let .useAsTemplate(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .useAsTemplate)
        }
    }
}
