import Foundation

public final class PlayerSession: Codable {
    public init(playerID: Player.ID, gameSessionID: GameSession.ID) {
        self.playerID      = playerID
        self.gameSessionID = gameSessionID
    }
    
    public private(set) var playerID      :Player.ID
    public private(set) var gameSessionID :GameSession.ID

    public var player: Player? {
        GameServer.shared[playerID: playerID]
    }
    
    public var gameSession: GameSession? {
        GameServer.shared[gameSessionID: gameSessionID]
    }
    
    @discardableResult
    public func draw() -> Card? {
        guard let player = player else {
            return nil
        }
        
        let card = Card()
        guard player.receive(card) else {
            return nil
        }
        
        gameSession?.deposit(card.value)
        
        return card
    }

    public func burn(card id: Card.ID) -> Card? {
        guard let player = player, let card = player.burn(card: id) else {
            return nil
        }
        
        gameSession?.withdrawl(card.value)
        
        return card
    }
}

extension PlayerSession {
    @discardableResult
    public func autoDraw() -> [Card] {
        var cardsDrawn = [Card]()
        while let card = self.draw() {
            cardsDrawn.append(card)
        }
        
        return cardsDrawn
    }
}

extension PlayerSession {
    public var allEligibleCards: [Card] {
        player?
            .cards
            .filter { $0.state == .playable }
            ?? []
    }
}
