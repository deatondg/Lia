protocol CacheReader {
    associatedtype Token: Codable
    
    func path(for token: Token) -> Path
}
protocol CacheWriter: CacheReader {
    associatedtype Enviornment
    
    var enviornment: Enviornment { get }
    
    func newToken() async -> Token
    func newToken(withExtension `extension`: String) async -> Token
}
