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
}

