import Foundation

extension Bundle {
    public var path: Path {
        Path(unchecked: self.bundleURL)
    }
}
