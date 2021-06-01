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

    /// Holder for CLI arguments
    /// - Parameters:
    ///   - args: argument list
    ///   - startIndex: argument to start at

    init(_ args: [String], startIndex: Int) {
        self.args = args
        index = startIndex
    }
}
