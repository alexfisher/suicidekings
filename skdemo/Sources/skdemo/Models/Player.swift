import Foundation

class Player: Identifiable, Codable {
    init(name: String?) {
        self.name = name
    }

    private(set) var name: String?
	  private(set) var id: UUID      = UUID()
    private(set) var cards: [Card] = []

    var votes: Int {
        cards.reduce(0) { result, next in
            result + next.votes
        }
    }

    func receive(_ card: Card) {
        self.cards.append(card)
    }

    func update() {
        self.cards.forEach {
            $0.update()
        }
    }
}

