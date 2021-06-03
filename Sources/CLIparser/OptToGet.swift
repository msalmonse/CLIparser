//
//  OptToGet.swift
//  
//
//  Created by Michael Salmon on 2021-05-18.
//

import Foundation

/// Description of the option to get
public class OptToGet: Comparable, Hashable, Encodable {
    internal enum CodingKeys: CodingKey {
        case short, long, minmax, options, tag, usage, argTag
    }

    let short: String?
    let long: String?
    let aka: [String]?
    let minCount: UInt8
    let maxCount: UInt8
    let options: OptToGet.Options
    let tag: CLIparserTag?
    let usage: String?
    let argTag: String?

    // test if arguments expected
    var hasArgs: Bool { minCount > 0 || maxCount > 0}

    /// Initialize an OptToGet object
    /// - Parameters:
    ///   - short: single character name for the option
    ///   - long: long name for the option
    ///   - aka: also known as, a list of aliases
    ///   - minMax: range of the number of arguments to collect
    ///   - options: option behaviours
    ///   - tag: opaque object
    ///   - usage: help text
    ///   - argTag: how to tag the arguments for this tag e.g. for --file: <file name>...

    public init(
        short: String? = nil,
        long: String? = nil,
        aka: [String]? = nil,
        _ minMax: ClosedRange<UInt8> = 0...0,
        options: [OptToGet.Options] = [],
        tag: CLIparserTag? = nil,
        usage: String? = nil,
        argTag: String? = nil
    ) {
        self.short = short
        self.long = long
        self.aka = aka
        self.minCount = minMax.lowerBound
        self.maxCount = minMax.upperBound
        self.options = OptToGet.Options(options)
        self.tag = tag
        self.usage = usage
        self.argTag = argTag
    }

    func match(long name: String) -> Bool {
        if name == long { return true }
        if let aka = aka {
            for long in aka {
                if name == long { return true }
            }
        }

        return false
    }

    /// Encode an OptToGet instance
    /// - Parameter encoder: encoder
    /// - Throws: `EncodingError.invalidValue`

    public func encode(to encoder: Encoder) throws {
        let softBreak = String(Usage.softBreak)
        var container = encoder.container(keyedBy: Self.CodingKeys.self)
        if let short = short { try container.encode(short, forKey: .short) }
        if let long = long { try container.encode(long, forKey: .long) }
        if maxCount > 0 {
            let minmax = String(format: "%d...%d", minCount, maxCount)
            try container.encode(minmax, forKey: .minmax)
        }
        if options.rawValue != 0 { try container.encode(options.description, forKey: .options) }
        if let usage = usage {
            try container.encode(usage.replacingOccurrences(of: softBreak, with: " "), forKey: .usage)
        }
        if let argTag = argTag { try container.encode(argTag, forKey: .argTag) }
    }

    /// Generate hash value
    /// - Parameter hasher: the hash generator

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    /// Test for equality
    /// - Parameters:
    ///   - lhs: left OptToGet
    ///   - rhs: right OptToGet
    /// - Returns: true if names match

    public static func == (lhs: OptToGet, rhs: OptToGet) -> Bool {
        return lhs.short == rhs.short && lhs.long == rhs.long
    }

    /// Compare OptToGet names
    /// - Parameters:
    ///   - lhs: left OptToGet
    ///   - rhs: right OptToGet
    /// - Returns: true if left < right

    public static func < (lhs: OptToGet, rhs: OptToGet) -> Bool {
        if let left = lhs.short, let right = rhs.short { return left < right }
        if let left = lhs.long, let right = rhs.long { return left < right }
        if let left = lhs.short, let right = rhs.long { return left < right }
        if let left = lhs.long, let right = rhs.short { return left < right }

        return false
    }
}

public typealias OptsToGet = [OptToGet]
