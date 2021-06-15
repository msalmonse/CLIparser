//
//  OptToGetOptions.swift
//  
//
//  Created by Michael Salmon on 2021-05-12.
//

import Foundation

extension OptToGet {

    /// options when parsing arguments

    public struct Options: OptionSet {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// option is a flag and has no options
        public static let flag = Options(rawValue: 1 << 0)
        public var isFlag: Bool { contains(.flag) }

        /// option should not be seen in usage
        public static let hidden = Options(rawValue: 1 << 1)
        public var isHidden: Bool { contains(.hidden) }

        /// arguments that start with - are included
        public static let includeMinus = Options(rawValue: 1 << 2)
        public var minusIncluded: Bool { contains(Self.includeMinus) }

        /// -- is also included
        public static let includeMinusMinus = Options(rawValue: 1 << 3)
        public var minusMinusIncluded: Bool { contains(Self.includeMinusMinus) }

        /// option can appear multiple times
        public static let multi = Options(rawValue: 1 << 4)
        public var isMulti: Bool { contains(Self.multi) }

        // option is required
        public static let required = Options(rawValue: 1 << 5)
        public var isRequired: Bool { contains(Self.required) }

        // option cannot be abbreviated
        public static let unabbrev = Options(rawValue: 1 << 6)
        public var canAbbrev: Bool { !contains(Self.unabbrev) }

        private static let allNames: [(Options, String)] = [
            (.flag, ".flag"),
            (.hidden, ".hidden"),
            (.includeMinus, ".includeMinus"),
            (.includeMinusMinus, ".includeMinusMinus"),
            (.multi, ".multi"),
            (.required, ".required"),
            (.unabbrev, ".unabbrev")
        ]

        public var description: String {
            var result: [String] = []
            for (value, name) in Self.allNames {
                if contains(value) { result.append(name) }
            }
            return "[" + result.sorted().joined(separator: ", ") + "]"
        }
    }
}
