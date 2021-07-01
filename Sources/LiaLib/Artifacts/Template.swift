struct Template {
    let parameters: String
    let key: String
    let identifier: IdentifierPath
    
    enum Component {
        case literal
        case value
        case code
        case comment
    }
}
