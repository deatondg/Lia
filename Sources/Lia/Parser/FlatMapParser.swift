//
//  FlatMapParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/14/20.
//

import Foundation

struct FlatMapParser<P1: Parser, P2: Parser>: Parser {
    let parser: P1
    let transform: (P1.Result) throws -> P2

    func parse<S: StringProtocol>(from string: S) throws -> (P2.Result, remainder: S.SubSequence) {
        let (r1, string) = try string %> parser
        let p2 = try transform(r1)
        return try string %> p2
    }
}

extension Parser {
    func flatMap<P: Parser>(_ transform: @escaping (Result) -> P) -> FlatMapParser<Self, P> {
        return FlatMapParser(parser: self, transform: transform)
    }
}
