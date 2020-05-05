import Foundation
import ConsoleKit

struct AutoplayCommand: Command {
    struct Signature: CommandSignature {
        @Option(name: "name", short: "r", help: "Sets the player name. Defaults to 10")
        var rounds: Int?
    }

    var help: String = "Plays an automated game of \"Suicide Kings\""

    func run(using context: CommandContext, signature: Signature) throws {
        let console = context.console
        defer {
            console.output("")
        }

        console.output("""
        - - - - - - - - - - - - - - - -
         ♔ Welcome to Suicide Kings ♔
        - - - - - - - - - - - - - - - -
        + Autoplay Mode
        + v0.0.1
        - - - - - - - - - - - - - - - -

        """.consoleText(color: .brightYellow))

        var gameServer = GameServer.shared
        gameServer.add(Player(name: "kevin"))
        gameServer.add(Player(name: "wade"))
        gameServer.add(Player(name: "alex"))

        /// High-Level game loop
        /// 0. Create new session
        let gameSession = GameSession(startingAmount: 1_000, valueAwardedEachRound: 100.0)
        gameSession.start(on: &gameServer)

        repeat {
            print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            /// Start the voting round
            /// 1. Add all players to the current game session
            print("| Waiting for more players to join...")
            gameSession.join(players: gameServer.players)

            print("| All player have joined. Preparing voting round...")
            print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")

            /// Deal cards to players
            print("| Dealing 1 card to all ...")
            gameSession.dealCards()

            gameSession
                .playerSessions
                .compactMap { $0.player }
                .forEach { player in
                    print("\(player.name!) received:")
                    print(player.cards.last!)
            }

            print("| Cards dealt. Calculating latest interest accrual...")

            print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            let interestRate = 5.0
            let frequency    = 3.0
            let unitOfTime   = 1
            print("""
            | .: COMPUTING INTEREST CALCULATION :.
            | Current Value Amount :  \(gameSession.principleAmount) ETH
            | Interest Rate        :  \(interestRate)%
            | Accrual Frequency    :  \(frequency)
            | Within Unit of Time  :  \(unitOfTime) (assuming 24hrs)
            """)

            let accruedInterest = gameSession.accrueInterest(atRate: interestRate, occuring: frequency)
            print("| Interest Accrued: \(accruedInterest)")

            print("| Interest compounded. Opening round for voting...")

            /// 3. Create voting round
            /// 3a. Create ballots for each player
            /// 3b. Open the round for voting
            guard var votingRound = gameSession.beginVoting() else {
                break
            }

            print("----------------------------------------")
            print("| Voting Round: #\(votingRound.id) has started...")
            print("----------------------------------------")

            /// 4. Cast votes
            votingRound.ballots.forEach {
                var ballot = $0
                guard let player = ballot.playerSession.player else {
                    print("> WARNING: \(#line)")
                    return
                }

                print( """
                | Casting Votes for : \(player.id)
                | Name              : \"\(player.name ?? "")\"
                | Available Votes   : \(player.votes)
                """)

                /*
                if votingRound.id >= 2 && player.name == "kevin" {
                    var card: Card!
                    card.burn()
                    print(card!)
                    print("| \(player.name!) has burned a card for \(card.votes) votes! (\(card.id)")
                }
                */

								let choiceString = """
								|-------------------------------------------------|
								|                  MAKE A CHOICE                  |
								|-------------------------------------------------|
								|   Earn Interest     |   Increate Voting Power   |
								| -----------------   | ------------------------- |
								| A0) All Reds	      | B0) All Reds              |
								| A1) All Blacks      | B1) All Blacks            |
								| A2) All Hearts      | B2) All Hearts            |
								| A3) All Spades      | B3) All Spades            |
								| A4) All Clubs       | B4) All Clubs             |
								| A5) All Diamonds    | B5) All Diamonds          |
								|                     |                           |
								| A6) Specific Level  |                           |
								|-------------------------------------------------|
								"""
								console.output(choiceString.consoleText(.info))

                print("> Casting votes ============================== <")
                do {
                    while ballot.availableVotes > 0 {
										console.output("VOTES REMAINING: \(ballot.availableVotes)".consoleText(.info))
										let votes = Int(console.ask("How many votes?"))!
										var choice: VotingRound.Choice!
												switch console.ask("Which choice?").uppercased() {
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
                        print("| Random choice     : \(choice.votes) vote(s) -> \(choice.proposal)")
                        print("|  - Votes Remaining:", ballot.availableVotes)
                    }
                }
                catch {
                    print(error)
                }
                print("> ============================================ <")



								if false {
										print("> Casting votes ============================== <")
										do {
												while ballot.availableVotes > 0 {
														let choice = try markRandomChoice(on: &ballot, withVotes: .random(in: 1...ballot.availableVotes))
														print("| Random choice     : \(choice.votes) vote(s) -> \(choice.proposal)")
														print("|  - Votes Remaining:", ballot.availableVotes)
												}
										}
										catch {
												print(error)
										}
										print("> ============================================ <")
								}
            }

            print("Closing Round #\(votingRound.id)")
            gameSession.end(votingRound: &votingRound)

            let allEligibleCards = votingRound.ballots
                .compactMap { $0.playerSession.player?.cards }
                .flatMap { $0 }
                .filter { $0.state == .playable }
            
            let allBallotChoices = votingRound.ballots
                .flatMap { $0.choices }

            let group = Dictionary<String, [VotingRound.Choice]>(grouping: allBallotChoices, by: { $0.proposal.label })
            print(group as AnyObject)

            let totalVotesForIncreasePowerVotes = group["increaseVotingPower"]?.reduce(0) { result, next in
                result + Double(next.votes)
            } ?? 0

            let choicesAndVotes = group["increaseVotingPower"]?.map {
                ($0.proposal.characteristic, Double($0.votes) / totalVotesForIncreasePowerVotes)
            } ?? []

            print("| Increasing exp. points to these eligble cards...")
            choicesAndVotes.forEach { (characteristic, percent) in
                let valueAwardedThisRound = gameSession.valueAwardedEachRound
                print("| \(percent * 100)% to: \(characteristic)")

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

            print("----------------------------------------")
            print("| Resulting cards:")
            votingRound.ballots
                .compactMap { $0.playerSession.player }
                .forEach {
                    print("| \($0.name!)")
                    $0.cards
                        .filter { $0.state == .playable }
                        .sorted(by: <)
                        .forEach {
                            print(" -", $0.pip.display(color: $0.color), "@ LVL \($0.level) (xp: \($0.points))")
                        }
                }

        } while gameSession.completedRounds < 15

        gameSession.stop(on: &gameServer)
    }
}

extension AutoplayCommand {
    @discardableResult
    fileprivate func markRandomChoice(
              on ballot: inout VotingRound.Ballot,
        withVotes votes: Int? = nil) throws -> VotingRound.Choice
    {
        let choice: VotingRound.Choice = .random(withVotes: votes ?? ballot.availableVotes)
        try ballot.mark(choice: choice)
        return choice
    }
}
