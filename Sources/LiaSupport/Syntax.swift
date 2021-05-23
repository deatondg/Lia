public struct Syntax: Equatable, Codable {
    public struct Pair: Equatable, Codable {
        public let open: Located<String>
        public let close: Located<String>
        
        public init(open: Located<String>, close: Located<String>) {
            self.open = open
            self.close = close
        }
        public init(@LocatedBuilder open: () -> Located<String>, @LocatedBuilder close: () -> Located<String>) {
            self.init(open: open(), close: close())
        }
    }
    public let value: Pair?
    public let code: Pair?
    public let comment: Pair?
    
    public init(value: Pair? = nil, code: Pair? = nil, comment: Pair? = nil) {
        self.value = value
        self.code = code
        self.comment = comment
    }
}
