import Foundation

public class Player: Identifiable, Codable {
    public init(name: String?, isBot: Bool = false, bankRoll: Double) {
        self.name     = name
        self.isBot    = isBot
        self.bankRoll = bankRoll
    }

    public private(set) var bankRoll   :Double
    public private(set) var cards      :[Card] = []
    public private(set) var id         :UUID      = UUID()
    public private(set) var isBot      :Bool = false
    public private(set) var name       :String?

    private func credit(_ amount: Double) {
        self.bankRoll += amount
    }
    
    private func debit(_ amount: Double) {
        self.bankRoll -= amount
    }
    
    public subscript(cardID id: Card.ID) -> Card? {
        cards.first(where: {
            $0.id == id && $0.state == .playable
        })
    }

    public var votes: Int {
        cards.reduce(0) { result, next in
            result + next.votes
        }
    }

    public var totalCardValue: Double {
        cards
            .filter { $0.state == .playable }
            .reduce(0.0) { result, next in
            result + next.value
        }
    }

    @discardableResult
    public func receive(_ card: Card) -> Bool {
        guard self.bankRoll - card.value > 0.0 else {
            return false
        }
        self.debit(card.value)
        self.cards.append(card)
        return true
    }
    
    public func burn(card id: Card.ID) -> Card? {
        guard let card = self[cardID: id] else {
            return nil
        }
        
        card.burn()
        self.credit(card.value)

        return card
    }

    public func discard() {
        self.cards.forEach {
            $0.discard()
        }
    }
}
