import Foundation
import ConsoleKit

final class GameSessionController: BaseController {
    enum State {
        case initialized(GameSession)
        case starting(GameSession)
        case playing(GameSession)
        case stopping(GameSession)

        var gameSession: GameSession {
            switch self {
            case .initialized(let gameSession)   : return gameSession
            case .starting(let gameSession)      : return gameSession
            case .playing(let gameSession)       : return gameSession
            case .stopping(let gameSession)      : return gameSession
            }
        }
    }

    required init(with context: AppContext, gameSession: GameSession) {
        self.state = .initialized(gameSession)
        super.init(with: context)
    }

    fileprivate var state: State

    func drawBanner() {
        self.console.output("""
        - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        | GAME ID: \(self.state.gameSession.id)                   |
        - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
        """.consoleText(.info))
    }

    override func start() {
        defer {
            // Detaches from parent and `deinit`
            self.pop()
        }
        
        defer { self.console.popEphemeral() }
        self.console.pushEphemeral()
        
        self.drawBanner()
        
        var gameServer = self.context.gameServer
        
        if case(.initialized) = self.state {
            self.state = .starting(self.state.gameSession)
            self.console.output("|> Connecting to server...".consoleText(.info))
            self.state.gameSession.start(on: &gameServer)
        }
        
        if case(.starting) = self.state {
            self.state = .playing(self.state.gameSession)
        }
        
        while case(.playing) = self.state {
            defer { self.console.popEphemeral() }
            self.console.pushEphemeral()
            
            self.console.output("|> Waiting for more players...".consoleText(.info))
            self.state.gameSession.join(players: gameServer.players)
            
            while var votingRound = self.state.gameSession.beginVoting() {
                self.dealStartingCardsIfNecssary()

                self.push(child: VotingRoundController(with: context, votingRound: votingRound))
                self.state.gameSession.end(votingRound: &votingRound)
            }
            
            self.state = .stopping(self.state.gameSession)
        }
        
        if case(.stopping) = self.state {
            self.console.output("|> Disconnecting to server...".consoleText(.info))
            self.state.gameSession.stop(on: &gameServer)
        }
    }
    
    private func dealStartingCardsIfNecssary() {
        guard let cardCount = context.signature.cardsToStart, self.state.gameSession.completedRounds == 0 else {
            return
        }
        
        self.state.gameSession.playerSessions.forEach {
            for _ in 0..<cardCount {
                $0.player?.receive(Card())
            }
        }
    }
}
