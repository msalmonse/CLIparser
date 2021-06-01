//
//  OptParseCommon.swift
//  
//
//  Created by Michael Salmon on 2021-05-12.
//

import Foundation

extension ArgumentList {

    /// Copy args to opt
    /// - Parameters:
    ///   - opt: option matched
    ///   - args: command line arguments
    ///   - i: index into args
    /// - Throws:
    ///   - CLIparserError.insufficientArguments

    internal func argsCopy(_ optMatch: OptMatch) throws {
        let opt = optMatch.opt
        let match = optMatch.matched!
        let minusTest: MinusTest = opt.options.minusIncluded ? .endOrNone : .normal

        /// Tests argIndex for validity
        /// - Returns: true if it is OK
        func argIndexIsOK() -> Bool {
            if !args.indices.contains(index) {
                return false
            } else {
                if opt.options.minusMinusIncluded { return true }
                switch MinusCount(args[index], type: minusTest) {
                case .end:
                    // this terminates our option so step over it
                    index += 1
                    return false
                case .none: return true
                default: return false
                }
            }
        }

        while match.optValuesAt.count < opt.maxCount && argIndexIsOK() {
            match.optValuesAt.append(OptValueAt(value: args[index], atIndex: index))
            index += 1
        }
    }
}
