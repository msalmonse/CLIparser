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
    let count: Int
    public let tag: CLIparserTag?
    let usage: String?

    public init(_ cmdAndSub: [String], tag: CLIparserTag? = nil, usage: String? = nil) {
        self.cmdAndSub = cmdAndSub
        count = cmdAndSub.count
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

    /// Compare arguments with commnds
    /// - Parameters:
    ///   - cmds: a list of possible commands
    ///   - args: the command line arguments
    /// - Returns: the matching command or nil

    public func commandParser(_ cmds: CmdsToGet) -> CmdToGet? {
        let droppedArgs = Array(args.dropFirst(index))
        for cmd in cmds where cmd.cmdAndSub.count <= droppedArgs.count {
            if cmd.count == 0 || Array(droppedArgs.prefix(cmd.count)) == cmd.cmdAndSub {
                index += cmd.count
                return cmd
            }
        }
        return nil
    }
}
