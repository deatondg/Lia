import Foundation

extension Bundle {
    public var bundlePath: Path {
        Path(unchecked: self.bundleURL)
    }
    public var resourcePath: Path? {
        self.resourceURL.map(Path.init(unchecked:))
    }
}
