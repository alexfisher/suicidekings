import Foundation

final class GameServer: Codable {
    private enum CodingKeys: String, CodingKey {
        case players, gameSessions
    }

    private init() { }

    private let queue = DispatchQueue(label: "suicidekings.gameserver.io.queue")

    private(set) var players: [Player] = []
    private(set) var gameSessions: [GameSession] = []

    subscript(gameSessionID id: UUID) -> GameSession? {
        queue.sync {
            gameSessions.first(where: {
                $0.id == id
            })
        }
    }

    subscript(playerID id: UUID) -> Player? {
        queue.sync {
            players.first(where: {
                $0.id ==  id
            })
        }
    }

    subscript(playerName name: String) -> [Player] {
        queue.sync {
            players.filter {
                $0.name == name
            }
        }
    }

    func add(_ gameSession: GameSession) {
        guard self[gameSessionID: gameSession.id] == nil else {
            return
        }

        queue.async(flags: .barrier) {
            self.gameSessions.append(gameSession)
        }
    }

    func add(_ player: Player) {
        guard self[playerID: player.id] == nil else {
            return
        }
        queue.async(flags: .barrier) {
            self.players.append(player)
        }
    }

    func reset() {
        self.players.removeAll()
        self.gameSessions.removeAll()
    }

    static var shared = GameServer()
}

