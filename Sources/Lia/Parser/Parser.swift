//
//  Parser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

protocol Parser {
    associatedtype Result
    
    func parse(from string: Substring) throws -> (Result, remainder: Substring)
}

precedencegroup ParsePrecedence {
    higherThan: AssignmentPrecedence
}
infix operator %>: ParsePrecedence
func %> <P: Parser>(lhs: String, rhs: P) throws -> (P.Result, Substring) {
    try rhs.parse(from: lhs[...])
}
func %> <P: Parser>(lhs: Substring, rhs: P) throws -> (P.Result, Substring) {
    try rhs.parse(from: lhs)
}

