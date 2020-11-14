//
//  Template.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct Template: Parsable {
    enum Field: String, CaseIterable, Parsable {
        case name = "name"
        case args = "args"
        case key = "key"
    }
    typealias Header = [Field: String]
    
    static let parser = headerParser.flatMap({
                                                Parsers.constant($0) %& bodyParser(for: $0)
    }).map({ Template(header: $0, body: $1) })
    
    static let headerParser =
        (%Syntax.beginHeader %| Parsers.constant(Header()))
            .flatMapFirst({
                (Parsers.whitespace.ignore()
                    %& Template.Field.parser
                    %& Parsers.whitespace.ignore()
                    %& (%Syntax.fieldSeparator).mapError({ _ in ParserError.badSyntax })
                    %& Parsers.whitespace.ignore()
                    %& Parsers.line.mapError({ _ in ParserError.incompleteHeader }).map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                )
                    .until(%Syntax.endHeader)
                    //.mapError({ _ in ParserError.incompleteHeader })
                    .map({
                            try Header($0, uniquingKeysWith: { _,_ in throw ParserError.repeatedHeaderField })
                        
                    })
                    %& Parsers.emptyLine.mapError({ _ in ParserError.headerEndRequiresNewLine }).ignore()
            })
    
    static func bodyParser(for header: Header) -> MapParser<UntilEmptyParser<MapParser<EitherParser<MapParser<UntilParsedParser<FlatMapParser<BothIgnoreFirstParser<StringParser, MapParser<EitherParser<EitherParser<MapParser<StringParser, Syntax>, MapParser<StringParser, Syntax>>, MapParser<StringParser, Syntax>>, Syntax>>, MapParser<UntilSubstringParser, BodyElement>>>, Array<BodyElement>>, MapParser<String.Parser, Array<BodyElement>>>, Array<BodyElement>>>, Array<BodyElement>> {
        let key = header[.key] ?? ""
        let beginKey = key + "{"
        let closeKey = "}" + key.reversed()
        
        let parseBeginKey = Parsers.string(beginKey) %& (
                Parsers.string(Syntax.value.beginKey).map({ Syntax.value })
                %| Parsers.string(Syntax.code.beginKey).map({ Syntax.code })
                %| Parsers.string(Syntax.comment.beginKey).map({ Syntax.comment })
            ).map({ x -> Syntax in
                switch x {
                case .first(let x):
                    switch x {
                    case .first(let s):
                        return s
                    case .second(let s):
                        return s
                    }
                case .second(let s):
                    return s
                }
            })
        
        let parseSyntax = parseBeginKey.flatMap({ s in
            Parsers.until(substring: s.closeKey + closeKey).map({ x -> BodyElement in
                switch s {
                case .value:
                    return BodyElement.value(x)
                case .code:
                    return BodyElement.code(x)
                case .comment:
                    return BodyElement.comment(x)
                }
            })
        })
        
        let parseBodySection = (Parsers.until(parseSyntax).map({ [.literal($0), $1] }) %| String.parser.map({ [BodyElement.literal($0)] })).map({ x -> [BodyElement] in
            switch x {
            case .first(let r):
                return r
            case .second(let r):
                return r
            }
        })
        
        let parseBody = parseBodySection.untilEmpty().map({ Array($0.joined()) })
        
        return parseBody
    }
        
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
    static let parser = Template.headerParser
}
