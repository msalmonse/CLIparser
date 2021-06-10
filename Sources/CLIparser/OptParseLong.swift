//
//  OptParseLong.swift
//  
//
//  Created by Michael Salmon on 2021-05-12.
//

import Foundation

extension ArgumentList {

    /// Check for a `no` prefix
    /// - Parameter name: name to check
    /// - Returns: true if prefix found

    private func noCheck(_ name: inout String) -> Bool {
        if name.hasPrefix("no-") {
            name = String(name.dropFirst(3))
            return true
        }
        if name.hasPrefix("no") {
            name = String(name.dropFirst(2))
            return true
        }
        return false
    }

    /// Lookup name and throw if it doesn't exist
    /// - Parameters:
    ///   - name: name to lookup
    ///   - state: the state of parsing
    /// - Throws: CLIparserError.unknownName
    /// - Returns: match found

    private func lookup(_ name: String, _ state: ParseState) throws -> OptMatch {
        if let match = state.longToGet[name] { return match }
        throw CLIparserError.unknownName(name: name, index: index)
    }

    /// Handle a long argument
    /// - Parameters:
    ///   - minuses: the number of minus prefixes
    ///   - state: the state of parsing
    /// - Throws:
    ///   - CLIparserError.duplicateArgument
    ///   - CLIparserError.insufficientArguments
    ///   - CLIparserError.tooManyArguments
    ///   - CLIparserError.unknownName

    func longOption(_ minuses: Int, _ state: ParseState) throws {
        var optMatch: OptMatch
        var arg1: String?
        var name: String = String(args[index].dropFirst(minuses))
        var invert = false

        if state.longToGet[name] != nil {
            optMatch = state.longToGet[name]!
        } else if noCheck(&name) {
            invert = true
            optMatch = try lookup(name, state)
            // no prefix only applies to flags
            if !optMatch.opt.options.isFlag {
                name = String(args[index].dropFirst(minuses))
                throw CLIparserError.unknownName(name: name, index: index)
            }
        } else if let equalsIndex = name.firstIndex(of: "=") {
            // the arg may be --name=val
            arg1 = String(name[name.index(after: equalsIndex)...])
            name = String(name[name.startIndex...name.index(before: equalsIndex)])
            optMatch = try lookup(name, state)
        } else {
            throw CLIparserError.unknownName(name: name, index: index)
        }

        var match: OptGot
        let opt = optMatch.opt
        if optMatch.matched == nil {
            match = OptGot(opt: opt)
            optMatch.matched = match
            state.matched.append(match)
            state.required.remove(opt)
        } else if opt.options.isMulti {
            match = optMatch.matched!
        } else {
            throw CLIparserError.duplicateOption(name: name, index: index)
        }

        if opt.options.isFlag {
            match.count = invert ? 0 : 1
        } else {
            match.count += 1
        }

        index += 1
        if opt.hasArgs {
            if arg1 != nil { match.optValuesAt.append(OptValueAt(value: arg1!, atIndex: index)) }
            try argsCopy(optMatch)
        }
    }
}
