//
//  BasicParsers.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct TrivialParser: Parser {
    func parse<S: StringProtocol>(from string: S) throws -> ((), remainder: S.SubSequence) {
        return ((), string[...])
    }
}

struct ConstantParser<T>: Parser {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    func parse<S: StringProtocol>(from string: S) throws -> (T, remainder: S.SubSequence) {
        return (value, string[...])
    }
}

struct NeverParser<T>: Parser {
    func parse<S: StringProtocol>(from string: S) throws -> (T, remainder: S.SubSequence) {
        throw ParserError.never
    }
}

prefix operator %

struct CharacterParser: Parser {
    let character: Character
    
    init(_ character: Character) {
        self.character = character
    }
    
    func parse<S: StringProtocol>(from string: S) throws -> ((), remainder: S.SubSequence) {
        let (head, tail) = (string.first, string.dropFirst())
        if head == character {
            return ((), tail)
        } else {
            throw ParserError.patternNotFound
        }
    }
}
prefix func %(c: Character) -> CharacterParser {
    CharacterParser(c)
}

struct StringParser: Parser {
    let prefix: String
    
    init(_ prefix: String) {
        self.prefix = prefix
    }
    
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
prefix func %(s: String) -> StringParser {
    StringParser(s)
}

struct PredicateParser: Parser {
    let predicate: (Character) -> Bool
    
    init(_ predicate: @escaping (Character) -> Bool) {
        self.predicate = predicate
    }
    
    func parse<S: StringProtocol>(from string: S) throws -> (String, remainder: S.SubSequence) {
        let index = string.firstIndex(where: predicate) ?? string.endIndex
        return (String(string[..<index]), string[index...])
    }
}
prefix func %(p: @escaping (Character) -> Bool) -> PredicateParser {
    PredicateParser(p)
}


