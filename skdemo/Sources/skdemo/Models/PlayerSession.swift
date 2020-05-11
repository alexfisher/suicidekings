import Foundation

struct PlayerSession: Codable {
    private(set) var playerID: UUID
    private(set) var sessionID: UUID
    private(set) var joinedAt: Date

    var player: Player? {
        GameServer.shared[playerID: playerID]
    }
    
    var allEligibleCards: [Card] {
        player?
            .cards
            .filter { $0.state == .playable }
            ?? []
    }
}

