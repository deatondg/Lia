//
//  Path+Extensions.swift
//  Lia
//
//  Created by Davis Deaton on 11/15/20.
//

import Foundation
import PathKit
import ArgumentParser

extension Path: ExpressibleByArgument {
    public init(argument: String) {
        self.init(argument)
    }
}
