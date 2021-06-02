import Foundation

extension Data {
    public init(contentsOf path: Path) throws {
        try self.init(contentsOf: path.url)
    }
    public func write(to path: Path, options: Data.WritingOptions = []) throws {
        try self.write(to: path.url, options: options)
    }
}
