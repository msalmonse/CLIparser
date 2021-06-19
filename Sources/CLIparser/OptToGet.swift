//
//  OptToGet.swift
//  
//
//  Created by Michael Salmon on 2021-05-18.
//

import Foundation

/// Description of the option to get
public class OptToGet: Comparable, Hashable {
    public let short: String?
    public let long: String?
    public let aka: [String]?
    public let minCount: UInt8
    public let maxCount: UInt8
    public let options: OptToGet.Options
    public let tag: CLIparserTag?
    public let usage: String?
    public let argTag: String?

    // test if arguments expected
    public var hasArgs: Bool { minCount > 0 || maxCount > 0 }

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
        options: [OptToGet.Options],
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

    /// The same as init but with a single option
    
    public convenience init (
        short: String? = nil,
        long: String? = nil,
        aka: [String]? = nil,
        _ minMax: ClosedRange<UInt8> = 0...0,
        option: OptToGet.Options,
        tag: CLIparserTag? = nil,
        usage: String? = nil,
        argTag: String? = nil
    ) {
        self.init(short: short, long: long, aka: aka,
                  minMax, options: [option], tag: tag,
                  usage: usage, argTag: argTag
        )
    }

    /// The same as init but with no option

    public convenience init (
        short: String? = nil,
        long: String? = nil,
        aka: [String]? = nil,
        _ minMax: ClosedRange<UInt8> = 0...0,
        tag: CLIparserTag? = nil,
        usage: String? = nil,
        argTag: String? = nil
    ) {
        self.init(short: short, long: long, aka: aka,
                  minMax, options: [], tag: tag,
                  usage: usage, argTag: argTag
        )
    }

    func match(long name: String) -> Bool {
        if name == long { return true }
        if let aka = aka {
            for long in aka where name == long { return true }
        }

        return false
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
