import Foundation

class Player: Identifiable, Codable {
    init(name: String?, isBot: Bool = false, bankRoll: Double) {
        self.name = name
        self.isBot = isBot
        self.bankRoll = bankRoll
    }

    private(set) var isBot: Bool = false
    private(set) var bankRoll: Double
    private(set) var name: String?
    private(set) var id: UUID      = UUID()
    private(set) var cards: [Card] = []

    var votes: Int {
        cards.reduce(0) { result, next in
            result + next.votes
        }
    }

    var totalCardValue: Double {
        cards
            .filter { $0.state == .playable }
            .reduce(0.0) { result, next in
            result + next.value
        }
    }

    @discardableResult
    func receive(_ card: Card) -> Bool {
        guard self.bankRoll - card.value > 0.0 else {
            return false
        }
        self.bankRoll -= card.value
        self.cards.append(card)
        return true
    }

    func update() {
        self.cards.forEach {
            if $0.state == .burned {
                self.bankRoll += $0.value
            }
            $0.update()
        }
    }
}

