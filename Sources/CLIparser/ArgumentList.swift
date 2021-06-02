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
    ///   - args: argument list
    ///   - startIndex: argument to start at
    ///   - options: parser options

    public init(_ args: [String], startIndex: Int = 1, options: CLIparserOptions = []) {
        self.args = args
        index = startIndex
        self.options = options
    }
}
