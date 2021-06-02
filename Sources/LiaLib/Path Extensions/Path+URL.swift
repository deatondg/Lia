import Foundation

extension Path {    
    public func appending(component: String) -> Path {
        // TODO: Maybe make a path component type? Is this even the correct condition?
        assert(!component.contains("/"))
        return Path(unchecked: self.url.appendingPathComponent(component))
    }
    public func appending(components: String...) -> Path {
        Path(unchecked: components.reduce(into: self.url, { $0.appendPathComponent($1) }))
    }
    
    public func deletingLastComponent() -> Path {
        Path(unchecked: self.url.deletingLastPathComponent())
    }
    
    public var relativePath: String { self.url.relativePath }
    public var base: Path? {
        if let baseURL = self.url.baseURL {
            return Path(unchecked: baseURL)
        } else {
            return nil
        }
    }
    public var components: [String] { self.url.pathComponents }
    
    public var `extension`: String {
        self.url.pathExtension
    }
    public func deletingExtension() -> Path {
        Path(unchecked: self.url.deletingPathExtension())
    }
    public func appending(extension: String) -> Path {
        Path(unchecked: self.url.appendingPathExtension(`extension`))
    }
}
