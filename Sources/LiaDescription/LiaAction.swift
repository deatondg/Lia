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

public enum LiaActionType: Equatable, Codable {
    case render
    case build(LiaProduct)
}
