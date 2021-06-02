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

    init(_ toGet: OptsToGet, _ canAbbrev: Bool) throws {
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
                if let optMatchLong = longToGet[long] {
                    if optMatchLong.long == long { throw CLIparserError.duplicateName(name: long) }
                    // Must be an abbreviation then
                    longToGet[long] = nil
                }
                longToGet[long] = optMatch
                if canAbbrev && long.count >= 4 && opt.options.canAbbrev {
                    let start = long.startIndex
                    for offset in 2..<(long.count - 1) {
                        let end = long.index(start, offsetBy: offset)
                        let abbrev = String(long[start...end])
                        if let optMatchAbbr = longToGet[abbrev] {
                            // If the existing entry is an abbreviation remove it
                            if optMatchAbbr.long != abbrev { longToGet[abbrev] = nil }
                        } else {
                            longToGet[abbrev] = optMatch
                        }
                    }
                }
            }
        }
        self.longToGet = longToGet
        self.shortToGet = shortToGet
        self.required = required
    }
}
