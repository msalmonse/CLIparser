//
//  ArgumentList.swift
//  
//
//  Created by Michael Salmon on 2021-06-01.
//

import Foundation

public class ArgumentList {
    internal var args: [String]
    internal var index: Int
    internal let options: CLIparserOptions

    /// Holder for CLI arguments
    /// - Parameters:
    ///   - args: argument list, default: argv
    ///   - startIndex: argument to start at, default: 1
    ///   - options: parser options, default: none

    public init(_ args: [String] = CommandLine.arguments, startIndex: Int = 1, options: CLIparserOptions = []) {
        self.args = args
        index = startIndex
        self.options = options
    }
}
