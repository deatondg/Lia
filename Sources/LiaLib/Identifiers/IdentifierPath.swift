/// An IdentifierPath represents a path of Swift identifiers, separated by dots.
struct IdentifierPath {
    let components: [Identifier]
    
    var parent: IdentifierPath? {
        if components.isEmpty {
            return nil
        } else {
            return IdentifierPath(components.dropLast())
        }
    }
    var lastComponent: Identifier? { components.last }
    
    init(_ components: [Identifier]) {
        self.components = components
    }
    
    init(from path: Path, handleInvalidCharactersWith invalidCharacterMethod: InvalidIdentifierCharacterMethod) throws {
        self.components = try path.components.map({ try Identifier(from: $0, handleInvalidCharactersWith: invalidCharacterMethod) })
    }
    init(_ string: String) throws {
        self.components = try string.split(separator: ".", omittingEmptySubsequences: false)
            .map(String.init)
            .map({ try Identifier(from: $0, handleInvalidCharactersWith: .fail) })
    }
}

extension IdentifierPath: CustomStringConvertible {
    var description: String {
        components.map(\.description).joined(separator: ".")
    }
}
