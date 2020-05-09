import Foundation
import ConsoleKit

let console = Terminal()
var input   = CommandInput(arguments: CommandLine.arguments)
var context = CommandContext(console: console, input: input)

var commands = Commands(enableAutocomplete: true)
commands.use(PlayCommand(), as: "play", isDefault: true)

#if canImport(WebSocketKit)
commands.use(ClientCommand(), as: "client", isDefault: false)
commands.use(ServerCommand(), as: "server", isDefault: false)
#endif

do {
    let group = commands.group(help: "This is the help text")
    try console.run(group, input: input)
} catch {
    console.error("\(error)")
    exit(1)
}
