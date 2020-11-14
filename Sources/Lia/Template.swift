//
//  Template.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct Template {
    enum Field: String, CaseIterable, Parsable {
        case name = "name"
        case args = "args"
        case key = "key"
    }
    typealias Header = [Field: String]
    
    enum BodyElement {
        case literal(String)
        case value(String)
        case code(String)
        case comment(String)
    }
    var header: Header
    var body: [BodyElement]
}

extension Template.Header: Parsable {
    struct Parser: Lia.Parser {
        func parse<S: StringProtocol>(from string: S) throws -> (Template.Header, remainder: S.SubSequence) {
            return try string %>
                (%Syntax.beginHeader %| TrivialParser())
                .eraseToAnyParser()
                .flatMap({ x -> AnyParser<Template.Header> in
                    switch x {
                    case .first():
                        let whitespaceParser = UntilPredicateParser({ !$0.isWhitespace }).map({ _ in })
                        return (
                            (whitespaceParser
                                %& Template.Field.parser
                                %& whitespaceParser
                                %& (%Syntax.fieldSeparator).mapError({ _ in ParserError.badSyntax })
                                %& whitespaceParser
                                %& UntilSubstringParser("\n").mapError({ _ in ParserError.incompleteHeader })
                            )
                            .map({ ($0, $1.trimmingCharacters(in: .whitespacesAndNewlines)) })
                            .until(%Syntax.endHeader)
                            //.mapError({ _ in ParserError.incompleteHeader })
                            .map({ try Template.Header($0, uniquingKeysWith: { _,_ in throw ParserError.repeatedHeaderField }) })
                            %& UntilSubstringParser("\n")
                                .mapError({ _ in ParserError.headerEndRequiresNewLine })
                                .map({ guard $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw ParserError.headerEndRequiresNewLine } })
                        )
                        .eraseToAnyParser()
                    case .second():
                        return ConstantParser(Template.Header()).eraseToAnyParser()
                    }
                })
        }
    }
    
    static var parser: Parser {
        Parser()
    }
}
