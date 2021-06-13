import Foundation
import CLIparser

let argList = ArgumentList(options: [.longOnly])
let command = getCommand(argList)
do {
    try setOptions(for: command, from: argList)
} catch {
    print(error.localizedDescription)
}

command.execute()

