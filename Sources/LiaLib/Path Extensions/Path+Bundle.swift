import Foundation

extension Bundle {
    public var bundlePath: Path {
        Path(unchecked: self.bundleURL)
    }
    public var liaResourcePath: Path? {
        if let resourcePath = self.resourceURL.map(Path.init(unchecked:)),
           resourcePath.appending(components: "Resources", "LiaResourcesRoot").exists()
        {
            return resourcePath
        } else if self.bundlePath.appending(components: "Resources", "LiaResourcesRoot").exists()
        {
            return self.bundlePath
        } else {
            return nil
        }
    }
}
