//
//  CmdParse.swift
//  
//
//  Created by Michael Salmon on 2021-05-15.
//

import Foundation

/// A command and sub command to match against the command line arguments

public class CmdToGet {
    public let cmdAndSub: [String]
    public let tag: CLIparserTag?
    public let usage: String?

    public init(_ cmdAndSub: [String], tag: CLIparserTag? = nil, usage: String? = nil) {
        self.cmdAndSub = cmdAndSub
        self.tag = tag
        self.usage = usage
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
