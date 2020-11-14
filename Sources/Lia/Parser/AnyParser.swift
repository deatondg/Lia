//
//  AnyParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/14/20.
//

import Foundation

struct AnyParser<Result>: Parser {
    let parsingFunction: (String) throws -> (Result, remainder: Substring)
    
    func parse<S: StringProtocol>(from string: S) throws -> (Result, remainder: S.SubSequence) {
        let (value, string) = try parsingFunction(String(string))
        return (value, S.SubSequence(stringLiteral: String(string)))
    }
}

extension Parser {
    func eraseToAnyParser() -> AnyParser<Result> {
        AnyParser(parsingFunction: self.parse)
    }
}
