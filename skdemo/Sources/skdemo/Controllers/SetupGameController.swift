import Foundation
import ConsoleKit

final class SetupGameController: BaseController {
    enum State {
        case uninitialized
        case initialized(GameSessionSettings)

        var settings: GameSessionSettings? {
            guard case(.initialized(let settings)) = self else {
                return nil
            }
            return settings
        }
    }

    required init(with context: AppContext, delegate: SetupGameDelegate? = nil) {
        super.init(with: context)
        self.delegate = delegate
    }

    private weak var delegate: SetupGameDelegate?

    private var state: State = .uninitialized

    private func displaySettings() {
        let output = (try? self.state.settings?.prettyPrinted()) ?? "<SETTINGS FAILURE>"
        console.output(output.consoleText(.info))
    }

    private func showConfirmPrompt() {
        guard console.confirm("Confirm settings") else {
            self.state = .uninitialized
            return
        }
    }
    
    private func drawBanner() {
        self.console.output("""
            - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            | CREATING NEW SESSION:                                           |
            - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            """.consoleText(.info))
    }

    override func start() {
        defer {
            // Detaches from parent and `deinit`
            super.pop()
        }
        
        defer { console.popEphemeral() }
        self.console.pushEphemeral()
        
        self.drawBanner()
        
        while case(.uninitialized) = state {
            defer { console.popEphemeral() }
            console.pushEphemeral()

            console.printPlayerList()
            console.output("|> Setup game:")

            defer { console.popEphemeral() }
            console.pushEphemeral()
            
            let liquidity = context.signature.liquidity ?? 10_000
            let rounds    = context.signature.rounds ?? 100
            let rate      = context.signature.rate ?? 5.0
            let settings  = GameSessionSettings(
                         liquidity: liquidity,
                     numberOfRound: rounds,
                      interestRate: rate)
            
            self.state = .initialized(settings)
            
            self.displaySettings()
            self.showConfirmPrompt()
        }

        self.delegate?.controller(self, didSetup: self.state.settings)
    }
}

protocol SetupGameDelegate: class {
    func controller(_ controller: SetupGameController, didSetup settings: GameSessionSettings?)
}
