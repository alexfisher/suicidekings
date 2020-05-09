import Foundation
import ConsoleKit

final class AppContext {
    init(using context: CommandContext, signature: PlayCommand.Signature) {
        self.context = context
        self.signature = signature
    }

    // MARK: Properties (Public)
    private(set) var context: CommandContext
    private(set) var signature: PlayCommand.Signature

    let gameServer: GameServer = .shared

    // MARK: Properties (Computed)
    var console: Console {
        context.console
    }

    func clear() {
        self.gameServer.reset()
    }
}

extension AppContext {
    func push() {
        context.console.pushEphemeral()
    }

    func pop() {
        context.console.popEphemeral()
    }
}

extension Console {
    func printPlayerList(_ players: [Player] = GameServer.shared.players) {
        var playerListString: String {
            players.reduce("") { result, next in
                result + "|>  - \(next.id): \"\(next.name ?? "")\"\n"
            }
        }

        if players.count > 0 {
            self.output("|> Added players:")
            self.output(playerListString.consoleText(.info))
        }
    }
}
