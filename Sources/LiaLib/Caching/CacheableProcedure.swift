// Only conform to this through CacheableProcedure
protocol CacheableProcedureProtocol {
    static var tokenType: Codable.Type { get }
    static var enviornmentType: Any.Type { get }
    
    static var inputType: Any.Type { get }
//    static var contextType: (Hashable & Codable).Type { get }
    static var contextType: Codable.Type { get }
    
    static var outputType: Any.Type { get }
    static var entryType: Codable.Type { get }
    
    // Used in CacheTable
    static var cacheTableDataModelKey: (CodableDependentDictionaryKeyProtocol & CacheTableDataModelKeyProtocol).Type { get }
    static var cacheTableKey: (DependentDictionaryKeyProtocol & CacheTableKeyProtocol).Type { get }
    static func unsafeConvertDictToEntryDict(_ dict: Codable) -> Any
    static func unsafeConvertEntryDictToDict(_ entryDict: Any) -> Codable
}

protocol CacheableProcedure: CacheableProcedureProtocol {
    associatedtype Token: Codable
    associatedtype Enviornment
    
    associatedtype Input
    associatedtype Context: Hashable, Codable
    
    associatedtype Output
    associatedtype Entry: Codable
    
    static func context(for input: Input) throws -> Context
    static func create<C>(from input: Input, in cacher: C) async throws -> (Entry, () async throws -> Output) where C: CacheWriter, C.Token == Token, C.Enviornment == Enviornment
    static func create<C>(from input: Input, with entry: Entry, in cacher: C) async throws -> Output where C: CacheReader, C.Token == Token
}
extension CacheableProcedure {
    static var tokenType: Codable.Type { Token.self }
    static var enviornmentType: Any.Type { Enviornment.self }
    
    static var inputType: Any.Type { Input.self }
//    static var contextType: (Hashable & Codable).Type { Context.self }
    static var contextType: Codable.Type { Context.self }
    
    static var outputType: Any.Type { Output.self }
    static var entryType: Codable.Type { Entry.self }
    
    static var cacheTableDataModelKey: (CacheTableDataModelKeyProtocol & CodableDependentDictionaryKeyProtocol).Type {
        CacheTableDataModel.Key<Self>.self
    }
    static var cacheTableKey: (DependentDictionaryKeyProtocol & CacheTableKeyProtocol).Type {
        CacheTable.Key<Self>.self
    }
    
    static func convertDictToEntryDict(_ dict: [Context: Entry]) -> [Context: CacheTable.EntryContainer<Self>] {
        dict.mapValues({ .saved($0) })
    }
    static func unsafeConvertDictToEntryDict(_ dict: Codable) -> Any {
        convertDictToEntryDict(dict as! [Context: Entry])
    }
    
    static func convertEntryDictToDict(_ entryDict: [Context: CacheTable.EntryContainer<Self>]) -> [Context: Entry] {
        entryDict.compactMapValues({
            switch $0 {
            case .stage0(_):
                return nil
            case .stage1(let entry, _):
                return entry
            case .saved(let entry):
                return entry
            case .ready(let entry, _):
                return entry
            }
        })
    }
    static func unsafeConvertEntryDictToDict(_ entryDict: Any) -> Codable {
        convertEntryDictToDict(entryDict as! [Context: CacheTable.EntryContainer<Self>])
    }
}
