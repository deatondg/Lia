import LiaSupport

public struct LiaAction: Equatable, Codable {
    public let bundles: [Located<String>]
    public let destination: Located<String>
    public let type: LiaActionType
}
extension LiaAction {
    public static func render(
        @LocatedBuilder bundles: () -> [Located<String>],
        @LocatedBuilder toPath destination: () -> Located<String>
    ) -> LiaAction {
        self.init(
            bundles: bundles(),
            destination: destination(),
            type: .render
        )
    }
    public static func build(
        @LocatedBuilder bundles: () -> [Located<String>],
        @LocatedBuilder toPath destination: () -> Located<String>,
        as product: LiaProduct
    ) -> LiaAction {
        self.init(
            bundles: bundles(),
            destination: destination(),
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
        guard container.allKeys.count == 1 else {
            if container.allKeys.count > 1 {
                throw DecodingError.multipleKeys
            } else {
                throw DecodingError.noKeys
            }
        }
        if try container.decodeNil(forKey: .render) {
            self = .render
            return
        } else if let product = try container.decodeIfPresent(LiaProduct.self, forKey: .build) {
            self = .build(product)
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
        case .render:
            try container.encodeNil(forKey: .render)
            return
        case .build(let product):
            try container.encode(product, forKey: .build)
            return
        }
    }
}
