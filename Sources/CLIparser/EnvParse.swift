//
//  EnvParse.swift
//  
//
//  Created by Michael Salmon on 2021-06-22.
//

import Foundation

/// Parse options from environment
/// - Parameters:
///   - toGet: options to get
///   - environment: process environment
/// - Returns: a list of options found

public func environmentParse(
    _ toGet: OptsToGet,
    _ environment: [String: String] = ProcessInfo.processInfo.environment
) -> OptsGot {
    var matched: OptsGot = []

    for opt in toGet {
        if let key = opt.env {
            if let val = environment[key] {
                let valueAt = OptValueAt(value: val, atIndex: 0, atEnv: key)
                let optGot = OptGot(opt: opt, value: valueAt)
                matched.append(optGot)
            }
        }
    }
    return matched
}
