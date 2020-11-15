//
//  Renderer.swift
//  Lia
//
//  Created by Davis Deaton on 11/15/20.
//

import Foundation

let escapeRegex = try! NSRegularExpression(pattern: ##"("#*)|(#*")|(\\#*)"##)
func escapes(for string: String) -> Int {
    let matches = escapeRegex.matches(in: string, range: NSRange(location: 0, length: string.count))
    return matches.reduce(0, { max($0, $1.range.length) })
}

extension Template {
    func compile() -> String {
        let name = Identifier(from: header[.name] ?? "unknown_template_name")
    
        var output: String = ""
        
        output += """
func render_\(name)() -> String {
    var output: String = ""

"""
        for bodyElement in body {
            switch bodyElement {
            case .literal(let value):
                let escape = String(repeating: "#", count: escapes(for: value))
                output += #"""
    output += \#(escape)"""
\#(value)
"""\#(escape)

"""#
            case .value(let value):
                output += """
    output += String(describing: \(value))

"""
            case .code(let value):
                output += value
                output += "\n"
            case .comment:
                continue
            }
        }
        
        output += """
    return output
}
"""
        return output
    }
}
