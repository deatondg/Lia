import LiaSupport

struct LiaAction {
    public let bundles: [String]
    public let destination: Path
    public let type: LiaActionType
}
enum LiaActionType {
    case render
    case build(LiaProduct)
}

extension LocatedLiaAction {
    var value: LiaAction {
        LiaAction(
            bundles: self.bundles.map(\.value),
            destination: Path(self.destination.value),
            type: self.type.value
        )
    }
}
extension LocatedLiaActionType {
    var value: LiaActionType {
        switch self {
        case .render:
            return .render
        case .build(let product):
            return .build(product.value)
        }
    }
}

