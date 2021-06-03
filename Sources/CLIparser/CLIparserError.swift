//
//  CLIparserError.swift
//  
//
//  Created by Michael Salmon on 2021-05-12.
//

import Foundation

public enum CLIparserError: Error, CustomStringConvertible {
    public var description: String { self.errorDescription ?? "???" }

    case duplicateName(name: String)
    case duplicateOption(name: String, index: Int)
    case illegalValue(type: String, valueAt: OptValueAt)
    case insufficientArguments(name: String)
    case missingOptions(names: String)
    case missingName
    case tooManyArguments(name: String)
    case unknownError(index: Int)
    case unknownName(name: String, index: Int)
}

extension CLIparserError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .duplicateName(name):
            return "Option \"\(name)\" defined previously"
        case let .duplicateOption(name, index):
            return "Option \"\(name)\" is on the command line multiple times, last at argument \(index)"
        case let .illegalValue(type, valueAt):
            return "Not a valid \(type) at argument \(valueAt.atIndex): \"\(valueAt.value)\""
        case let .insufficientArguments(name):
            return "Not enough arguments to satisfy minimum requirements for \"\(name)\""
        case let .missingOptions(names):
            return "Missing options: \(names)"
        case .missingName:
            return "Option declared without a long or short name"
        case let .tooManyArguments(name):
            return "The number of arguments for \"\(name)\" exceeds the maximum defined"
        case let .unknownError(index):
            return "An unknown error occured at argument: \(index)"
        case let .unknownName(name, index):
            return "There is no option defined for \"\(name)\" at argument \(index)"
        }
    }
}
