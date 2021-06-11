import Foundation

public struct StringEncodingError: Error {
    let value: String
    let encoding: String.Encoding
}
public struct StringDecodingError: Error {
    let value: Data
    let encoding: String.Encoding
}

public extension String {
    init(contentsOf path: Path) throws {
        try self.init(contentsOf: path.url)
    }
    init(contentsOf path: Path, encoding: Encoding) throws {
        try self.init(contentsOf: path.url, encoding: encoding)
    }
    init(contentsOf path: Path, usedEncoding encoding: inout Encoding) throws {
        try self.init(contentsOf: path.url, usedEncoding: &encoding)
    }
    
    init(data: Data, encoding: Encoding = .utf8) throws {
        guard let _self = String(data: data, encoding: encoding) else {
            throw StringDecodingError(value: data, encoding: encoding)
        }
        self = _self
    }
    
    func data(using encoding: Encoding = .utf8) throws -> Data {
        guard let data = self.data(using: encoding) else {
            throw StringEncodingError(value: self, encoding: encoding)
        }
        return data
    }
    
    func write(to path: Path, using encoding: Encoding = .utf8) throws {
        try self.data(using: encoding).write(to: path)
    }
    
}
