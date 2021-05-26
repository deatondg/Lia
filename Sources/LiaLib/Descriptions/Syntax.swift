import Algorithms

enum SyntaxError: Error {
    case repeatedSyntax(LocatedSyntaxDescription)
    case overlappingSyntax(LocatedSyntaxDescription)
}
struct Syntax {
    let originalDescription: LocatedSyntaxDescription?
    
    struct Pair {
        let open: String
        let close: String
        
        init(open: String, close: String) {
            self.open = open
            self.close = close
        }
    }
    let value: Pair
    let code: Pair
    let comment: Pair
    
    init(value: Pair, code: Pair, comment: Pair) {
        self.originalDescription = nil
        
        self.value = value
        self.code = code
        self.comment = comment
    }
    
    init(fromDescription description: LocatedSyntaxDescription, defaultSyntax: Syntax) throws {
        self.originalDescription = description
        
        let valueSyntax: Pair
        if let locatedValueSyntax = description.value {
            valueSyntax = .init(open: locatedValueSyntax.open.value, close: locatedValueSyntax.close.value)
        } else {
            valueSyntax = defaultSyntax.value
        }
        
        let codeSyntax: Pair
        if let locatedCodeSyntax = description.code {
            codeSyntax = .init(open: locatedCodeSyntax.open.value, close: locatedCodeSyntax.close.value)
        } else {
            codeSyntax = defaultSyntax.code
        }
        
        let commentSyntax: Pair
        if let locatedCommentSyntax = description.comment {
            commentSyntax = .init(open: locatedCommentSyntax.open.value, close: locatedCommentSyntax.close.value)
        } else {
            commentSyntax = defaultSyntax.comment
        }
        
        let syntaxSet = Set([valueSyntax.open, valueSyntax.close, codeSyntax.open, codeSyntax.close, commentSyntax.open, commentSyntax.close])
        guard syntaxSet.count == 6 else {
            throw SyntaxError.repeatedSyntax(description)
        }
        
        for syntaxPair in syntaxSet.permutations(ofCount: 2) {
            guard !syntaxPair[0].contains(syntaxPair[1]) else {
                throw SyntaxError.overlappingSyntax(description)
            }
        }
        
        self.value = valueSyntax
        self.code = codeSyntax
        self.comment = commentSyntax
    }
}
