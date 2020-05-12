extension VotingRound {
    public enum Proposal: CustomStringConvertible {
        case earnInterest(on: Characteristic)
        case increaseVotingPower(for: Characteristic)

        public static func random(levelCap: Int) -> VotingRound.Proposal {
            switch Int.random(in: 0...1) {
                case 0:
                    return .earnInterest(on: .random(levelCap: levelCap))
                case 1:
                    let proposal: Proposal = .increaseVotingPower(for: .random(levelCap: levelCap))
                    guard case(.level) = proposal.characteristic else {
                        return proposal
                    }
                    // Can't vote for increasing XP for specific levels
                    return random(levelCap: levelCap)
            default: fatalError()
            }
        }

        public var characteristic: Characteristic {
            switch self {
            case .earnInterest(let char): return char
            case .increaseVotingPower(let char): return char
            }
        }

        public var label: String {
            switch self {
            case .earnInterest:
                return "earnInterest"
            case .increaseVotingPower:
                return "increaseVotingPower"
            }
        }

        public var description: String {
            switch self {
            case .earnInterest(let char):
                return "+Earn, on: \"\(char)\""
            case .increaseVotingPower(let char):
                return "+Vote, for: \"\(char)\""
            }
        }
    }
}

extension VotingRound.Proposal: Codable {
    enum CodingKeys: CodingKey {
        case earnInterest, increaseVotingPower
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try? container.decode(Characteristic.self, forKey: .earnInterest) {
            self = .earnInterest(on: value)
        }
        else if let value = try? container.decode(Characteristic.self, forKey: .increaseVotingPower) {
            self = .increaseVotingPower(for: value)
        } else {
            fatalError(file: #file, line: #line)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .earnInterest(let char):
            try container.encode(char, forKey: .earnInterest)
        case .increaseVotingPower(let char):
            try container.encode(char, forKey: .increaseVotingPower)
        }
    }
}

extension VotingRound.Proposal {
    public enum Characteristic: Hashable, CustomStringConvertible, Codable {
        case color(Card.Color)
        case level(Int)
        case pip(Card.Pip)
        case unknown

        public static func random(levelCap: Int) -> Characteristic {
            switch Int.random(in: 0...2) {
            case 0: return .color(.random())
            case 1: return .level(Int.random(in: 0...levelCap))
            case 2: return .pip(.random())
            default: fatalError()
            }
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            let components = value.components(separatedBy: " ")
            guard components.count == 2 else {
                self = .unknown
                return
            }

            let prefix = components.first ?? ""
            let suffix = components.last ?? ""
            if prefix == "color", let color = Card.Color(rawValue: suffix) {
                self = .color(color)
            } else if prefix == "pip", let pip = Card.Pip(rawValue: suffix) {
                self = .pip(pip)
            } else if prefix == "level", let level = Int(suffix) {
                self = .level(level)
            } else {
                self = .unknown
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.description)
        }

        public var description: String {
            switch self {
            case .pip(let pip): return "pip \(pip.rawValue)"
            case .level(let level): return "level \(level)"
            case .color(let color): return "color \(color.rawValue)"
            case .unknown: return "unknown"
            }
        }
    }
}

