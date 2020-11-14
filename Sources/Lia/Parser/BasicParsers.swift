//
//  BasicParsers.swift
//  Lia
//
//  Created by Davis Deaton on 11/14/20.
//

import Foundation

struct AlwaysParser: Parser {
    func parse<S: StringProtocol>(from string: S) throws -> ((), remainder: S.SubSequence) {
        return ((), string[...])
    }
}
extension Parsers {
    static var always: AlwaysParser { AlwaysParser() }
}

struct EmptyParser: Parser {
    func parse<S: StringProtocol>(from string: S) throws -> ((), remainder: S.SubSequence) {
        guard string.isEmpty else {
            throw ParserError.patternNotFound
        }
        return ((), string[...])
    }
}
extension Parsers {
    static var empty: EmptyParser { EmptyParser() }
}

struct ConstantParser<T>: Parser {
    let value: T
        
    func parse<S: StringProtocol>(from string: S) throws -> (T, remainder: S.SubSequence) {
        return (value, string[...])
    }
}
extension Parsers {
    static func constant<T>(_ value: T) -> ConstantParser<T> {
        ConstantParser(value: value)
    }
}

struct NeverParser<T>: Parser {
    func parse<S: StringProtocol>(from string: S) throws -> (T, remainder: S.SubSequence) {
        throw ParserError.never
    }
}
extension Parsers {
    static var never: NeverParser<()> { NeverParser() }
    static func never<T>(_ type: T.Type) -> NeverParser<T> {
        return NeverParser()
    }
}
