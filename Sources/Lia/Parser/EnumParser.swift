//
//  EnumParser.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

struct EnumParser<E>: Parser where E: CaseIterable, E: RawRepresentable, E.RawValue == String {
    func parse(from string: Substring) throws -> (E, remainder: Substring) {
        try string %> Parsers.oneOf(E.allCases.map({ e in (%e.rawValue).map({ e }) }))
    }
}
extension RawRepresentable where Self: Parsable, Self: CaseIterable, RawValue == String {
    static var parser: EnumParser<Self> {
        EnumParser()
    }
}
