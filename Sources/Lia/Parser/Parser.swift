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

precedencegroup ParsePrecedence {
    higherThan: AssignmentPrecedence
}
infix operator %>: ParsePrecedence
func %> <S: StringProtocol, P: Parser>(lhs: S, rhs: P) throws -> (P.Result, S.SubSequence) {
    try rhs.parse(from: lhs)
}
