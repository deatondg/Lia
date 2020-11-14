//
//  AllOfParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct AllOfParser<C: Collection>: Parser where C.Element: Parser {
    let parsers: C
    
    func parse<S: StringProtocol>(from string: S) throws -> ([C.Element.Result], remainder: S.SubSequence) {
        var results = [C.Element.Result]()
        results.reserveCapacity(parsers.count)
        
        var string: S.SubSequence = string[...]
        for p in parsers {
            let result: C.Element.Result
            (result, string) = try string %> p
            results.append(result)
        }
        return (results, string)
    }
}
extension Parsers {
    static func allOf<C: Collection>(_ collection: C) -> AllOfParser<C> where C.Element: Parser {
        AllOfParser(parsers: collection)
    }
}

struct BothParser<P1: Parser, P2: Parser>: Parser {
    let p1: P1
    let p2: P2
    
    func parse<S: StringProtocol>(from string: S) throws -> ((P1.Result, P2.Result), remainder: S.SubSequence) {
        let r1: P1.Result
        let r2: P2.Result
        
        var substring: S.SubSequence
        (r1, substring) = try string %> p1
        (r2, substring) = try substring %> p2
        
        return ((r1,r2), substring)
    }
}

struct BothIgnoreFirstParser<P1: Parser, P2: Parser>: Parser {
    let p1: P1
    let p2: P2
    
    func parse<S: StringProtocol>(from string: S) throws -> (P2.Result, remainder: S.SubSequence) {
        let r2: P2.Result
        
        var substring: S.SubSequence
        (_, substring) = try string %> p1
        (r2, substring) = try substring %> p2
        
        return (r2, substring)
    }
}

struct BothIgnoreSecondParser<P1: Parser, P2: Parser>: Parser {
    let p1: P1
    let p2: P2
    
    func parse<S: StringProtocol>(from string: S) throws -> (P1.Result, remainder: S.SubSequence) {
        let r1: P1.Result
        
        var substring: S.SubSequence
        (r1, substring) = try string %> p1
        (_, substring) = try substring %> p2
        
        return (r1, substring)
    }
}

precedencegroup ParserAndPrecedence {
    higherThan: ParsePrecedence
    associativity: left
}
infix operator %& : ParserAndPrecedence

func %& <P1: Parser, P2: Parser>(lhs: P1, rhs: P2) -> BothIgnoreFirstParser<P1,P2> where P1.Result == () {
    return BothIgnoreFirstParser(p1: lhs, p2: rhs)
}
func %& <P1: Parser, P2: Parser>(lhs: P1, rhs: P2) -> BothIgnoreSecondParser<P1,P2> where P2.Result == () {
    return BothIgnoreSecondParser(p1: lhs, p2: rhs)
}
func %& <P1: Parser, P2: Parser>(lhs: P1, rhs: P2) -> BothParser<P1, P2> {
    BothParser(p1: lhs, p2: rhs)
}
