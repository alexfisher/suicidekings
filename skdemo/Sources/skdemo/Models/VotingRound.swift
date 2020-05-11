import Foundation

struct VotingRound: Identifiable, Codable {
    enum State: String, Codable {
        case opened
        case closed
    }

    init(id: Int, playerSessions: [PlayerSession]) { 
        self.id = id 
        self.createdAt = Date()
        self.ballots = playerSessions.map(Ballot.init)
    }

    private(set) var id: Int
    private(set) var ballots: [Ballot] = []
    private(set) var createdAt: Date
    private(set) var state: State = .opened

    mutating func close() {
        defer { 
            self.state = .closed  
        }
        self.ballots.forEach {
            _ = $0.finalize()
        }
    }
    
    var playableCards: [Card] {
        ballots.flatMap {
            $0.playerCards.filter { $0.state == .playable}
        }
    }
    
    var burnedValue: Double {
        ballots.map({ $0.burnedCardsValue }).reduce(0.0) { result, next in result + next }
    }
}
