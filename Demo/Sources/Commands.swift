import Foundation
import CLIparser

enum CommandType: CLIparserTag {
    case branch, commit, status, unspecified

    func execute() { return }
}

let commands: CmdsToGet = [
    CmdToGet(["branch"], tag: CommandType.branch),
    CmdToGet(["commit"], tag: CommandType.commit),
    CmdToGet(["status"], tag: CommandType.status)
]

func getCommand(_ list: ArgumentList) -> CommandType {
    return list.commandParser(commands)?.tag as? CommandType ?? .unspecified
}
