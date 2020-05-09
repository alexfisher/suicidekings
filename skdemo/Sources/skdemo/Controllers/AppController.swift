import Foundation
import ConsoleKit

final class AppController: BaseController {
    enum State {
        case uninitialized
        case started
        case inputtingNewPlayers
        case settingUpGame
        case playingGame(with: GameSessionSettings)
        case shuttingDown
    }

    private var gameSessionSettings: GameSessionSettings?
    
    private var  previousState: State = .uninitialized
    fileprivate(set) var state: State = .uninitialized {
        willSet {
            previousState = state
        }
        didSet {
            switch state {
            case .inputtingNewPlayers:
                self.push(child: InputPlayersController(with: context))
            case .settingUpGame:
                self.push(child: SetupGameController(with: context, delegate: self))
            case .playingGame(let settings):
                self.push(child: GameSessionController(with: context,
                                                gameSession: GameSession(settings: settings)))
            case .started:
                self.context.clear()
            default: ()
            }
        }
    }

    fileprivate func drawBanner() {
        console.output("""
        - - - - - - - - - - - - - - - -
         ♔ Welcome to: SUICIDE KINGS ♔
        - - - - - - - - - - - - - - - -
        + Play Mode (🤖: \(context.signature.bots))
        + v0.0.1
        - - - - - - - - - - - - - - - -
        |        ~ TEAM SKETH ~       |
        - - - - - - - - - - - - - - - -

        """
        .consoleText(color: .brightYellow))
    }

    override func start() {
        defer {
            // Detaches from parent and `deinit`
            self.pop()
        }
        
        while case(.uninitialized) = state {
            defer { console.popEphemeral() }
            self.console.pushEphemeral()
            
            self.drawBanner()
            
            if case(.uninitialized) = state {
                self.state = .started
            }
            
            if case(.started) = state {
                self.state = .inputtingNewPlayers
            }
            
            if case(.inputtingNewPlayers) = state {
                self.state = .settingUpGame
            }
            
            if case(.settingUpGame) = state {
                if let settings = gameSessionSettings {
                    self.state = .playingGame(with: settings)
                } else {
                    console.error("Invalid game settings")
                }
                self.state = .shuttingDown
            }
            
            if case(.shuttingDown) = state {
                self.console.output("""
                - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                | GAME OVER                                                       |
                - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                """.consoleText(.info))
                guard console.confirm("Play again?") else {
                    break
                }
                self.state = .uninitialized
            }
        }
    }
}

extension AppController: SetupGameDelegate {
    func controller(_ controller: SetupGameController, didSetup settings: GameSessionSettings?) {
        self.gameSessionSettings = settings
    }
}
