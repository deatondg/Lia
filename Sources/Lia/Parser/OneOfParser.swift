//
//  OneOfParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct OneOfParser<C: Collection>: Parser where C.Element: Parser {
    let parsers: C
    
    func parse<S: StringProtocol>(from string: S) throws -> (C.Element.Result, remainder: S.SubSequence) {
        var errors: [Error] = []
        errors.reserveCapacity(parsers.count)
        for p in parsers {
            do {
                return try string %> p
            } catch {
                errors.append(error)
            }
        }
        throw ParserError.noMatch(errors)
    }
}
extension Parsers {
    static func oneOf<C: Collection>(_ parsers: C) -> OneOfParser<C> where C.Element: Parser {
        return OneOfParser(parsers: parsers)
    }
}


enum Either<First, Second> {
    case first(First)
    case second(Second)
}
extension Either: Parser where First: Parser, Second: Parser, First.Result == Second.Result {
    func parse<S: StringProtocol>(from string: S) throws -> (First.Result, remainder: S.SubSequence) {
        switch self {
        case .first(let parser):
            return try string %> parser
        case .second(let parser):
            return try string %> parser
        }
    }
}

struct EitherParser<P1: Parser, P2: Parser>: Parser {
    let p1: P1
    let p2: P2
    
    func parse<S: StringProtocol>(from string: S) throws -> (Either<P1.Result, P2.Result>, remainder: S.SubSequence) {
        do {
            let (r1, string) = try string %> p1
            return (.first(r1), string)
        } catch let e1 {
            do {
                let (r2, string) = try string %> p2
                return (.second(r2), string)
            } catch let e2 {
                throw ParserError.noMatch(e1, e2)
            }
        }
    }
}

precedencegroup ParserOrPrecedence {
    higherThan: ParsePrecedence
    associativity: left
}
infix operator %| : ParserOrPrecedence
func %| <P1: Parser, P2: Parser>(lhs: P1, rhs: P2) -> EitherParser<P1, P2> {
    return EitherParser(p1: lhs, p2: rhs)
}
