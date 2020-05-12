import Foundation

public struct VotingRound: Identifiable, Codable {
    public init(id: Int, playerSessions: [PlayerSession]) {
        self.ballots   = playerSessions.map(Ballot.init)
        self.createdAt = Date()
        self.id        = id
    }
    
    public private(set) var ballots   :[Ballot] = []
    public private(set) var createdAt :Date
    public private(set) var id        :Int
    public private(set) var state     :State = .opened

    public mutating func close() {
        defer {
            self.state = .closed
        }
        self.ballots.forEach {
            _ = $0.finalize()
        }
    }
    
    public var playableCards: [Card] {
        ballots.flatMap {
            $0.playerCards.filter { $0.state == .playable}
        }
    }
}

extension VotingRound {
    public enum State: String, Codable {
        case opened
        case closed
    }
}
