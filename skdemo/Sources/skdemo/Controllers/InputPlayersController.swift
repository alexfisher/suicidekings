import Foundation
import ConsoleKit

final class InputPlayersController: BaseController {
    enum State {
        case askForName
        case completed
    }
    
    private var numberOfBots: Int = 10
    private var playerListString: String {
        players.reduce("") { result, next in
            result + "|>  - \(next.id): \"\(next.name ?? "")\"\n"
        }
    }

    fileprivate var state: State = .askForName
    fileprivate var players: [Player] = []
    
    fileprivate func showConfirmPrompt() {
        guard console.confirm("Add another?") else {
            self.state = .completed
            return
        }
    }

    private func getPlayerName() -> Player? {
        let player = Player(name: console.ask("Player Name?"), bankRoll: context.signature.bankRoll ?? 1.0)
        guard let name = player.name, !name.isEmpty else {
            return nil
        }
        return player
    }
    
    private func addBotsIfNecessary() {
        guard context.signature.bots else {
            return
        }
        
        for _ in 0..<(context.signature.botCount ?? numberOfBots) {
            self.players.append(Player(name: .randomString(ofLength: 6), isBot: true, bankRoll: context.signature.bankRoll ?? 1.0))
        }
    }
    
    private func drawBanner() {
        self.console.output("""
            - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            | REGISTER NEW PLAYERS:                                           |
            - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            """.consoleText(.info))
    }

    override func start() {
        defer {
            // Detaches from parent and `deinit`
            super.pop()
        }
        
        defer { console.popEphemeral() }
        self.console.pushEphemeral()
        
        self.drawBanner()
        self.addBotsIfNecessary()
        
        while case(.askForName) = state {
            defer { console.popEphemeral() }
            self.console.pushEphemeral()
            
            console.printPlayerList(self.players)
            
            self.showConfirmPrompt()
            
            if case(.askForName) = state, let player = self.getPlayerName() {
                self.players.append(player)
            }
        }

        self.players.forEach {
            self.context.gameServer.add($0)
        }
    }
}
