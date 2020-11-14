//
//  Parser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

protocol Parser {
    associatedtype Result
    
    func parse<S: StringProtocol>(from string: S) throws -> (Result, remainder: S.SubSequence)
}
protocol Parsable {
    associatedtype Parser: Lia.Parser where Parser.Result == Self
    static var parser: Parser { get }
}
extension Parsable {
    static func parse<S: StringProtocol>(from string: S) throws -> (Self, remainder: S.SubSequence) {
        try parser.parse(from: string)
    }
}

precedencegroup ParsePrecedence {
    higherThan: AssignmentPrecedence
}
infix operator %>: ParsePrecedence
func %> <S: StringProtocol, P: Parser>(lhs: S, rhs: P) throws -> (P.Result, S.SubSequence) {
    try rhs.parse(from: lhs)
}
