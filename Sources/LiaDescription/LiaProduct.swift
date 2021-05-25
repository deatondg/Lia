import LiaSupport

public enum LiaProduct: Equatable {
    case sources
    case package(name: Located<String>)
    //case dylibs(DylibController)
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
        if try container.decodeNil(forKey: .sources) {
            guard !container.contains(.package) else {
                throw DecodingError.multipleKeysSpecified
            }
            self = .sources
            return
        } else if let name = try container.decodeIfPresent(Located<String>.self, forKey: .package) {
            guard !container.contains(.sources) else {
                throw DecodingError.multipleKeysSpecified
            }
            self = .package(name: name)
            return
        } else {
            throw DecodingError.noKeys
        }
    }
    enum DecodingError: Error {
        case multipleKeysSpecified
        case noKeys
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .sources:
            try container.encodeNil(forKey: .sources)
        case .package(name: let name):
            try container.encode(name, forKey: .package)
        }
    }
}
