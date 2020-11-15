//
//  AnyParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/15/20.
//

import Foundation

struct AnyParser<T>: Parser {
    let parser: (Substring) throws -> (T, remainder: Substring)
    
    func parse(from string: Substring) throws -> (T, remainder: Substring) {
        try self.parser(string)
    }
}
extension Parser {
    func eraseToAnyParser() -> AnyParser<Result> {
        return AnyParser(parser: self.parse)
    }
}
