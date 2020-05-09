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

        @Flag(name: "bots", short: "b", help: "Play automatically using (terrible) bots")
        var bots: Bool
    }

    var help: String = "Plays an automated game of \"Suicide Kings\""

    func run(using context: CommandContext, signature: Signature) throws {
        let appContext = AppContext(
                using: context, 
            signature: signature
        )

        appContext.console.clear(.screen)
        AppController(with: appContext).start()

        /*
        exit(0)

        let gameLoop    = GameLoop(console: console)
        var gameServer  = GameServer.shared
        var gameSession: GameSession!

        let players         = gameLoop.inputPlayerNames(automatically: signature.autoMode)
        let liquidityAmount = signature.liquidity ?? 10_000
        let xpAwardAmount   = 100.0
        let numberOfRounds  = signature.rounds ?? 10
        let interestRate    = signature.rate ?? 5.0
        let frequency       = 3.0
        let unitOfTime      = 1

        console.output("""
        | - - - - - - - - - - - - - - - - - - - |
        |> Game Session
        |>  - Rounds    : \(numberOfRounds)
        |>  - XP Award  : \(100.0)
        | - - - - - - - - - - - - - - - - - - - |
        |>  - Liquidity : \(liquidityAmount)
        |>  - Int. Rate : \(interestRate)%
        | - - - - - - - - - - - - - - - - - - - |
        | Players       : \(players.count)
        | - - - - - - - - - - - - - - - - - - - |
        """.consoleText(.info))

        if console.confirm("Begin Game?") == false {
            exit(0)
        }

        players.forEach { gameServer.add($0) }

        gameSession = GameSession(
                startingAmount: liquidityAmount, 
         valueAwardedEachRound: xpAwardAmount
        )

        gameSession.start(on: &gameServer)
        gameSession.join(players: gameServer.players)

        repeat {
            let sessions = gameSession.playerSessions
            let players  = sessions.compactMap { $0.player }

            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            console.output("""
            |> Current Value Amount :  \(gameSession.principleAmount) ETH
            |> Accrual Frequency    :  \(frequency)
            |> Within Unit of Time  :  \(unitOfTime) (assuming 24hrs)
            """.consoleText(.info))

            let accruedInterest = gameSession.accrueInterest(atRate: interestRate, occuring: frequency)
            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            console.output("|> Interest Accrued : \(accruedInterest)".consoleText(.info))
            console.output("|> New Principle    : \(gameSession.principleAmount)".consoleText(.info))
            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            console.output("|> Dealing 1 card")

            players.forEach { player in
                let card = Card()
                player.receive(card)
            }

            /*
            players.forEach { player in
                console.output("|> +++ \(player.name!)\t\(card.asPipAndLevel)".consoleText(color: .cyan))
            }
            */

            guard var votingRound = gameSession.beginVoting() else {
                break
            }

            console.output("|> Voting Round: #\(votingRound.id) has begun 🎉".consoleText())
            console.output("|> RED \(Card.Pip.hearts.display(color: .red)) || BLK \(Card.Pip.hearts.display(color: .black))")
            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")

            /// 4. Cast votes
            votingRound.ballots.forEach {
								let choiceString = """
                |-------------------------------------------------|
                |                  MAKE A CHOICE                  |
                |-------------------------------------------------|
                |   Earn Interest     |   Increate Voting Power   |
                | -----------------   | ------------------------- |
                | A0) All Reds        | B0) All Reds              |
                | A1) All Blacks      | B1) All Blacks            |
                | A2) All Hearts      | B2) All Hearts            |
                | A3) All Spades      | B3) All Spades            |
                | A4) All Clubs       | B4) All Clubs             |
                | A5) All Diamonds    | B5) All Diamonds          |
                |                     |                           |
                | A6) Specific Level  |                           |
                |-------------------------------------------------|
                """

                var ballot = $0
                guard let player = ballot.playerSession.player else {
                    console.output("> WARNING: \(#line)".consoleText(.warning))
                    return
                }

								console.output(choiceString.consoleText(.info))
                console.output("> ============================================ <")
                console.output("\(player.name!) -- bank roll: \(player.bankRoll)".consoleText())
                console.output("\(player.name!) -- card val.: \(player.totalCardValue)".consoleText())
                console.output("> ============================================ <")


                let groupedCards = Dictionary(grouping: player.cards, by: { $0.level })
                groupedCards.forEach { (pip: Int, cards: [Card]) in
                    let output = cards.map({ $0.asPipAndXP }).joined(separator: ", ")
                    console.output("Level \(pip): \(output)\n".consoleText())
                }
                console.output("> ============================================ <")

                if false {

                do {
                    while ballot.availableVotes > 0 {
                        switch console.choose("\(player.name!)'s turn:", from: ["View Hand", "Burn Card", "Buy a Card", "Vote"]) {
                            case "View Hand":
                                console.pushEphemeral()
                                let groupedCards = Dictionary(grouping: player.cards, by: { $0.level })
                                groupedCards.flatMap({ $0.1 }).enumerated().forEach {
                                    console.output("#\($0.0): \($0.1.asPip) [votes: \($0.1.votes); xp: \($0.1.points)]".consoleText())
                                }
                                console.output("> ============================================ <")
                                _ = console.ask("Press 'any' key to continue")
                                console.popEphemeral()
                            case "Burn Card":
                                player.cards.enumerated().forEach {
                                    console.output("#\($0.0): \($0.1.asPip) +\($0.1.votes)".consoleText())
                                }

                                let response = console.ask("Which card?")
                                guard let idx = Int(response) else {
                                    continue
                                }
                                let card = player.cards[idx]
                                guard card.level > 0 else {
                                    console.output("|> Cannot burn a 'Level 0' card!")
                                    console.output("> ============================================ <")
                                    _ = console.ask("Press 'any' key to continue")
                                    continue
                                }
                                card.burn()
                                console.output("|> \(player.name!) has burned a card for \(card.votes) votes! (\(card.id))".consoleText(color: .white))
                            case "Buy a Card":
                                let card = Card()
                                ballot.playerSession.player?.receive(card)
                                console.output("\(card.asPip)")
                                console.output("|> +++ \(player.name!)\t\(card.asPipAndLevel)".consoleText(color: .cyan))
                            default:
                                console.output("VOTES REMAINING: \(ballot.availableVotes)".consoleText(.info))
                                guard let votes = Int(console.ask("How many votes?")) else {
                                    continue
                                }

                                var choice: VotingRound.Choice!
                                switch console.ask("Which choice?", isSecure: true).uppercased() {
                                    case "A0": choice = VotingRound.Choice(proposal: .earnInterest(on: .color(.red)), votes: votes)
                                    case "A1": choice = VotingRound.Choice(proposal: .earnInterest(on: .color(.black)), votes: votes)
                                    case "A2": choice = VotingRound.Choice(proposal: .earnInterest(on: .pip(.hearts)), votes: votes)
                                    case "A3": choice = VotingRound.Choice(proposal: .earnInterest(on: .pip(.spades)), votes: votes)
                                    case "A4": choice = VotingRound.Choice(proposal: .earnInterest(on: .pip(.clubs)), votes: votes)
                                    case "A5": choice = VotingRound.Choice(proposal: .earnInterest(on: .pip(.diamonds)), votes: votes)
                                    case "A6": 
                                          let level = Int(console.ask("Level:"))!
                                          choice = VotingRound.Choice(proposal: .earnInterest(on: .level(level)), votes: votes)
                                    case "B0": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .color(.red)), votes: votes)
                                    case "B1": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .color(.black)), votes: votes)
                                    case "B2": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .pip(.hearts)), votes: votes)
                                    case "B3": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .pip(.spades)), votes: votes)
                                    case "B4": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .pip(.clubs)), votes: votes)
                                    case "B5": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .pip(.diamonds)), votes: votes)
                                    default: ()
                                }
                                try ballot.mark(choice: choice)
                                // console.output("| Random choice     : \(choice.votes) vote(s) -> \(choice.proposal)".consoleText())
                                // console.output("|  - Votes Remaining: \(ballot.availableVotes)".consoleText())
                        }
                    }

                }
                catch {
                    print(error)
                }

                }

                //  BOT VOTING IS BROKEN
								if true {
										console.output("> Casting votes ============================== <")
										do {
												while ballot.availableVotes > 0 {
														let choice = try markRandomChoice(on: &ballot, withVotes: .random(in: 1...ballot.availableVotes))
														console.output("| Random choice     : \(choice.votes) vote(s) -> \(choice.proposal)".consoleText())
														console.output("|  - Votes Remaining: \(ballot.availableVotes)".consoleText())
												}
										}
										catch {
												print(error)
										}
										console.output("> ============================================ <")
								}
            }

            // console.clear(.screen)
            console.output("> ============================================ <")
            console.output("\tClosing Round #\(votingRound.id)".consoleText())
            gameSession.end(votingRound: &votingRound)
            console.output("> ============================================ <")

            let allEligibleCards = votingRound.ballots
                .compactMap { $0.playerSession.player?.cards }
                .flatMap { $0 }
                .filter { $0.state == .playable }
            
            let allBallotChoices = votingRound.ballots
                .flatMap { $0.choices }

            let group = Dictionary<String, [VotingRound.Choice]>(grouping: allBallotChoices, by: { $0.proposal.label })
            console.output("\(group as AnyObject)".consoleText(.info))

            let totalVotesForEarnInterestVotes = group["earnInterest"]?
         .reduce(0) { result, next in
                result + Double(next.votes)
            } ?? 0

            let earnedInterestVoteChoicesAndVotes = group["earnInterest"]?.map {
                ($0.proposal.characteristic, Double($0.votes) / totalVotesForEarnInterestVotes)
            } ?? []

            console.output("| Distributing earned interest to these eligble cards...")
            earnedInterestVoteChoicesAndVotes.forEach { (characteristic, percent) in
                let valueAwardedThisRound = accruedInterest
                console.output("| \(percent * 100.0)% to: \(characteristic)".consoleText())

                allEligibleCards.forEach { card in
                    switch characteristic {
                    case .level(let level): 
                        if level == card.level {
                            card.value += percent * valueAwardedThisRound
                        }
                    case .color(let color):
                        if color == card.color {
                            card.value += percent * valueAwardedThisRound
                        }
                    case .pip(let pip):
                        if pip == card.pip {
                            card.value += percent * valueAwardedThisRound
                        }
                    case .unknown: ()
                    }
                }
            }

            let totalVotesForIncreasePowerVotes = group["increaseVotingPower"]?.reduce(0) { result, next in
                result + Double(next.votes)
            } ?? 0

            let increaseVoteChoicesAndVotes = group["increaseVotingPower"]?.map {
                ($0.proposal.characteristic, Double($0.votes) / totalVotesForIncreasePowerVotes)
            } ?? []

            console.output("| Increasing exp. points to these eligble cards...")
            increaseVoteChoicesAndVotes.forEach { (characteristic, percent) in
                let valueAwardedThisRound = gameSession.valueAwardedEachRound
                console.output("| \(percent * 100)% to: \(characteristic)".consoleText())

                allEligibleCards.forEach { card in
                    switch characteristic {
                    case .level(let level): 
                        if level == card.level {
                            card.points += percent * valueAwardedThisRound
                        }
                    case .color(let color):
                        if color == card.color {
                            card.points += percent * valueAwardedThisRound
                        }
                    case .pip(let pip):
                        if pip == card.pip {
                            card.points += percent * valueAwardedThisRound
                        }
                    case .unknown: ()
                    }
                }
            }

            console.output("| ----------------------------------------")
            console.output("|> Resulting cards:")
            votingRound.ballots
                .compactMap { $0.playerSession.player }
                .forEach {
                    console.output("| \($0.name!)")
                    $0.cards
                        .filter { $0.state == .playable }
                        .sorted(by: <)
                        .forEach {
                            console.output("""
                            - \($0.asPip) [lvl: \($0.level); xp: \($0.points); val.: \($0.value)]
                            """.consoleText())
                        }
                }

            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            _ = console.confirm("Press 'any' to continue")
            // console.clear(.screen)
            // usleep(150000)
        } while gameSession.completedRounds < numberOfRounds

        gameSession.stop(on: &gameServer)
         */
    }
}

extension PlayCommand {
    @discardableResult
    fileprivate func markRandomChoice(
              on ballot: inout VotingRound.Ballot,
        withVotes votes: Int? = nil) throws -> VotingRound.Choice
    {
        let choice: VotingRound.Choice = .random(withVotes: votes ?? ballot.availableVotes, levelCap: ballot.highestCardLevel)
        try ballot.mark(choice: choice)
        return choice
    }
}
