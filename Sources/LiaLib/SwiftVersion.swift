import Foundation

struct SwiftVersion: Hashable, Codable {
    let value: String
    
    static let regex: NSRegularExpression = {
        // TODO: Is there some way to bubble up errors from here?
        try! NSRegularExpression(pattern: #"^(Apple )?Swift version ([0-9.]*) \(([^()]*)\)\#nTarget: (.*)\#n$"#, options: [])
    }()
    
    init(ofExecutable swift: Path) throws {
        try self.init(value: swift.runSync(withArguments: "--version").extractOutput())
    }
    
    enum SwiftVersionError: Error {
        case invalidVersionString
    }
    init(value: String) throws {
        guard SwiftVersion.regex.numberOfMatches(in: value, options: [], range: NSRange(value.startIndex..<value.endIndex, in: value)) == 1 else {
            throw SwiftVersionError.invalidVersionString
        }
        self.value = value
    }
}
