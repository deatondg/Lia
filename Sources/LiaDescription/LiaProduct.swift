import LiaSupport

public enum LiaProduct: Equatable {
    case sources(line: Int = #line, column: Int = #column)
    case package(name: Located<String>)
    //case dylibs(DylibController)
    
    public static func package(@LocatedBuilder name: () -> Located<String>) -> LiaProduct {
        .package(name: name())
    }
}
/*
public struct DylibController: Equatable, Codable {
    public let name: String
    public let destination: String
    public let type: DylibControllerType
}
public enum DylibControllerType: String, Equatable, Codable {
    case sources
    case package
}
public enum DylibFormat: String, Equatable, Codable {
    case dylibs
    case package
}
*/

extension LiaProduct: Codable {
    enum CodingKeys: String, CodingKey {
        case sources
        case package
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
        if let location = try container.decodeIfPresent(Location.self, forKey: .sources) {
            self = .sources(line: location.line, column: location.column)
            return
        } else if let name = try container.decodeIfPresent(Located<String>.self, forKey: .package) {
            self = .package(name: name)
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
        case let .sources(line: line, column: column):
            try container.encode(Location(line: line, column: column), forKey: .sources)
            return
        case .package(name: let name):
            try container.encode(name, forKey: .package)
            return
        }
    }
}
