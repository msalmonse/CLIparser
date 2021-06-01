//
//  OptParseShort.swift
//  
//
//  Created by Michael Salmon on 2021-05-12.
//

import Foundation

extension ArgumentList {

    /// Handle short options
    /// - Parameters:
    ///   - state: the state of parsing
    /// - Throws:
    ///   - CLIparserError.duplicateArgument
    ///   - CLIparserError.insufficientArguments
    ///   - CLIparserError.tooManyArguments
    ///   - CLIparserError.unknownName

    func shortOptions(_ state: ParseState) throws {
        let shortIndex = index           // check that we are in the same place
        let arg = args[index]
        var charIndex = arg.index(after: arg.startIndex)
        do {
            while charIndex < arg.endIndex {
                let name = String(arg[charIndex])
                charIndex = arg.index(after: charIndex)
                try shortOption(name: name, &charIndex, state)
                // if we aren't handling the same arg we need to check for short or long opts
                if index != shortIndex { break }
            }
            if index == shortIndex { index += 1 }
        } catch {
            throw error
        }
    }

    /// Handle a short option
    /// - Parameters:
    ///   - name: the name of the option
    ///   - charIndex: index into arg[i]
    ///   - state: the state of parsing
    /// - Throws:
    ///   - CLIparserError.duplicateArgument
    ///   - CLIparserError.insufficientArguments
    ///   - CLIparserError.tooManyArguments
    ///   - CLIparserError.unknownName

    func shortOption(name: String, _ charIndex: inout String.Index, _ state: ParseState) throws {
        guard let optMatch = state.shortToGet[name] else {
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
        match.count += 1

        if opt.hasArgs {
            if charIndex < args[index].endIndex && args[index][charIndex] == "=" {
                charIndex = args[index].index(after: charIndex)
            }
            // Take the rest of the argument
            if charIndex < args[index].endIndex {
                match.optValuesAt.append(OptValueAt(value: String(args[index][charIndex...]), atIndex: index))
                charIndex = args[index].endIndex
            }
            index += 1

            do {
                try argsCopy(optMatch)
            } catch {
                throw(error)
            }
        }
    }
}
