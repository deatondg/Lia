//
//  UntilParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct UntilSubstringParser: Parser {
    var substring: String
    
    init(_ substring: String) {
        self.substring = substring
    }
    
    func parse<S: StringProtocol>(from string: S) throws -> (String, remainder: S.SubSequence) {
        guard let range = string.range(of: substring) else {
            throw ParserError.patternNotFound
        }
        
        return (String(string[..<range.lowerBound]), string[range.upperBound...])
    }
}

struct UntilPredicateParser: Parser {
    var predicate: (Character) -> Bool
    
    init(_ predicate: @escaping (Character) -> Bool) {
        self.predicate = predicate
    }
    
    func parse<S: StringProtocol>(from string: S) throws -> (String, remainder: S.SubSequence) {
        guard let index = string.firstIndex(where: predicate) else {
            throw ParserError.patternNotFound
        }
        return ( String(string[..<index]) , string[index...] )
    }
}

struct UntilParsedParser<Parser: Lia.Parser, Until: Lia.Parser>: Lia.Parser {
    let p: Parser
    let until: Until
    
    func parse<S: StringProtocol>(from string: S) throws -> (([Parser.Result], Until.Result), remainder: S.SubSequence)  {
        var r1: [Parser.Result] = []
        var string = string[...]
        while !string.isEmpty {
            if let (r2, string) = try? until.parse(from: string) {
                return ((r1, r2), string)
            } else {
                let r: Parser.Result
                (r, string) = try string %> p
                r1.append(r)
            }
        }
        throw ParserError.parserNeverMatched
    }
}

extension Parser {
    func until<U: Parser>(_ other: U) -> MapParser<UntilParsedParser<Self, U>, [Self.Result]> where U.Result == () {
        let until: UntilParsedParser<Self, U> = self.until(other)
        return until.map({ $0.0 })
    }
    func until<U: Parser>(_ other: U) -> UntilParsedParser<Self, U> {
        UntilParsedParser(p: self, until: other)
    }
}
