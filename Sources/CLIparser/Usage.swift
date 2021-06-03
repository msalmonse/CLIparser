//
//  Usage.swift
//  
//
//  Created by Michael Salmon on 2021-05-13.
//

import Foundation

public struct Usage {

    let textLeft: Int
    let textRight: Int
    let gap: Int
    let spaces: String
    let indent: String

    public init(
        tagLeft: Int = 2,
        textLeft: Int = 25,
        textRight: Int = 75,
        gap: Int = 2
    ) {
        indent = String(repeating: " ", count: tagLeft)
        spaces = String(repeating: " ", count: textLeft)
        self.textLeft = textLeft
        self.textRight = textRight
        self.gap = gap
    }

    /// Indicate a potential line break
    public static let softBreak: Character = "\u{11}"

    private func wrapOnce(_ one: inout String, _ result: inout [String]) {
        let brk = Self.softBreak
        let width = textRight - textLeft

        /// Divide one into 2 parts
        /// - Parameter count: where to divide one

        func divideOne(_ count: Int) {
            let start = one.startIndex
            let end = one.index(one.startIndex, offsetBy: count)
            let leftPart = one[start..<end]
            one.replaceSubrange(start...end, with: spaces)
            result.append(String(leftPart).replacingOccurrences(of: String(brk), with: " "))
        }

        /// Search for a character in a string, either from the left or the right
        /// - Parameters:
        ///   - srch: search character
        ///   - string: string to search for
        ///   - fromLeft: from the left or right
        /// - Returns: offset to the character or really big offset if not found

        func search(for srch: Character, in string: Substring, fromLeft: Bool = false) -> Int {
            if let found = fromLeft ? string.firstIndex(of: srch) : string.lastIndex(of: srch) {
                return string.distance(from: string.startIndex, to: found)
            }
            return fromLeft ? Int.max : Int.min
        }

        var brkPos: Int
        var spcPos: Int
        let start = one.index(one.startIndex, offsetBy: textLeft)
        let end = one.index(one.startIndex, offsetBy: textRight)
        let oneLeft = one[start...end]
        let oneRight = one[end...]
        // First search from the left
        brkPos = search(for: brk, in: oneLeft)
        spcPos = search(for: " ", in: oneLeft)
        if brkPos >= 0 || spcPos >= 0 {
            if brkPos < 0 {
                // use space if no break
                divideOne(spcPos + textLeft)
            } else if spcPos < 0 {
                // use break if no space
                divideOne(brkPos + textLeft)
            } else {
                // choose the closest to the end but if break is pretty close choose it
                if (spcPos - brkPos) * 10 < width {
                    divideOne(brkPos + textLeft)
                } else {
                    divideOne(spcPos + textLeft)
                }
            }
        } else {
            // check to right
            brkPos = search(for: brk, in: oneRight, fromLeft: true)
            spcPos = search(for: " ", in: oneRight, fromLeft: true)
            let pos = min(brkPos, spcPos)
            if pos < oneRight.count {
                divideOne(pos + textRight)
            } else {
                // no spaces left
                return
            }
        }
    }

    private func oneUsage(_ name: String, opt: OptToGet) -> String {
        let brk = Self.softBreak
        var result: [String] = []
        var one: String
        var onlySpaces = name.isEmpty

        one = indent + name
        if let tag = opt.argTag, !tag.isEmpty {
            if name.isEmpty {
                one = indent + tag
            } else {
                one += " " + tag
            }
            onlySpaces = false
        }

        if let usage = opt.usage {
            // check for a blank line
            if onlySpaces && usage.isEmpty { return "" }

            let pad = textLeft - one.count
            if pad > gap {
                one += spaces.prefix(pad)
            } else {
                if !onlySpaces { result.append(one) }
                one = spaces
            }
            one += usage

            while one.count > textRight {
                wrapOnce(&one, &result)
            }
        }
        // remove any soft breaks
        result.append(one.replacingOccurrences(of: String(brk), with: " "))

        if let aka = opt.aka {
            one = indent + "aka: " + aka.joined(separator: ", ")
            result.append(one)
        }

        return result.joined(separator: "\n")
    }

    /// Create a usage string
    /// - Parameters:
    ///   - opts: the options for usage
    ///   - wrap: wrap layout
    ///   - longFirst: put the long option first
    ///   - longOnly: use a single - for long options
    /// - Returns: usage string

    public func optUsage(
        _ opts: OptsToGet,
        options: CLIparserOptions = []
    ) -> String {
        var result: [String] = []
        let longFirst = options.putLongFirst
        let longOnly = options.onlyLong

        for opt in opts.sorted() where !opt.options.isHidden {
            if longOnly, let name = opt.long {
                result.append(oneUsage("-\(name)", opt: opt))
            } else if let long = opt.long, let short = opt.short {
                let names = longFirst ? "--\(long), -\(short)" : "-\(short), --\(long)"
                result.append(oneUsage(names, opt: opt))
            } else if let name = opt.long {
                result.append(oneUsage("--\(name)", opt: opt))
            } else if let name = opt.short {
                result.append(oneUsage("-\(name)", opt: opt))
            } else {
                result.append(oneUsage("", opt: opt))
            }
        }

        return result.joined(separator: "\n")
    }

    /// Create a usage string
    /// - Parameters:
    ///   - opts: the arguments for usage
    /// - Returns: usage string

    public func positionalUsage(_ opts: OptsToGet) -> String {
        var result: [String] = []

        for opt in opts {
            result.append(oneUsage("", opt: opt))
        }

        return result.joined(separator: "\n")
    }

    public func paragraphWrap(_ paragraphs: [String]) -> String {
        let opts = paragraphs.map { OptToGet(usage: $0.replacingOccurrences(of: "\n", with: " ")) }
        return positionalUsage(opts)
    }

    /// Create a usage string from CmdsToGet
    /// - Parameters:
    ///   - cmds: list of CmdToGet
    /// - Returns: usage string

    public func cmdUsage(_ cmds: CmdsToGet) -> String {

        /// Create an OptToGet from CmdToGet data
        /// - Parameter cmd: CmdToGet instance
        /// - Returns: OptToGet instance

        func cmds2opts(_ cmd: CmdToGet) -> OptToGet {
            return OptToGet(usage: cmd.usage, argTag: cmd.cmdAndSub.joined(separator: " "))
        }

        let opts = cmds.filter { $0.usage != nil && $0.cmdAndSub.count > 0 }.map { cmds2opts($0) }
        return positionalUsage(opts)
    }
}
