import Foundation

extension Path {
    public func relative(to other: Path) -> Path {
        Path(unchecked: URL(fileURLWithPath: self.path, relativeTo: other.url))
    }
    
    public static func + (lhs: Path, rhs: Path) -> Path {
        rhs.relative(to: lhs)
    }
    public static func + (lhs: Path, rhs: String) -> Path {
        Path(unchecked: URL(fileURLWithPath: rhs, relativeTo: lhs.url))
    }
    
    public func appending(pathComponent: String) -> Path {
        Path(unchecked: self.url.appendingPathComponent(pathComponent))
    }
    public func deletingLastPathComponent() -> Path {
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
}
