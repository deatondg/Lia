//
//  ValueParsers.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

prefix operator %

struct CharacterParser: Parser {
    let character: Character
        
    func parse<S: StringProtocol>(from string: S) throws -> ((), remainder: S.SubSequence) {
        let (head, tail) = (string.first, string.dropFirst())
        if head == character {
            return ((), tail)
        } else {
            throw ParserError.patternNotFound
        }
    }
}
extension Parsers {
    static func character(_ character: Character) -> CharacterParser {
        CharacterParser(character: character)
    }
}
prefix func %(c: Character) -> CharacterParser {
    CharacterParser(character: c)
}

struct StringParser: Parser {
    let prefix: String
        
    func parse<S: StringProtocol>(from string: S) throws -> ((), remainder: S.SubSequence) {
        var prefixIndex = prefix.startIndex
        var stringIndex = string.startIndex
        while prefixIndex < prefix.endIndex && stringIndex < string.endIndex && prefix[prefixIndex] == string[stringIndex] {
            prefixIndex = prefix.index(after: prefixIndex)
            stringIndex = string.index(after: stringIndex)
        }
        if prefixIndex == prefix.endIndex {
            return ((), remainder: string[stringIndex...])
        } else {
            throw ParserError.patternNotFound
        }
    }
}
extension Parsers {
    static func string(_ prefix: String) -> StringParser {
        StringParser(prefix: prefix)
    }
}
prefix func %(s: String) -> StringParser {
    StringParser(prefix: s)
}

struct PredicateParser: Parser {
    let predicate: (Character) -> Bool
    
    func parse<S: StringProtocol>(from string: S) throws -> (String, remainder: S.SubSequence) {
        let index = string.firstIndex(where: predicate) ?? string.endIndex
        return (String(string[..<index]), string[index...])
    }
}
extension Parsers {
    static func predicate(_ predicate: @escaping (Character) -> Bool) -> PredicateParser {
        PredicateParser(predicate: predicate)
    }
}
prefix func %(p: @escaping (Character) -> Bool) -> PredicateParser {
    PredicateParser(predicate: p)
}


