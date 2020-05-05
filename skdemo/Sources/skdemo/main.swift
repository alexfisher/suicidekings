import Foundation
import ConsoleKit

let console = Terminal()
var input   = CommandInput(arguments: CommandLine.arguments)
var context = CommandContext(console: console, input: input)

let choiceString = """
|-------------------------------------------------|
|                  MAKE A CHOICE                  |
|-------------------------------------------------|
|   Earn Interest     |   Increate Voting Power   |
| -----------------   | ------------------------- |
| A1) All Hearts      | B1) All Hearts            |
| A2) All Spades      | B2) All Spades            |
| A3) All Clubs       | B3) All Clubs             |
| A4) All Diamonds    | B4) All Diamonds          |
|                     |                           |
| A5) Specific Level  |                           |
|-------------------------------------------------|
"""

var commands = Commands(enableAutocomplete: true)
commands.use(ClientCommand(), as: "client", isDefault: false)
commands.use(ServerCommand(), as: "server", isDefault: false)
commands.use(AutoplayCommand(), as: "autoplay", isDefault: true)

do {
    let group = commands.group(help: "This is the help text")
    try console.run(group, input: input)
} catch {
    console.error("\(error)")
    exit(1)
}

import WebSocketKit
enum OpCode: UInt8, Codable {
    case ack  = 100
}
extension WebSocket {
    fileprivate func send(_ opCode: OpCode) {
        send([opCode.rawValue])
    }
    func ack() {
        send(.ack)
    }
}
