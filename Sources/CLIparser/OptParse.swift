//
//  OptParse.swift
//  
//
//  Created by Michael Salmon on 2021-05-12.
//

import Foundation

extension ArgumentList {

    /// Parse the commandline arguments
    /// - Parameters
    ///   - toGet: the options to look for
    ///   - positionalTag: tag to use for arguments not assigned to options
    /// - Throws:
    ///   - CLIparserError.duplicateArgument
    ///   - CLIparserError.insufficientArguments
    ///   - CLIparserError.missingOptions
    ///   - CLIparserError.tooManyArguments
    ///   - CLIparserError.unknownName
    /// - Returns: a list of options found

    public func optionsParse(_ toGet: OptsToGet, _ positionalTag: CLIparserTag? = nil) throws -> OptsGot {
        let state = try ParseState(toGet, options.canAbbreviate)
        let minusTest: MinusTest = options.onlyLong ? .longOnly : .normal
        argsLoop: while args.indices.contains(index) {
            switch MinusCount(args[index], type: minusTest) {
            case .end:
                index += 1
                break argsLoop
            case .long2:
                try longOption(2, state)
            case .long1:
                try longOption(1, state)
            case .short:    // only -
                try shortOptions(state)
            case .none:
                break argsLoop
            }
        }

        for optGot in state.matched {
            let minCount = Int(optGot.opt.minCount)
            let maxCount = Int(optGot.opt.maxCount)
            switch optGot.optValuesAt.count {
            case 0..<minCount:
                throw CLIparserError.insufficientArguments(name: optGot.name)
            case minCount...maxCount:
                break
            default:
                throw CLIparserError.tooManyArguments(name: optGot.name)
            }
        }

        // check for missing required options
        if !state.required.isEmpty {
            var missing: [String] = []
            for opt in state.required {
                missing.append(opt.long ?? opt.short ?? "???")
            }
            throw CLIparserError.missingOptions(names: missing.joined(separator: ", "))
        }

        // Copy remaining arguments
        if index < args.count {
            let opt = OptToGet(1...255, options: [.includeMinus, .includeMinusMinus], tag: positionalTag)
            let match = OptGot(opt: opt)
            let optMatch = OptMatch(opt)
            optMatch.matched = match
            state.matched.append(match)
            try argsCopy(optMatch)
        }

        return state.matched
    }

    enum MinusTest { case normal, longOnly, endOrNone }
    enum MinusCount {
        case none, short, long1, long2, end

        /// Count the number of minuses
        /// - Parameters:
        ///   - arg: string to count
        ///   - test: type of test

        init(_ arg: String, type test: MinusTest) {
            // -- signals the end of arguments
            if arg == "--" {
                self = .end
            // a prefix of -- is always long and also counts as an end
            } else if arg.hasPrefix("--") {
                self = .long2
            // use endOrNone when arguments can start with -
            } else if test == .endOrNone {
                self = .none
            // a single - can be long or short depending on longOnly
            } else if arg.hasPrefix("-") {
                self = (test == .longOnly) ? .long1 : .short
            // no minuses
            } else {
                self = .none
            }
        }
    }
}
