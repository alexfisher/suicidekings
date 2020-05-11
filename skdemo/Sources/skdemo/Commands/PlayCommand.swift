import Foundation
import ConsoleKit

struct PlayCommand: Command {
    struct Signature: CommandSignature {
        @Option(name: "rounds", short: "r", help: "Sets the number of round to play. Defaults to 10")
        var rounds: Int?

        @Option(name: "liquidity", short: "l", help: "Sets the starting amount for the liquidity pool. Defaults to 10,000")
        var liquidity: Double?

        @Option(name: "rate", short: "i", help: "Sets the interest rate for the liquidity collateral. Defaults to 5%")
        var rate: Double?

        @Option(name: "starting-cards", short: "c", help: "Sets the number of cards to begin each game with. Defaults to 0")
        var cardsToStart: Int?

        @Option(name: "bot-count", short: "a", help: "Play automatically using (terrible) bots")
        var botCount: Int?
        
        @Option(name: "bank-roll", short: "l", help: "Sets the starting bank roll amount for every player. Defaults to 1 ETH")
        var bankRoll: Double?

        
        @Flag(name: "bots", short: "b", help: "Play automatically using (terrible) bots")
        var bots: Bool
        
        @Flag(name: "auto-buy", short: "y", help: "Automatically buys cards for players at the start of each round. Defaults to false")
        var autoBuys: Bool
    }

    var help: String = "Plays an automated game of \"Suicide Kings\""

    func run(using context: CommandContext, signature: Signature) throws {
        let appContext = AppContext(
                using: context, 
            signature: signature
        )

        appContext.console.clear(.screen)
        AppController(with: appContext).start()
    }
}
