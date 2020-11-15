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

    func parse(from string: Substring) throws -> (P2.Result, remainder: Substring) {
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

struct FlatMapFirstParser<P1: Parser, First, Second, P2: Parser>: Parser where P1.Result == Either<First, Second> {
    let parser: P1
    let transform: (First) throws -> P2
    
    func parse(from string: Substring) throws -> (Either<P2.Result, Second>, remainder: Substring) {
        let (r1, string) = try string %> parser
        switch r1 {
        case .first(let r1):
            let (r2, string) = try string %> transform(r1)
            return (.first(r2), string)
        case .second(let r1):
            return (.second(r1), string)
        }
    }
}
extension Parser {
    func flatMapFirst<P: Parser, First, Second>(_ transform: @escaping (First) -> P) -> FlatMapFirstParser<Self, First, Second, P> where Result == Either<First, Second> {
        FlatMapFirstParser(parser: self, transform: transform)
    }
}

struct FlatMapSecondParser<P1: Parser, First, Second, P2: Parser>: Parser where P1.Result == Either<First, Second> {
    let parser: P1
    let transform: (Second) throws -> P2
    
    func parse(from string: Substring) throws -> (Either<First, P2.Result>, remainder: Substring) {
        let (r1, string) = try string %> parser
        switch r1 {
        case .first(let r1):
            return (.first(r1), string)
        case .second(let r1):
            let (r2, string) = try string %> transform(r1)
            return (.second(r2), string)
        }
    }
}
extension Parser {
    func flatMapSecond<P: Parser, First, Second>(_ transform: @escaping (Second) -> P) -> FlatMapSecondParser<Self, First, Second, P> where Result == Either<First, Second> {
        FlatMapSecondParser(parser: self, transform: transform)
    }
}

struct FlatMapFirstReduceParser<P1: Parser, First, P2: Parser>: Parser where P1.Result == Either<First, P2.Result> {
    let parser: P1
    let transform: (First) throws -> P2
    
    func parse(from string: Substring) throws -> (P2.Result, remainder: Substring) {
        let (r1, string) = try string %> parser
        switch r1 {
        case .first(let r1):
            return try string %> transform(r1)
        case .second(let r1):
            return (r1, string)
        }
    }
}
extension Parser {
    func flatMapFirst<P: Parser, First>(_ transform: @escaping (First) -> P) -> FlatMapFirstReduceParser<Self, First, P> where Result == Either<First, P.Result> {
        FlatMapFirstReduceParser(parser: self, transform: transform)
    }
}

struct FlatMapSecondReduceParser<P1: Parser, Second, P2: Parser>: Parser where P1.Result == Either<P2.Result, Second> {
    let parser: P1
    let transform: (Second) throws -> P2
    
    func parse(from string: Substring) throws -> (P2.Result, remainder: Substring) {
        let (r1, string) = try string %> parser
        switch r1 {
        case .first(let r1):
            return (r1, string)
        case .second(let r1):
            return try string %> transform(r1)
        }
    }
}
extension Parser {
    func flatMapSecond<P: Parser, Second>(_ transform: @escaping (Second) -> P) -> FlatMapSecondReduceParser<Self, Second, P> where Result == Either<P.Result, Second> {
        FlatMapSecondReduceParser(parser: self, transform: transform)
    }
}
