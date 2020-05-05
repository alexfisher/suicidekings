import Foundation

final class Card: Identifiable, Comparable, Codable, CustomStringConvertible {
    static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.points < rhs.points
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.points == rhs.points
    }

    enum Pip: String, Codable {
        case hearts
        case clubs
        case spades
        case diamonds

        func display(color: Color) -> String {
            switch (self, color) {
            case (.hearts, .red):
                return "♡"
            case (.spades, .red):
                return "♤"
            case (.clubs, .red):
                return "♤"
            case (.diamonds, .red):
                return "♢"
            case (.hearts, .black):
                return "♥"
            case (.spades, .black):
                return "♠"
            case (.clubs, .black):
                return "♣"
            case (.diamonds, .black):
                return "♦"
            }
        }

        static private let allPips: [Pip] = [.hearts, .clubs, .spades, .diamonds]

        static func random() -> Pip {
            allPips.randomElement()!
        }
    }

    enum Color: String, Codable {
        case red
        case black

        static private let allColors: [Color] = [.red, .black]

        static func random() -> Color {
            allColors.randomElement()!
        }
    }

    enum State: String, Codable {
        case playable
        case burned
        case discarded
    }

    var state: State   = .playable
    var points: Double = 0.0
		private(set) var id: UUID	    = UUID()
    private(set) var pip: Pip     = .random()
    private(set) var color: Color = .random()

    var level: Int {
        Int(sqrt(points / 100.0))
    }

    var votes: Int {
        switch state {
        case .playable:
            return 1
        case .burned:
            return Int(pow(Double(level), 2.0))
        case .discarded:
            return 0
        }
    }

    var description: String {
        """
        - \(pip.display(color: color))
        - Exp. : \(points)
        - Level: \(level)
        - Votes: \(votes)
        """
    }

    func burn() {
        self.state = .burned
    }

    func update() {
        guard case(.burned) = self.state else {
            return
        }
        self.state = .discarded
    }
}

