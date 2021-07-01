// TODO: Maybe make these handle a specific token type once the protocols are less annoying.

protocol CacheTableDataModelKeyProtocol {
    static var procedure: CacheableProcedureProtocol.Type { get }
}

// [CacheableProcedure (Key): [Key.Context: Key.Entry]]
struct CacheTableDataModel: Codable {
    // Invariants: All keys are of the form Key<P> for some P
    // If storage[key] is nil or is a non-empty dictionary
    private var storage: CodableDependentDictionary
    
    init() {
        self.storage = CodableDependentDictionary()
    }
    
    // All keys must be unique. Each (procedure, dictionary) pair must satisfy dictionary: [procedure.contextType, procedure.entryType]
    init<S>(unsafeProceduresWithDictionaries: S) where S: Sequence, S.Element == (CacheableProcedureProtocol.Type, Codable) {
        self.storage = CodableDependentDictionary(unsafeKeysWithValues: unsafeProceduresWithDictionaries.map({ (procedure, dictionary) in
            (procedure.cacheTableDataModelKey, dictionary)
        }))
    }
    
    struct UnsafeProceduresWithDictionaries: Collection {
        typealias Element = (procedure: CacheableProcedureProtocol.Type, dictionary: Codable)
        typealias Index = CodableDependentDictionary.UnsafeKeysWithValues.Index
        
        var startIndex: Index { storage.startIndex }
        var endIndex: Index { storage.endIndex }
        func index(after i: Index) -> Index {
            storage.index(after: i)
        }
        subscript(position: Index) -> (procedure: CacheableProcedureProtocol.Type, dictionary: Codable) {
            let (key, value) = storage[position]
            return ( (key as! CacheTableDataModelKeyProtocol.Type).procedure , value)
        }
        
        init(_ parent: CacheTableDataModel) {
            self.storage = parent.storage.unsafeKeysWithValues
        }
        
        private let storage: CodableDependentDictionary.UnsafeKeysWithValues
    }
    var unsafeProceduresWithDictionaries: UnsafeProceduresWithDictionaries { UnsafeProceduresWithDictionaries(self) }
    
    enum Key<P: CacheableProcedure>: CodableDependentDictionaryKey, CacheTableDataModelKeyProtocol {
        typealias Value = [P.Context: P.Entry]
        
        static var procedure: CacheableProcedureProtocol.Type { P.self }
    }
    
    subscript<P: CacheableProcedure>(procedure: P.Type, context: P.Context) -> P.Entry? {
        get {
            let key = Key<P>.self
            return storage[key]?[context]
        }
        set {
            let key = Key<P>.self
            if let newValue = newValue {
                if storage[key] == nil {
                    storage[key] = [:]
                }
                storage[key]![context] = newValue
            } else {
                if storage[key] != nil {
                    storage[key]![context] = nil
                    if storage[key]!.isEmpty {
                        storage[key] = nil
                    }
                }
            }
        }
    }
}

protocol CacheTableKeyProtocol {
    static var procedure: CacheableProcedureProtocol.Type { get }
}

// [CacheableProcedure (Key): [Key.Context: CacheTable.EntryContainer<Key>]]
struct CacheTable {
    // Invariants: All keys are of the form Key<P> for some P
    // If storage[key] is nil or is a non-empty dictionary
    fileprivate var storage: DependentDictionary
    
    init() {
        self.storage = DependentDictionary()
    }
    
    // All keys must be unique. Each (procedure, dictionary) pair must satisfy dictionary: [procedure.contextType, EntryContainer<procedure>]
    init<S>(unsafeProceduresWithDictionaries: S) where S: Sequence, S.Element == (CacheableProcedureProtocol.Type, Any) {
        self.storage = DependentDictionary(unsafeKeysWithValues: unsafeProceduresWithDictionaries.map({ (procedure, dictionary) in
            (procedure.cacheTableKey, dictionary)
        }))
    }
    
    struct UnsafeProceduresWithDictionaries: Collection {
        typealias Element = (procedure: CacheableProcedureProtocol.Type, dictionary: Any)
        typealias Index = DependentDictionary.UnsafeKeysWithValues.Index
        
        var startIndex: Index { storage.startIndex }
        var endIndex: Index { storage.endIndex }
        func index(after i: Index) -> Index {
            storage.index(after: i)
        }
        subscript(position: Index) -> (procedure: CacheableProcedureProtocol.Type, dictionary: Any) {
            let (key, value) = storage[position]
            return ( (key as! CacheTableKeyProtocol.Type).procedure , value)
        }
        
        init(_ parent: CacheTable) {
            self.storage = parent.storage.unsafeKeysWithValues
        }
        
        private let storage: DependentDictionary.UnsafeKeysWithValues
    }
    var unsafeProceduresWithDictionaries: UnsafeProceduresWithDictionaries { UnsafeProceduresWithDictionaries(self) }
    
    init(_ dataModel: CacheTableDataModel) {
        self.init(unsafeProceduresWithDictionaries: dataModel.unsafeProceduresWithDictionaries.map({ (procedure, dict) in
            (procedure, procedure.unsafeConvertDictToEntryDict(dict))
        }))
    }
    var dataModel: CacheTableDataModel {
        CacheTableDataModel(unsafeProceduresWithDictionaries: self.unsafeProceduresWithDictionaries.map({ (procedure, dict) in
            (procedure, procedure.unsafeConvertEntryDictToDict(dict))
        }))
    }
    
    enum EntryContainer<P: CacheableProcedure> {
        case saved(P.Entry)
        case stage0(Task<(P.Entry, Task<P.Output, Error>), Error>)
        case stage1(P.Entry, Task<P.Output, Error>)
        case ready(P.Entry, P.Output)
    }
    enum Key<P: CacheableProcedure>: DependentDictionaryKey, CacheTableKeyProtocol {
        typealias Value = [P.Context: EntryContainer<P>]
        
        static var procedure: CacheableProcedureProtocol.Type { P.self }
    }
    
    subscript<P: CacheableProcedure>(procedure: P.Type, context: P.Context) -> EntryContainer<P>? {
        get {
            let key = Key<P>.self
            return storage[key]?[context]
        }
        set {
            let key = Key<P>.self
            if let newValue = newValue {
                if storage[key] == nil {
                    storage[key] = [:]
                }
                storage[key]![context] = newValue
            } else {
                if storage[key] != nil {
                    storage[key]![context] = nil
                    if storage[key]!.isEmpty {
                        storage[key] = nil
                    }
                }
            }
        }
    }
}
