import LiaSupport

public struct LiaAction: Equatable, Codable {
    public let bundles: [Located<String>]
    public let destination: Located<String>
    public let type: LiaActionType
}
extension LiaAction {
    public static func render(
        bundles: [Located<String>],
        toPath destination: Located<String>
    ) -> LiaAction {
        self.init(
            bundles: bundles,
            destination: destination,
            type: .render
        )
    }
    public static func build(
        bundles: [Located<String>],
        toPath destination: Located<String>,
        as product: LiaProduct
    ) -> LiaAction {
        self.init(
            bundles: bundles,
            destination: destination,
            type: .build(product))
    }
}

public enum LiaActionType: Equatable {
    case render
    case build(LiaProduct)
}
extension LiaActionType: Codable {
    enum CodingKeys: String, CodingKey {
        case render
        case build
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if try container.decodeNil(forKey: .render) {
            guard !container.contains(.build) else {
                throw DecodingError.multipleKeysSpecified
            }
            self = .render
            return
        } else if let product = try container.decodeIfPresent(LiaProduct.self, forKey: .build) {
            guard !container.contains(.render) else {
                throw DecodingError.multipleKeysSpecified
            }
            self = .build(product)
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
        case .render:
            try container.encodeNil(forKey: .render)
        case .build(let product):
            try container.encode(product, forKey: .build)
        }
    }
}
