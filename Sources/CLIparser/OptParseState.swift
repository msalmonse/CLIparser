//
//  File.swift
//  
//
//  Created by Michael Salmon on 2021-06-01.
//

import Foundation

internal class ParseState {
    internal let longToGet: [String: OptMatch]
    internal var matched: OptsGot = []
    internal var required: Set<OptToGet>
    internal let shortToGet: [String: OptMatch]

    init(_ toGet: OptsToGet) throws {
        var longToGet: [String: OptMatch] = [:]
        var shortToGet: [String: OptMatch] = [:]
        var required: Set<OptToGet> = []
        for opt in toGet {
            if opt.long == nil && opt.short == nil { throw CLIparserError.missingName }
            if opt.options.isRequired { required.insert(opt) }
            let optMatch = OptMatch(opt)
            if let short = opt.short {
                if shortToGet[short] != nil { throw CLIparserError.duplicateName(name: short) }
                shortToGet[short] = optMatch
            }
            if let long = opt.long {
                if longToGet[long] != nil { throw CLIparserError.duplicateName(name: long) }
                longToGet[long] = optMatch
            }
        }
        self.longToGet = longToGet
        self.shortToGet = shortToGet
        self.required = required
    }
}
