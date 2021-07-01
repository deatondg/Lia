import Foundation

/**
 Dependent Dictionary
 */

// Any type implementing this must be public (or maybe internal is okay)?
// You should only conform to this by conforming to CodableDependentDictionaryKey
protocol DependentDictionaryKeyProtocol {
    static var valueType: Any.Type { get }
    
    // Used to verify the DependentDictionary invariant
    static func valueTypeContains(_ value: Any) -> Bool
}
// Any type implementing this must be public (or maybe internal is okay)?
protocol DependentDictionaryKey: DependentDictionaryKeyProtocol {
    associatedtype Value
}
extension DependentDictionaryKey {
    static var valueType: Any.Type { Self.Value.self }
    static func valueTypeContains(_ value: Any) -> Bool { value is Value }
}

// This must be public (but apparently it can be internal?)
protocol DependentDictionaryKeyWrapperProtocol: AnyObject {
    static var keyType: DependentDictionaryKeyProtocol.Type { get }
}
class DependentDictionaryKeyWrapper<Key: DependentDictionaryKeyProtocol>: DependentDictionaryKeyWrapperProtocol {
    static var keyType: DependentDictionaryKeyProtocol.Type { Key.self }
}

extension DependentDictionaryKeyProtocol {
    static var wrapper: DependentDictionaryKeyWrapperProtocol.Type { DependentDictionaryKeyWrapper<Self>.self }
}

struct DependentDictionary {
    struct KeyStorage: Hashable {
        let type: DependentDictionaryKeyProtocol.Type
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            ObjectIdentifier(lhs.type) == ObjectIdentifier(rhs.type)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self.type))
        }
    }

    private var storage: [KeyStorage: Any]
    
    init() {
        self.storage = [:]
    }
    
    // All keys must be unique. Each (key, value) pair must satisfy value: key.valueType
    init<S>(unsafeKeysWithValues: S) where S: Sequence, S.Element == (DependentDictionaryKeyProtocol.Type, Any) {
        self.storage = Dictionary(uniqueKeysWithValues: unsafeKeysWithValues.map({ (key, value) -> (KeyStorage, Any) in
            (KeyStorage(type: key), value)
        }))
    }
    
    struct UnsafeKeysWithValues: Collection {
        typealias Element = (key: DependentDictionaryKeyProtocol.Type, value: Any)
        typealias Index = Dictionary<KeyStorage, Any>.Index
        
        var startIndex: Index { storage.startIndex }
        var endIndex: Index { storage.endIndex }
        func index(after i: Index) -> Index {
            storage.index(after: i)
        }
        subscript(position: Index) -> (key: DependentDictionaryKeyProtocol.Type, value: Any) {
            let (keyStorage, value) = storage[position]
            return (keyStorage.type, value)
        }
        
        init(_ parent: DependentDictionary) {
            self.storage = parent.storage
        }
        
        private let storage: [KeyStorage: Any]
    }
    var unsafeKeysWithValues: UnsafeKeysWithValues { UnsafeKeysWithValues(self) }
    
    init(_ codableDependentDictionary: CodableDependentDictionary) {
        // Since CodableDependentDictionary satisfies essentially the same invariants as DependentDictionary, we can just use its unsafeKeysAndValues.
        // The .map({ $0 }) is just to make the type checker happy.
        self.init(unsafeKeysWithValues: codableDependentDictionary.unsafeKeysWithValues.map({ $0 }))
    }
    
    enum InvariantViolation: Error {
        case typeMismatch(keyType: DependentDictionaryKeyProtocol.Type, value: Any)
    }
    func verifyInvariant() throws {
        for (key, value) in storage {
            guard key.type.valueTypeContains(value) else {
                throw InvariantViolation.typeMismatch(keyType: key.type, value: value)
            }
        }
    }

    /// Unfortunately, there appears to be no way to check this invariant without an unnecessarily restrictive protocol.

    subscript<Key: DependentDictionaryKey>(_: Key.Type) -> Key.Value? {
        get {
            storage[KeyStorage(type: Key.self)] as? Key.Value // This cast will always succeed because of our invariant. It's just that the key might not exist in the dictionary.
        }
        set {
            storage[KeyStorage(type: Key.self)] = newValue // This maintains the invariant because value is guaranteed to be nil type Key.Value == Key.valueType
        }
    }
}

/**
 Codable Dependent Dictionary
 */

// Any type implementing this must be public (or maybe internal is okay)?
// You should only conform to this by conforming to CodableDependentDictionaryKey
protocol CodableDependentDictionaryKeyProtocol: DependentDictionaryKeyProtocol {
    static var valueType: Codable.Type { get }
}
// Any type implementing this must be public (or maybe internal is okay)?
protocol CodableDependentDictionaryKey: CodableDependentDictionaryKeyProtocol, DependentDictionaryKey where Value: Codable {}
extension CodableDependentDictionaryKey {
    static var valueType: Codable.Type { Self.Value.self }
}

// This must be public (but apparently it can be internal?)
protocol CodableDependentDictionaryKeyWrapperProtocol: AnyObject {
    static var keyType: CodableDependentDictionaryKeyProtocol.Type { get }
}
extension CodableDependentDictionaryKeyWrapperProtocol {
    static var keyType: DependentDictionaryKeyProtocol.Type { self.keyType }
}

class CodableDependentDictionaryKeyWrapper<Key: CodableDependentDictionaryKeyProtocol>: CodableDependentDictionaryKeyWrapperProtocol {
    static var keyType: CodableDependentDictionaryKeyProtocol.Type { Key.self }
}

extension CodableDependentDictionaryKeyProtocol {
    static var wrapper: CodableDependentDictionaryKeyWrapperProtocol.Type { CodableDependentDictionaryKeyWrapper<Self>.self }
}

extension Decodable {
    static func decode<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: K) throws -> Self {
        try container.decode(Self.self, forKey: key)
    }
}
extension Encodable {
    func encode<K: CodingKey>(into container: inout KeyedEncodingContainer<K>, forKey key: K) throws {
        try container.encode(self, forKey: key)
    }
}

struct CodableDependentDictionary: Codable {
    struct CodingKey: Swift.CodingKey {
        var stringValue: String
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int? { nil }
        init?(intValue: Int) { return nil }
    }
    struct KeyStorage: Hashable {
        let type: CodableDependentDictionaryKeyProtocol.Type
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            ObjectIdentifier(lhs.type) == ObjectIdentifier(rhs.type)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self.type))
        }
    }

    private var storage: [KeyStorage: Codable]
    
    init() {
        self.storage = [:]
    }
    
    // All keys must be unique. Each (key, value) pair must satisfy value: key.valueType
    init<S>(unsafeKeysWithValues: S) where S: Sequence, S.Element == (CodableDependentDictionaryKeyProtocol.Type, Codable) {
        self.storage = Dictionary(uniqueKeysWithValues: unsafeKeysWithValues.map({ (key, value) -> (KeyStorage, Codable) in
            (KeyStorage(type: key), value)
        }))
    }
    
    struct UnsafeKeysWithValues: Collection {
        typealias Element = (key: CodableDependentDictionaryKeyProtocol.Type, value: Codable)
        typealias Index = Dictionary<KeyStorage, Codable>.Index
        
        var startIndex: Index { storage.startIndex }
        var endIndex: Index { storage.endIndex }
        func index(after i: Index) -> Index {
            storage.index(after: i)
        }
        subscript(position: Index) -> (key: CodableDependentDictionaryKeyProtocol.Type, value: Codable) {
            let (keyStorage, value) = storage[position]
            return (keyStorage.type, value)
        }
        
        init(_ parent: CodableDependentDictionary) {
            self.storage = parent.storage
        }
        
        private let storage: [KeyStorage: Codable]
    }
    var unsafeKeysWithValues: UnsafeKeysWithValues { UnsafeKeysWithValues(self) }
    
    enum InvariantViolation: Error {
        case typeMismatch(keyType: CodableDependentDictionaryKeyProtocol.Type, value: Codable)
    }
    func verifyInvariant() throws {
        for (key, value) in storage {
            guard key.type.valueTypeContains(value) else {
                throw InvariantViolation.typeMismatch(keyType: key.type, value: value)
            }
        }
    }
    
    subscript<Key: CodableDependentDictionaryKey>(_: Key.Type) -> Key.Value? {
        get {
            storage[KeyStorage(type: Key.self)] as? Key.Value // This cast will always succeed because of our invariant. It's just that the key might not exist in the dictionary.
        }
        set {
            storage[KeyStorage(type: Key.self)] = newValue // This maintains the invariant because value is guaranteed to be nil type Key.Value == Key.valueType
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKey.self)
        for (key, value) in self.storage {
            let keyString = NSStringFromClass(key.type.wrapper)
            let codingKey = CodingKey(stringValue: keyString)
            try value.encode(into: &container, forKey: codingKey)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)
        
        self.storage = Dictionary(uniqueKeysWithValues: try container.allKeys.map({ codingKey in
            let keyString = codingKey.stringValue
            guard let wrapperType = NSClassFromString(keyString) as? CodableDependentDictionaryKeyWrapperProtocol.Type else {
                throw DecodingError.typeMismatch(CodableDependentDictionary.self, .init(codingPath: decoder.codingPath, debugDescription: "Decoding key \(keyString) was not a valid type. NSClassFromString returned nil or did not conform to CacheTableDataModelKeyWrapperProtocol.", underlyingError: nil))
            }
            let keyType = wrapperType.keyType
            let key = KeyStorage(type: keyType)
            let value = try keyType.valueType.decode(from: container, forKey: codingKey)
            
            return (key, value)
        }))
    }
}
