//
//  Parsers.swift
//  Lia
//
//  Created by Davis Deaton on 11/14/20.
//

import Foundation

enum Parsers {
    static var whitespace: UntilPredicateParser {
        Parsers.until({ !$0.isWhitespace })
    }
    static var line: UntilSubstringParser {
        Parsers.until(substring: "\n")
    }
    static var emptyLine: BothIgnoreSecondParser<UntilPredicateParser, IgnoreParser<Character.Parser>> {
        Parsers.until({
            guard $0.isWhitespace else {
                throw ParserError.parserNeverMatched
            }
            return $0 == "\n"
        }) %& Character.parser.ignore()
    }
}
