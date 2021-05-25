import Foundation

public struct Path: Equatable, Codable {
    public private(set) var url: URL
    public var path: String { url.path }
    
    public init(url: URL) throws {
        self.init(unchecked: url)
        try verifyAssertions()
    }
    public init(unchecked url: URL) {
        self.url = url
    }
    public init(_ string: String) {
        self.init(unchecked: URL(fileURLWithPath: string))
    }
    
    private func verifyAssertions() throws {
        guard url.isFileURL else {
            throw PathError.urlIsNotAFileURL
        }
    }
}
public enum PathError: Error {
    case urlIsNotAFileURL
    case cannotSetWorkingDirectory
}
