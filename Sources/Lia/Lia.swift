//
//  main.swift
//  Lia
//
//  Created by Davis Deaton on 11/13/20.
//

import Foundation
import ArgumentParser
import PathKit

struct Lia: ParsableCommand {
    static let version = "0.0.1"
    static var configuration = CommandConfiguration(
        //commandName: <#T##String?#>,
        abstract: "The Lia templating language compiler",
        //discussion: <#T##String#>,
        version: version,
        //shouldDisplay: <#T##Bool#>,
        subcommands: [Generate.self]
        //defaultSubcommand: <#T##ParsableCommand.Type?#>,
        //helpNames: <#T##NameSpecification#>
    )
    
    struct Options: ParsableArguments {
        @Option(name: [.customShort("t"), .customLong("template")])
        var templates: [Path]
        
        @Option(name: [.customShort("i"), .customLong("include")])
        var includes: [Path]
        
        @Option(name: [.customShort("o"), .customLong("output")])
        var output: Path
    }
    
    enum Error: Swift.Error {
        case pathDoesNotExist(Path)
        case other
    }
    
    struct Generate: ParsableCommand {
        
        @OptionGroup
        var options: Lia.Options
        
        var templates: [Path] { options.templates }
        var includes: [Path] { options.includes }
        var output: Path { options.output }
        
        func validate() throws {
            for path in templates + includes + [output.parent()]{
                guard path.exists else {
                    throw Error.pathDoesNotExist(path)
                }
            }
            guard !output.isDirectory else {
                throw Error.other
            }
        }
        
        func run() throws {
            
        }
    }
}

