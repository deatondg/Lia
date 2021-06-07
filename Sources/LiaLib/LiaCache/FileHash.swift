import Foundation
import Crypto

typealias LiaHash = SHA256Digest
extension LiaHash: Codable {
    public init(from decoder: Decoder) throws {
        // TODO: Fix this
        // AFAIK, this is the only way to initialize a digest.
        self = SHA256.hash(data: Data())
        
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        
        try withUnsafeMutableBytes(of: &self) { selfBytes in
            guard data.count == selfBytes.count else {
                throw DecodingError.typeMismatch(Insecure.SHA1.self, .init(codingPath: decoder.codingPath, debugDescription: "Incorrect byte count; is \(data.count), should be \(selfBytes.count)"))
            }
            selfBytes.copyBytes(from: data)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.data)
    }
    
    public var data: Data {
        self.withUnsafeBytes({ Data.init($0) })
    }
    
    public init(of data: Data) {
        self = SHA256.hash(data: data)
    }
}
extension Path {
    func stats() throws -> FileStats {
        let data = try Data(contentsOf: self)
        return FileStats(size: data.count, hash: LiaHash(of: data))
    }
    struct FileStats: Hashable, Codable {
        let size: Int
        let hash: LiaHash
    }
}
