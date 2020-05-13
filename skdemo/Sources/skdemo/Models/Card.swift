import Foundation

public final class Card: Identifiable, Codable {
    public var points: Double = 0.0
    public var  value: Double = 0.1
    
    public private(set) var color : Color = .random()
    public private(set) var id    : UUID  = UUID()
    public private(set) var pip   : Pip   = .random()
    public private(set) var state : State = .playable

    public func burn() {
        self.state = .burned
    }
    
    public func discard() {
        guard case(.burned) = self.state else {
            return
        }
        self.state = .discarded
    }
}

extension Card {
    public enum Pip: String, Hashable, Codable, CustomStringConvertible {
        case hearts
        case clubs
        case spades
        case diamonds
        
        public var description: String {
            switch self {
                case .hearts:   return "♥"
                case .clubs:    return "♣"
                case .spades:   return "♠"
                case .diamonds: return "♦"
            }
        }
        
        public var asciiArt: (pip: String, art: String) {
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

        private static let allPips: [Pip] = [
            .hearts, .clubs, .spades, .diamonds
        ]

        public static func random() -> Pip {
            allPips.randomElement()!
        }
    }
}

extension Card {
    public enum Color: String, Hashable, Codable {
        case red
        case black
        case blue
        case yellow
        case white
        case green
        case magenta

        private static let brightColors: [Color] = [
            .red, .magenta, .white, .green
        ]

        public static func random() -> Color {
            brightColors.randomElement()!
        }
    }

    public enum State: String, Codable {
        case playable
        case burned
        case discarded
    }

    public var level: Int {
        Int(sqrt(points / 100.0))
    }

    public var votes: Int {
        switch state {
        case .playable:
            return 1
        case .burned:
            if level == 1 {
                return 2
            }
            return Int(pow(Double(level), 2.0))
        case .discarded:
            return 0
        }
    }
}

extension Card: Hashable, Comparable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
    
    public static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.points < rhs.points
    }
    
    public static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.points == rhs.points
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
    
    var consoleTextShort: ConsoleText {
        "\(pip) (xp: \(String(format: "%.2f", points)); lvl \(level))".consoleText(color: color.consoleColor)
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
