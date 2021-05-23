import Foundation

extension Data {
    public init(contentsOf path: Path) throws {
        try self.init(contentsOf: path.url)
    }
}
