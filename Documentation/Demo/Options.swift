import Foundation
import CLIparser

// Global options
var all = false
var deleteBranch: String?
var listBranches = false
var message: String?
var moveBranch: [String]?
var short = false
var status = true
var verbosity = 0
var fileNames: [String]?

enum OptionType: CLIparserTag {
    case all, delete, list, message, move, short, status, verbose, positional, unknown
}

let branchOptions: OptsToGet = [
    OptToGet(long: "delete", 1...1, tag: OptionType.delete,
             usage: "Delete a branch", argTag: "<branch>"),
    OptToGet(long: "list", tag: OptionType.list, usage: "List branches"),
    OptToGet(long: "move", 1...2, tag: OptionType.move,
             usage: "Move (rename) a branch\ncurrent to new or\nold to new", argTag: "[old] <new>" )
]

let commitOptions: OptsToGet = [
    OptToGet(long: "all", tag: OptionType.all, usage: "Commit all files"),
    OptToGet(long: "message", 1...1, tag: OptionType.message, usage: "Commit message", argTag: "<text>"),
    OptToGet(long: "status", options: [.flag], tag: OptionType.status, usage: "Show status after commit")
]

let commonOptions: OptsToGet = [
    OptToGet(long: "short", tag: OptionType.short, usage: "Keep output short"),
    OptToGet(long: "verbose", options: [.hidden, .multi])
]

func setOptions(for command: CommandType, from list: ArgumentList) throws {
    let toGet: OptsToGet
    switch command {
    case .branch: toGet = commonOptions + branchOptions
    case .commit: toGet = commonOptions + commitOptions
    default: toGet = commonOptions
    }
    let opts = try list.optionsParse(toGet, OptionType.positional)
    for opt in opts {
        let tag = opt.tag as? OptionType ?? .unknown
        switch tag {
        case .all: all = true
        case .delete: deleteBranch = opt.stringValue
        case .list: listBranches = true
        case .message: message = opt.stringValue
        case .move: moveBranch = OptValueAt.stringArray(opt.optValuesAt)
        case .short: short = true
        case .status: status = (opt.count != 0)
        case .verbose: verbosity = opt.count
        case .positional: fileNames = OptValueAt.stringArray(opt.optValuesAt)
        case .unknown:
            print("unknown option")
            exit(1)
        }
    }
}
