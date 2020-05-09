import Foundation

class Player: Identifiable, Codable {
    init(name: String?, isBot: Bool = false) {
        self.name = name
        self.isBot = isBot
    }

    private(set) var isBot: Bool = false
    private(set) var bankRoll: Double = 10.0
    private(set) var name: String?
    private(set) var id: UUID      = UUID()
    private(set) var cards: [Card] = []

    var votes: Int {
        cards.reduce(0) { result, next in
            result + next.votes
        }
    }

    var totalCardValue: Double {
        cards.reduce(0.0) { result, next in
            result + next.value
        }
    }

    func receive(_ card: Card) {
        guard self.bankRoll - card.value > 0.0 else {
            return
        }
        self.bankRoll -= card.value
        self.cards.append(card)
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

