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

    /// Init for ParseState
    /// - Parameters:
    ///   - toGet: options to get
    ///   - canAbbrev: can options be abbreviated
    /// - Throws: CLIparserError.duplicateName

    init(_ toGet: OptsToGet, _ canAbbrev: Bool) throws {
        var longToGet: [String: OptMatch] = [:]
        var shortToGet: [String: OptMatch] = [:]
        var required: Set<OptToGet> = []
        var prevAbbrev: Set<String> = []

        /// Add a name with abbreviations to longToGet
        /// - Parameters:
        ///   - long: name of option
        ///   - optMatch: the instace to add to longToGet
        /// - Throws: CLIparserError.duplicateName

        func addToLong(_ long: String, _ optMatch: OptMatch) throws {
            if longToGet[long] != nil {
                // Was the previous entry an abbreviation
                if !prevAbbrev.contains(long) { throw CLIparserError.duplicateName(name: long) }
            }
            longToGet[long] = optMatch
            if canAbbrev && long.count >= 4 && optMatch.opt.options.canAbbrev {
                let start = long.startIndex
                for offset in 2..<(long.count - 1) {
                    let end = long.index(start, offsetBy: offset)
                    let abbrev = String(long[start...end])
                    if prevAbbrev.contains(abbrev) {
                        // check if the previous entry was an abbreviation
                        if !(longToGet[abbrev]?.match(long: abbrev) ?? false) {
                            longToGet[abbrev] = nil
                        }
                    } else {
                        longToGet[abbrev] = optMatch
                        prevAbbrev.insert(abbrev)
                    }
                }
            }
        }

        for opt in toGet {
            if opt.long == nil && opt.short == nil { throw CLIparserError.missingName }
            if opt.options.isRequired { required.insert(opt) }
            let optMatch = OptMatch(opt)
            if let short = opt.short {
                if shortToGet[short] != nil { throw CLIparserError.duplicateName(name: short) }
                shortToGet[short] = optMatch
            }
            if let long = opt.long {
                do {
                    try addToLong(long, optMatch)
                    if let aka = opt.aka {
                        for name in aka {
                            try addToLong(name, optMatch)
                        }
                    }
                } catch {
                    throw error
                }
            }
        }
        self.longToGet = longToGet
        self.shortToGet = shortToGet
        self.required = required
    }
}

#if DEBUG
extension ArgumentList {
    /// List the abbreviations
    /// - Parameter opts: options
    /// - Returns: all the abbreviations
    static public func abbreviations(_ opts: OptsToGet) -> String {
        var result: [String] = []
        if let state = try? ParseState(opts, true) {
            for key in state.longToGet.keys.sorted() {
                if let long = state.longToGet[key]?.opt.long, long != key {
                    result.append("\(key): \(long)")
                }
            }
        }
        return result.joined(separator: "\n")
    }
}
#endif
