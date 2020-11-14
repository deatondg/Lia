//
//  Parsable.swift
//  Lia
//
//  Created by Davis Deaton on 11/14/20.
//

import Foundation

protocol Parsable {
    associatedtype Parser: Lia.Parser where Parser.Result == Self
    static var parser: Parser { get }
}
extension Parsable {
    static func parse<S: StringProtocol>(from string: S) throws -> (Self, remainder: S.SubSequence) {
        try parser.parse(from: string)
    }
}

extension Character: Parsable {
    struct Parser: Lia.Parser {
        func parse<S: StringProtocol>(from string: S) throws -> (Character, remainder: S.SubSequence) {
            let (maybeHead, tail) = (string.first, string.dropFirst())
            guard let head = maybeHead else {
                throw ParserError.empty
            }
            return (head, tail)
        }
    }
    static let parser: Parser = Parser()
}

extension String: Parsable {
    struct Parser: Lia.Parser {
        func parse<S: StringProtocol>(from string: S) throws -> (String, remainder: S.SubSequence) {
            return (String(string), string[string.endIndex...])
        }
    }
    static let parser: Parser = Parser()
}
