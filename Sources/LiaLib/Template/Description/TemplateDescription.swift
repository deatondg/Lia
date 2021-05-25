enum TemplateDescriptionError: Error {
    case invalidIdentifier(Error, LocatedTemplateDescription)
    case pathIsInvalidIdentifier(Error, LocatedTemplateDescription, Path, TemplateBundle)
    case invalidSyntax(Error, LocatedTemplateDescription, TemplateBundle)
}
struct TemplateDescription {
    let originalDescription: LocatedTemplateDescription?
    let originalPath: Path?
    
    let parameters: String
    let key: String
    let identifier: IdentifierPath
    let syntax: Syntax
    
    init(
        parameters: String,
        key: String,
        identifier: IdentifierPath,
        syntax: Syntax
    ) {
        self.originalDescription = nil
        self.originalPath = nil
        
        self.parameters = parameters
        self.key = key
        self.identifier = identifier
        self.syntax = syntax
    }
    
    /// `path` must be relative to `bundle.path`
    init(fromDescription description: LocatedTemplateDescription, at path: Path, in bundle: TemplateBundle) throws {
        self.originalDescription = description
        self.originalPath = path
        
        /// This is not an error in the template description, but in my code.
        /// Thus, we assert instead of throwing.
        assert(path.base == bundle.path)
        
        self.parameters = description.parameters?.value ?? bundle.defaultParameters
        self.key = description.key?.value ?? path.relativePath
        
        if let identifierString = description.identifier?.value {
            do {
                self.identifier = try IdentifierPath(identifierString)
            } catch {
                throw TemplateDescriptionError.invalidIdentifier(error, description)
            }
        } else {
            do {
                self.identifier = IdentifierPath(try path.components.map({ try Identifier(from: $0, handleInvalidCharactersWith: bundle.invalidIdentifierCharacterMethod) }))
            } catch {
                throw TemplateDescriptionError.pathIsInvalidIdentifier(error, description, path, bundle)
            }
        }
        
        do {
            self.syntax = try Syntax(fromDescription: description.syntax, defaultSyntax: bundle.defaultSyntax)
        } catch {
            throw TemplateDescriptionError.invalidSyntax(error, description, bundle)
        }
    }
}
