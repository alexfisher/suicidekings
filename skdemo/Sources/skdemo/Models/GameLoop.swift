import Foundation
import ConsoleKit

struct GameLoop {
    init(console: Console) {
        self.console = console
    }

    private let console: Console

    func inputPlayerNames(automatically: Bool) -> [Player] {
        var outputString = ""
        var players: [Player] = [] {
            didSet {
                outputString = players.reduce("") { result, next in
                    result + "|>  - \(next.id): \"\(next.name ?? "")\"\n"
                }
            }
        }

        guard automatically == false else {
            let botNames = (0..<10)
                .map { _ in Player(name: .randomString(ofLength: 6)) }
            /*
            let botNames: [String] = [
                "kevin",
                "wade",
                "alex"
            ]
            */
            players = botNames // .map(Player.init(name:))

            console.output("|> Adding players:".consoleText(.info))
            console.output(outputString.consoleText(.info))
            return players
        }

        var getName: Bool = true
        repeat {
            guard getName else { break }

            defer { console.popEphemeral() }
            console.pushEphemeral()

            if players.count > 0 {
                console.output("|> Adding players:".consoleText(.info))
                console.output(outputString.consoleText(.info))
            }

            let player = Player(name: console.ask("Add Player:")) 
            if !(player.name ?? "").isEmpty {
                players.append(player)
            }

            console.output("")
            getName = console.confirm("Add more?".consoleText())
        } while getName

        return players
    }
}
