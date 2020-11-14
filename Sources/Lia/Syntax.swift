//
//  Syntax.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation

enum Syntax {
    static var beginHeader = "{#"
    static var endHeader = "#}"
    static var fieldSeparator = ":"
    
    case value
    case code
    case comment
    
    var beginKey: String {
        switch self {
        case .value:
            return "{"
        case .code:
            return "%"
        case .comment:
            return "#"
        }
    }
    var closeKey: String {
        switch self {
        case .value:
            return "}"
        case .code:
            return "%"
        case .comment:
            return "#"
        }
    }
}
