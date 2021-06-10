import Foundation
import Parsers

struct SwiftVersion: Hashable, Codable {
    let value: String
    
    // TODO: Is there some way to bubble up errors from here?
    static let versionRegex: NSRegularExpression = try! NSRegularExpression(pattern: #"^(Apple )?Swift version ([0-9.]+) \(([^()]*)\)\#nTarget: (.*)\#n$"#, options: [])
    static let errorRegex: NSRegularExpression = try! NSRegularExpression(pattern: #"^swift-driver version: ([0-9.]+) $"#, options: [])
    
    init(ofExecutable swift: Path) async throws {
        let (output, error) = try await swift.run(withArguments: "--version").extractOutputAndError()
        guard error == "" || SwiftVersion.errorRegex.numberOfMatches(in: error, options: [], range: ...) == 1 else {
            throw SwiftVersionError.invalidError(error)
        }
        try self.init(value: output)
    }
    
    enum SwiftVersionError: Error {
        case invalidVersion(String)
        case invalidError(String)
    }
    init(value: String) throws {
        guard SwiftVersion.versionRegex.numberOfMatches(in: value, options: [], range: ...) == 1 else {
            throw SwiftVersionError.invalidVersion(value)
        }
        self.value = value
    }
}
