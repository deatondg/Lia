//
//  MapParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct MapParser<P: Parser, Result>: Parser {
    let parser: P
    let transform: (P.Result) throws -> Result
    
    func parse(from string: Substring) throws -> (Result, remainder: Substring) {
        let (value, remainder) = try string %> parser
        return (try transform(value), remainder)
    }
}
extension Parser {
    func map<T>(_ transform: @escaping (Result) throws -> T) -> MapParser<Self, T> {
        MapParser(parser: self, transform: transform)
    }
}

struct IgnoreParser<P: Parser>: Parser {
    let parser: P
    
    func parse(from string: Substring) throws -> ((), remainder: Substring) {
        let (_, string) = try string %> parser
        return ((), string)
    }
}
extension Parser {
    func ignore() -> IgnoreParser<Self> {
        return IgnoreParser(parser: self)
    }
}

struct MapErrorParser<P: Parser>: Parser {
    let parser: P
    let transform: (Error) -> Error
    
    func parse(from string: Substring) throws -> (P.Result, remainder: Substring) {
        do {
            return try string %> parser
        } catch {
            throw transform(error)
        }
    }
}
extension Parser {
    func mapError(_ transform: @escaping (Error) -> Error) -> MapErrorParser<Self> {
        MapErrorParser(parser: self, transform: transform)
    }
}
