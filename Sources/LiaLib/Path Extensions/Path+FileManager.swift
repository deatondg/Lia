import Foundation

extension Path {
    public func exists() -> Bool {
        FileManager.default.fileExists(atPath: self.path)
    }
    public func deleteFromFilesystem() throws {
        try FileManager.default.removeItem(at: self.url)
    }
    
    public static var temporaryDirectory: Path {
        Path(unchecked: FileManager.default.temporaryDirectory)
    }
    
    public static var currentWorkingDirectory: Path { Path(FileManager.default.currentDirectoryPath) }
    public static func changeCurrentWorkingDirectory(_ newValue: Path) throws {
        guard FileManager.default.changeCurrentDirectoryPath(newValue.path) else {
            throw PathError.cannotSetWorkingDirectory
        }
    }
    /// This will crash if the work you do in `f` deletes `currentWorkingDirectory` or otherwise makes it inaccessible.
    @discardableResult
    public static func withCurrentWorkingDirectory<T>(_ path: Path, _ f: () throws -> T) throws -> T {
        let oldDir = Path.currentWorkingDirectory
        try Path.changeCurrentWorkingDirectory(path)
        defer { try! Path.changeCurrentWorkingDirectory(oldDir) }
        return try f()
    }
}
