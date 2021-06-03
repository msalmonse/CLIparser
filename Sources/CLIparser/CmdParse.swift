//
//  CmdParse.swift
//  
//
//  Created by Michael Salmon on 2021-05-15.
//

import Foundation

/// A command and sub command to match against the command line arguments

public class CmdToGet: Encodable {
    internal enum CodingKeys: CodingKey {
        case cmdAndSub, usage
    }

    let cmdAndSub: [String]
    public let tag: CLIparserTag?
    let usage: String?

    public init(_ cmdAndSub: [String], tag: CLIparserTag? = nil, usage: String? = nil) {
        self.cmdAndSub = cmdAndSub
        self.tag = tag
        self.usage = usage
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

public typealias CmdsToGet = [CmdToGet]

extension ArgumentList {

    /// Compare cmd.cmdAndSub with args
    /// - Parameter cmd: CmdToGet to compare
    /// - Returns: true if they match, empty strings are wildcards

    func cmdCompare(_ cmd: CmdToGet) -> Bool {
        if cmd.cmdAndSub.count + index > args.count { return false }
        let cmdList = cmd.cmdAndSub
        var offset = index
        for word in cmdList {
            if word != args[offset] && !word.isEmpty { return false }
            offset += 1
        }
        return true
    }

    /// Compare arguments with commnds
    /// - Parameters:
    ///   - cmds: a list of possible commands
    ///   - args: the command line arguments
    /// - Returns: the matching command or nil

    public func commandParser(_ cmds: CmdsToGet) -> CmdToGet? {
        for cmd in cmds {
            if cmd.cmdAndSub.isEmpty || cmdCompare(cmd) {
                index += cmd.cmdAndSub.count
                return cmd
            }
        }
        return nil
    }
}
