import Foundation

class GameSession: Identifiable, Codable {
    enum State: String, Codable {
        case initialized
        case started
        case waitingForPlayers
        case voting
        case stopped
    }

    init(startingAmount principleAmount: Double, valueAwardedEachRound: Double) {
        self.principleAmount = principleAmount
        self.valueAwardedEachRound = valueAwardedEachRound
    }

    private(set) var state: State = .initialized
    private(set) var principleAmount: Double
    private(set) var valueAwardedEachRound: Double
    private(set) var completedRounds: Int = 0

    private(set) var id: UUID = UUID()
    private(set) var playerSessions: [PlayerSession] = []

    func join(player: Player) {
        // Players cannot join session already in-progress
        guard case(.waitingForPlayers) = self.state else {
            return
        }

        let idx = self.playerSessions.first(where: {
            $0.playerID == player.id
        })

        // Player has already joined
        guard idx == nil else {
            return
        }

        let playerSession = PlayerSession(playerID: player.id, sessionID: self.id, joinedAt: Date())
        self.playerSessions.append(playerSession)
    }

    func join(players: Player...) {
        players.forEach {
            self.join(player: $0)
        }
    }

    func join(players: [Player]) {
        players.forEach {
            self.join(player: $0)
        }
    }

    func dealCards() {
        self
            .playerSessions
            .compactMap { $0.player }
            .forEach {
                $0.receive(Card())
            }
    }

    func accrueInterest(atRate interestRate: Double, occuring frequency: Double = 4.0, overTime iterations: Int = 1) -> Double {
        guard frequency > 0  else {
            return principleAmount
        }

        let nominalRate = interestRate / 100.0
        let newPrincipleAmount = self.principleAmount * pow(1.0 + (nominalRate/frequency), frequency * Double(iterations))
        defer {
            principleAmount = newPrincipleAmount
        }

        return newPrincipleAmount - principleAmount
    }

    func start(on gameServer: inout GameServer) {
        guard case(.initialized) = self.state else {
            return
        }
        defer {
            self.state = .waitingForPlayers
        }
        gameServer.add(self)
    }

    func beginVoting() -> VotingRound? {
        guard case(.waitingForPlayers) = self.state else {
            return nil
        }
        defer {
            self.state = .voting
        }
        return VotingRound(id: self.completedRounds, playerSessions: self.playerSessions)
    }

    func end(votingRound: inout VotingRound) {
        defer {
            self.state = .waitingForPlayers
        }
        votingRound.close()
        self.completedRounds += 1
    }

    func stop(on gameServer: inout GameServer) {
        defer {
            self.state = .stopped
        }
    }

    func hasPlayerJoined(_ player: Player) -> Bool {
        self.playerSessions
            .map { $0.playerID }
            .contains(player.id)
    }
}
