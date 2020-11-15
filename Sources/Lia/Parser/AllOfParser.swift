//
//  AllOfParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct AllOfParser<C: Collection>: Parser where C.Element: Parser {
    let parsers: C
    
    func parse(from string: Substring) throws -> ([C.Element.Result], remainder: Substring) {
        var results = [C.Element.Result]()
        results.reserveCapacity(parsers.count)
        
        var string = string
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
    
    func parse(from string: Substring) throws -> ((P1.Result, P2.Result), remainder: Substring) {
        let r1: P1.Result
        let r2: P2.Result
        
        var string = string
        (r1, string) = try string %> p1
        (r2, string) = try string %> p2
        
        return ((r1,r2), string)
    }
}

struct BothIgnoreFirstParser<P1: Parser, P2: Parser>: Parser {
    let p1: P1
    let p2: P2
    
    func parse(from string: Substring) throws -> (P2.Result, remainder: Substring) {
        let r2: P2.Result
        
        var string = string
        (_, string) = try string %> p1
        (r2, string) = try string %> p2
        
        return (r2, string)
    }
}

struct BothIgnoreSecondParser<P1: Parser, P2: Parser>: Parser {
    let p1: P1
    let p2: P2
    
    func parse(from string: Substring) throws -> (P1.Result, remainder: Substring) {
        let r1: P1.Result
        
        var string = string
        (r1, string) = try string %> p1
        (_, string) = try string %> p2
        
        return (r1, string)
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
