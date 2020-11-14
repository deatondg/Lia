//
//  UntilParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct UntilSubstringParser: Parser {
    var substring: String
        
    func parse<S: StringProtocol>(from string: S) throws -> (String, remainder: S.SubSequence) {
        guard let range = string.range(of: substring) else {
            throw ParserError.patternNotFound
        }
        
        return (String(string[..<range.lowerBound]), string[range.upperBound...])
    }
}
extension Parsers {
    static func until(substring: String) -> UntilSubstringParser {
        UntilSubstringParser(substring: substring)
    }
}

struct UntilPredicateParser: Parser {
    var predicate: (Character) throws -> Bool
        
    func parse<S: StringProtocol>(from string: S) throws -> (String, remainder: S.SubSequence) {
        
        guard let index = try string.firstIndex(where: predicate) else {
            throw ParserError.patternNotFound
        }
        return ( String(string[..<index]) , string[index...] )
    }
}
extension Parsers {
    static func until(_ predicate: @escaping (Character) throws -> Bool) -> UntilPredicateParser {
        UntilPredicateParser(predicate: predicate)
    }
}

struct UntilParsedParser<P: Parser>: Parser {
    let parser: P
    
    func parse<S: StringProtocol>(from string: S) throws -> ((String, P.Result), remainder: S.SubSequence) {
        var index = string.startIndex
        while index < string.endIndex {
            do {
                let (r,substring) = try string[index...] %> parser
                return ((String(string[..<index]),r), substring)
            } catch {
                index = string.index(after: index)
            }
        }
        throw ParserError.parserNeverMatched
    }
}
extension Parsers {
    static func until<P: Parser>(_ parser: P) -> UntilParsedParser<P> {
        return UntilParsedParser(parser: parser)
    }
}

struct UntilEmptyParser<P: Parser>: Parser {
    let parser: P
    
    func parse<S: StringProtocol>(from string: S) throws -> ([P.Result], remainder: S.SubSequence) {
        var string = string[...]
        var results: [P.Result] = []
        while !string.isEmpty {
            let result: P.Result
            (result, string) = try string %> parser
            results.append(result)
        }
        return (results, string)
    }
}
extension Parser {
    func untilEmpty() -> UntilEmptyParser<Self> {
        return UntilEmptyParser(parser: self)
    }
}

struct ParseUntilParsedParser<Parser: Lia.Parser, Until: Lia.Parser>: Lia.Parser {
    let p: Parser
    let until: Until
    
    func parse<S: StringProtocol>(from string: S) throws -> (([Parser.Result], Until.Result), remainder: S.SubSequence)  {
        var r1: [Parser.Result] = []
        var string = string[...]
        repeat {
            if let (r2, string) = try? string %> until {
                return ((r1, r2), string)
            } else {
                let r: Parser.Result
                (r, string) = try string %> p
                r1.append(r)
            }
        } while !string.isEmpty
        throw ParserError.parserNeverMatched
    }
}
extension Parser {
    func until<U: Parser>(_ other: U) -> MapParser<ParseUntilParsedParser<Self, U>, [Self.Result]> where U.Result == () {
        let until: ParseUntilParsedParser<Self, U> = self.until(other)
        return until.map({ $0.0 })
    }
    func until<U: Parser>(_ other: U) -> ParseUntilParsedParser<Self, U> {
        ParseUntilParsedParser(p: self, until: other)
    }
}
