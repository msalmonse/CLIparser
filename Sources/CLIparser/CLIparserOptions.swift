//
//  CLIparserOptions.swift
//  
//
//  Created by Michael Salmon on 2021-06-02.
//

import Foundation

public struct CLIparserOptions: OptionSet {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    // Put the long name first in usage
    public static let longFirst = CLIparserOptions(rawValue: 1 << 0)
    var putLongFirst: Bool { contains(.longFirst) }

    // There are only long options
    public static let longOnly = CLIparserOptions(rawValue: 1 << 1)
    var onlyLong: Bool { contains(.longOnly) }

    // Don't add abbreviations
    public static let noAbbreviations = CLIparserOptions(rawValue: 1 << 2)
    var canAbbreviate: Bool { !contains(.noAbbreviations) }

    private static let allNames: [(CLIparserOptions, String)] = [
        (.longFirst, ".longFirst"),
        (.longOnly, ".longOnly"),
        (.noAbbreviations, ".noAbbreviations")
    ]

    public var description: String {
        var result: [String] = []
        for (value, name) in Self.allNames {
            if contains(value) { result.append(name) }
        }
        return "[" + result.sorted().joined(separator: ", ") + "]"
    }

}
