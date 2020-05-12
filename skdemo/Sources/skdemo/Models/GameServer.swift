import Foundation

public final class GameServer: Codable {
    private enum CodingKeys: String, CodingKey {
        case players, gameSessions
    }

    private init() { }

    private let queue = DispatchQueue(label: "suicidekings.gameserver.io.queue")

    public private(set) var players: [Player] = []
    public private(set) var gameSessions: [GameSession] = []

    public subscript(gameSessionID id: UUID) -> GameSession? {
        queue.sync {
            gameSessions.first(where: {
                $0.id == id
            })
        }
    }

    public subscript(playerID id: UUID) -> Player? {
        queue.sync {
            players.first(where: {
                $0.id ==  id
            })
        }
    }

    public subscript(playerName name: String) -> [Player] {
        queue.sync {
            players.filter {
                $0.name == name
            }
        }
    }

    public func add(_ gameSession: GameSession) {
        guard self[gameSessionID: gameSession.id] == nil else {
            return
        }

        queue.async(flags: .barrier) {
            self.gameSessions.append(gameSession)
        }
    }

    public func add(_ player: Player) {
        guard self[playerID: player.id] == nil else {
            return
        }
        queue.async(flags: .barrier) {
            self.players.append(player)
        }
    }

    public func reset() {
        self.players.removeAll()
        self.gameSessions.removeAll()
    }

    public static var shared = GameServer()
}

