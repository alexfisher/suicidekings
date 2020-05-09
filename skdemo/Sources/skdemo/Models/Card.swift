import Foundation

final class Card: Hashable, Identifiable, Comparable, Codable, CustomStringConvertible {
    static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.points < rhs.points
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.points == rhs.points
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }

    enum Pip: String, Hashable, Codable {
        case hearts
        case clubs
        case spades
        case diamonds
        
        var asPip: String {
            switch self {
                case .hearts:   return "♥"
                case .clubs:    return "♣"
                case .spades:   return "♠"
                case .diamonds: return "♦"
            }
        }
        
        var asciiArt: (pip: String, art: String) {
            let pip: String = {
                switch self {
                case .hearts:   return "♥"
                case .clubs:    return "♣"
                case .spades:   return "♠"
                case .diamonds: return "♦"
                }
            }()
            
            return (pip: "|> \(pip) - \(self.rawValue.uppercased())", art: """
            ┌─────────┐
            │K        │
            │         │
            │         │
            │    \(pip)    │
            │         │
            │         │
            │       K │
            └─────────┘
            """)
        }
        
        var asciiPip: String {
            switch self {
            case .diamonds: return
                """
                  /▲\\
                 /♦♦♦\\
                 ♦♦♦♦♦
                 \\♦♦♦/
                  \\▼/
                """
            case .clubs: return
                """
                     ♣
                   (♣♣♣)
                 (♣ )♣( ♣)
                ((♣)) ((♣))
                    )♣(
                """
            case .hearts: return
                """
                 ⏜    ⏜
                (♥♥\\ /♥♥)
                 \\♥♥♥♥♥/
                  \\♥♥♥/
                   \\♥/
                """
            case .spades: return
                """
                   /♠\\
                  /♠♠♠\\
                 /♠♠♠♠♠\\
                (♠♠♠♠♠♠♠)
                   )♠(
                """
            }
        }

        func display(color: Color) -> String {
            switch (self, color) {
            case (.hearts, .black):
                return "♡"
            case (.spades, .black):
                return "♤"
            case (.clubs, .black):
                return "♤"
            case (.diamonds, .black):
                return "♢"
            case (.hearts, .red):
                return "♥"
            case (.spades, .red):
                return "♠"
            case (.clubs, .red):
                return "♣"
            case (.diamonds, .red):
                return "♦"
            default: return ""
            }
        }

        static private let allPips: [Pip] = [.hearts, .clubs, .spades, .diamonds]

        static func random() -> Pip {
            allPips.randomElement()!
        }
    }
    

    enum Color: String, Hashable, Codable {
        case red
        case black
        case blue
        case yellow
        case white
        case green
        case magenta

        static private let allColors: [Color] = [.red, .black]
        static private let brightColors: [Color] = [.red, .magenta, .white, .green]

        static func random() -> Color {
            // allColors.randomElement()!
            brightColors.randomElement()!
        }
    }

    enum State: String, Codable {
        case playable
        case burned
        case discarded
    }

    var state: State   = .playable
    var points: Double = 0.0
    var value: Double  = 0.1
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

    var asPip: String {
        pip.display(color: color)
    }

    var asPipAndXP: String {
        "\(asPip)" + String(format: " (xp: %.2f)", points)
    }

    var asPipAndLevel: String {
        "LVL \(level) \(asPip)"
    }

    var description: String {
        """
        \(asPipAndLevel)
        XP: \(points)
        VT: \(votes)
        $$: \(value)
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

#if canImport(ConsoleKit)
import ConsoleKit
extension Card {
    var consoleText: ConsoleText {
        self.pip.asciiArt.pip.consoleText(color: color.consoleColor) + " (" +
        self.color.rawValue.uppercased().consoleText(color: color.consoleColor) + ")\n" +
        self.pip.asciiArt.art.consoleText(color: color.consoleColor)
    }
}

extension Card.Color {
    var consoleColor: ConsoleColor {
        switch self {
        case .black: return .brightBlack
        case .red: return .brightRed
        case .white: return .brightWhite
        case .yellow: return .brightYellow
        case .magenta: return .brightMagenta
        case .blue: return .brightBlue
        case .green: return .brightGreen
        }
    }
}
#endif
