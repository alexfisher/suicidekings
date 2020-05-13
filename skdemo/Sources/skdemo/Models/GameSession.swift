import Foundation
import ConsoleKit

public class GameSession: Identifiable, Codable {
    public enum State: String, Codable {
        case initialized
        case started
        case waitingForPlayers
        case voting
        case stopped
    }

    public init(settings: GameSessionSettings) {
        self.settings = settings
        self.principleAmount = settings.liquidity
    }

    public private(set) var settings: GameSessionSettings
    public private(set) var state: State = .initialized
    public private(set) var completedRounds: Int = 0

    public private(set) var principleAmount: Double
    public var valueAwardedEachRound: Double { settings.xpAwardAmount }

    public private(set) var id: UUID = UUID()
    public private(set) var playerSessions: [PlayerSession] = []
    
    public func deposit(_ amount: Double) {
        self.principleAmount += amount
    }
    
    public func withdrawl(_ amount: Double) {
        self.principleAmount -= amount
    }
    
    public func join(player: Player) {
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

        let playerSession = PlayerSession(playerID: player.id, gameSessionID: self.id)
        self.playerSessions.append(playerSession)
    }

    public func join(players: Player...) {
        players.forEach {
            self.join(player: $0)
        }
    }

    public func join(players: [Player]) {
        players.forEach {
            self.join(player: $0)
        }
    }

    public func dealCards() {
        self
            .playerSessions
            .compactMap { $0.player }
            .forEach {
                $0.receive(Card())
            }
    }

    public func accrueInterest(atRate interestRate: Double, occuring frequency: Double = 4.0, overTime iterations: Int = 1) -> Double {
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

    public func start(on gameServer: inout GameServer) {
        guard case(.initialized) = self.state else {
            return
        }
        defer {
            self.state = .waitingForPlayers
        }
        gameServer.add(self)
    }

    public func beginVoting() -> VotingRound? {
        guard case(.waitingForPlayers) = self.state, self.completedRounds < self.settings.numberOfRound else
        {
            return nil
        }

        defer {
            self.state = .voting
        }
        return VotingRound(id: self.completedRounds, playerSessions: self.playerSessions)
    }

    public func end(votingRound: inout VotingRound) {
        defer {
            self.state = .waitingForPlayers
        }
        votingRound.close()
        self.completedRounds += 1
    }

    public func stop(on gameServer: inout GameServer) {
        self.state = .stopped
    }

    public func hasPlayerJoined(_ player: Player) -> Bool {
        self.playerSessions
            .map { $0.playerID }
            .contains(player.id)
    }
}

public struct GameSessionSettings: Codable {
    public init(           liquidity: Double = 10000,
                xpAwardAmount: Double = 100,
                numberOfRound: Int    = 10,
                 interestRate: Double = 5,
            compoundFrequency: Double = 3,
     interestRateSeriesLength: Int    = 1)
    {
        self.liquidity                 = liquidity
        self.xpAwardAmount             = xpAwardAmount
        self.numberOfRound             = numberOfRound
        self.interestRate              = interestRate
        self.compoundFrequency         = compoundFrequency
        self.interestRateSeriesLength  = interestRateSeriesLength
    }

    public let          liquidity: Double
    public let      xpAwardAmount: Double
    public let      numberOfRound: Int
    public let       interestRate: Double
    public let  compoundFrequency: Double
    public let interestRateSeriesLength: Int
}
