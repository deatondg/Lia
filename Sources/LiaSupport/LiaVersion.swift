public struct LiaVersion: Hashable, Codable {
    public let major: UInt
    public let minor: UInt
    public let patch: UInt
    public let commit: String
    
    public init(major: UInt, minor: UInt, patch: UInt, commit: String) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.commit = commit
    }
}
