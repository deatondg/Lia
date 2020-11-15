//
//  main.swift
//  Lia
//
//  Created by Davis Deaton on 11/15/20.
//

Lia.main(["generate", "--help"])

exit(0)

let include = """
import Foundation
"""

let file = """
Hello! It it currently {{ Date() }}.
"""

let (template, remainder) = try Template.parse(from: file)
guard remainder.isEmpty else {
    fatalError()
}

let compiled = template.compile()

let main = """
print(render_\(Identifier(from: template.header[.name] ?? "unknown_template_name"))())
"""

let source = include + "\n" + compiled + "\n" + main

let tmp = Path.temporary
try tmp.chdir {
    try Path("main.swift").write(source)
    
    let swiftc = Process()
    swiftc.launchPath = "/usr/bin/swiftc"
    swiftc.arguments = ["main.swift"]
    swiftc.launch()
    swiftc.waitUntilExit()
    
    let renderer = Process()
    let pipe = Pipe()
    renderer.launchPath = "./main"
    renderer.standardOutput = pipe
    renderer.launch()
    renderer.waitUntilExit()
    
    let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!
    
    print(output)
}
