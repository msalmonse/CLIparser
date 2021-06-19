//
//  Encoder.swift
//  
//
//  Created by Michael Salmon on 2021-06-19.
//

import Foundation

extension OptToGet: Encodable {
    internal enum CodingKeys: CodingKey {
        case short, long, minmax, options, tag, usage, argTag
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
}

extension CmdToGet: Encodable {
    internal enum CodingKeys: CodingKey {
        case cmdAndSub, usage
    }

    /// Encode a CmdToGet instance
    /// - Parameter encoder: encoder
    /// - Throws: `EncodingError.invalidValue`

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cmdAndSub, forKey: .cmdAndSub)
        if let usage = usage { try container.encode(usage, forKey: .usage) }
    }
}
