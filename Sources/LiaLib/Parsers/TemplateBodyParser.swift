import Parsers
import Foundation

enum SyntaxPiece: String, CaseIterable {
    case valueOpen
    case valueClose
    case codeOpen
    case codeClose
    case commentOpen
    case commentClose
    
    init(type: SyntaxType, kind: SyntaxKind) {
        switch (type, kind) {
        case (.value, .open):
            self = .valueOpen
        case (.value, .close):
            self = .valueClose
        case (.code, .open):
            self = .codeOpen
        case (.code, .close):
            self = .codeClose
        case (.comment, .open):
            self = .commentOpen
        case (.comment, .close):
            self = .commentClose
        }
    }
    
    var type: SyntaxType {
        switch self {
        case .valueOpen, .valueClose:
            return .value
        case .codeOpen, .codeClose:
            return .code
        case .commentOpen, .commentClose:
            return .comment
        }
    }
    
    var kind: SyntaxKind {
        switch self {
        case .valueOpen, .codeOpen, .commentOpen:
            return .open
        case .valueClose, .codeClose, .commentClose:
            return .close
        }
    }
}

enum SyntaxType {
    case value
    case code
    case comment
    
    var openPiece: SyntaxPiece {
        switch self {
        case .value:
            return .valueOpen
        case .code:
            return .codeOpen
        case .comment:
            return .commentOpen
        }
    }
    var closePiece: SyntaxPiece {
        switch self {
        case .value:
            return .valueClose
        case .code:
            return .codeClose
        case .comment:
            return .commentClose
        }
    }
    
    var templateComponent: Template.Component {
        switch self {
        case .value:
            return .value
        case .code:
            return .code
        case .comment:
            return .comment
        }
    }
}

enum SyntaxKind {
    case open
    case close
}

extension Syntax {
    subscript(_ syntaxPiece: SyntaxPiece) -> String {
        switch syntaxPiece {
        case .valueOpen:
            return self.value.open
        case .valueClose:
            return self.value.close
        case .codeOpen:
            return self.code.open
        case .codeClose:
            return self.code.close
        case .commentOpen:
            return self.comment.open
        case .commentClose:
            return self.comment.close
        }
    }
    subscript(_ syntaxType: SyntaxType, _ syntaxKind: SyntaxKind) -> String {
        self[SyntaxPiece(type: syntaxType, kind: syntaxKind)]
    }
}

struct NextSyntaxParser: ParserFromBuilder {
    typealias Output = (prefix: Substring, piece: SyntaxPiece)
    typealias Failure = NoMatchFailure
    
    let syntaxExpression: NSRegularExpression
    
    init(for syntax: Syntax) {
        let syntaxPattern =
            "(?:"
            + SyntaxPiece.allCases.map({ syntaxType in
                let syntaxPattern = NSRegularExpression.escapedPattern(for: syntax[syntaxType])
                return "(?<\(syntaxType.rawValue)>\(syntaxPattern)"
            }).joined(separator: "|")
            + ")"
        self.syntaxExpression = try! NSRegularExpression(pattern: syntaxPattern, options: [])
    }
    
    var parser: Parser<Output, Failure> {
        self.syntaxExpression.nextMatchParser().map({ (prefix, match) -> (prefix: Substring, piece: SyntaxPiece) in
            assert( SyntaxPiece.allCases.filter({ match[named: $0.rawValue] != nil }).count == 1 )
            for piece in SyntaxPiece.allCases where match[named: piece.rawValue] != nil {
                return (prefix, piece)
            }
            fatalError("Impossibility in NextSyntaxParser.")
        })
    }
}

struct NextSyntaxPairParser: ParserFromBuilder {
    typealias Output = (literalPrefix: Substring, content: Substring, syntaxType: SyntaxType)
    enum Failure: Error {
        case noMoreSyntax
        case failure(TemplateBodyParserFailure)
    }
    
    let nextSyntaxParser: NextSyntaxParser
    
    init(for syntax: Syntax) {
        self.nextSyntaxParser = .init(for: syntax)
    }
    
    var parser: Parser<(literalPrefix: Substring, content: Substring, syntaxType: SyntaxType), Failure> {
        nextSyntaxParser
            .flatMap({ (literalPrefix, openPiece) -> Result<Parser<(literalPrefix: Substring, content: Substring, syntaxType: SyntaxType), TemplateBodyParserFailure>, TemplateBodyParserFailure> in
                guard openPiece.kind == .open else {
                    return .failure(.unexpectedCloseDelimiter)
                }
                return .success(nextSyntaxParser
                                    .map({ (content, closePiece) -> Result<(literalPrefix: Substring, content: Substring, syntaxType: SyntaxType), TemplateBodyParserFailure> in
                                        guard closePiece == openPiece.type.closePiece else {
                                            return .failure(.expectedCloseDelimiter(openPiece.type))
                                        }
                                        return .success((literalPrefix, content, openPiece.type))
                                    
                                    })
                                    .mapFailures({ f -> TemplateBodyParserFailure in
                                        switch f {
                                        case .parseFailure:
                                            return .unmatchedOpenDelimeter
                                        case .mapFailure(let f):
                                            return f
                                        }
                                    }))
                
            })
            .mapFailures({ f -> Failure in
                switch f {
                case .outerFailure:
                    return .noMoreSyntax
                case .mapFailure(let f):
                    return .failure(f)
                case .innerFailure(let f):
                    return .failure(f)
                }
            })
    }
}

enum TemplateBodyParserFailure: Error {
    // TODO: Add indices
    case unexpectedCloseDelimiter
    case expectedCloseDelimiter(SyntaxType)
    case unmatchedOpenDelimeter
}

struct TemplateBodyParser: ParserFromBuilder {
    typealias Output = [(Substring, Template.Component)]
    typealias Failure = TemplateBodyParserFailure
    
    let nextSyntaxPairParser: NextSyntaxPairParser
    
    init(for syntax: Syntax) {
        self.nextSyntaxPairParser = .init(for: syntax)
    }
    
    var parser: Parser<[(Substring, Template.Component)], TemplateBodyParserFailure> {
        nextSyntaxPairParser
            .map({ (literalPrefix, content, syntaxType) -> [(Substring, Template.Component)] in
                (literalPrefix.isEmpty ? [] : [(literalPrefix, .literal)]) + [(content, syntaxType.templateComponent)]
            })
            .catch({ f -> Result<Parser<[(Substring, Template.Component)], Never>, TemplateBodyParserFailure> in
                switch f {
                case .noMoreSyntax:
                    return .success(Parsers.remainder().map({ [($0, Template.Component.literal)] }))
                case .failure(let f):
                    return .failure(f)
                }
            })
            .repeatUntilEnd()
            .map({ Array($0.joined()) })
            .mapFailures({ $0.parseFailure })
    }
}
