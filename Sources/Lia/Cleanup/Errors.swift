//
//  Errors.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

enum ParserError: Error {
    case patternNotFound
    case parserNeverMatched
    case unknownHeaderField
    case unknownCase
    case noMatch([Error])
    case noMatch(Error, Error)
    case badSyntax
    case incompleteHeader
    case repeatedHeaderField
    case headerEndRequiresNewLine
    case never
}
