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

    public func parseArgs(_ toGet: OptsToGet, _ positionalTag: CLIparserTag? = nil) throws -> OptsGot {
        let state = try ParseState(toGet)
        let minusTest: MinusTest = longOnly ? .longOnly : .normal
        argsLoop: while args.indices.contains(index) {
            do {
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
            } catch {
                throw error
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
            if arg == "--" {
                self = .end
            } else if test == .endOrNone {
                self = .none
            } else if arg.hasPrefix("--") {
                self = .long2
            } else if arg.hasPrefix("-") {
                self = (test == .longOnly) ? .long1 : .short
            } else {
                self = .none
            }
        }
    }
}
