//
//  Parsable.swift
//  Lia
//
//  Created by Davis Deaton on 11/14/20.
//

import Foundation

protocol Parsable {
    associatedtype Parser: ParserProtocol where Parser.Result == Self
    static var parser: Parser { get }
}
extension Parsable {
    static func parse(from string: Substring) throws -> (Self, remainder: Substring) {
        try string %> Self.parser
    }
    static func parse(from string: String) throws -> (Self, remainder: Substring) {
        try string %> Self.parser
    }
}
typealias ParserProtocol = Parser

extension Character: Parsable {
    struct Parser: ParserProtocol {
        func parse(from string: Substring) throws -> (Character, remainder: Substring) {
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
    struct Parser: ParserProtocol {
        func parse(from string: Substring) throws -> (String, remainder: Substring) {
            return (String(string), string[string.endIndex...])
        }
    }
    static let parser: Parser = Parser()
}
