import Foundation
import ConsoleKit
class VotingRoundController: BaseController {
    // MARK: Initialization
    init(with context: AppContext, votingRound: VotingRound) {
        self.votingRound = votingRound
        super.init(with: context)
    }
    
    // MARK: Properties (Private)
    fileprivate var votingRound: VotingRound
    private var amounts: (Double, Double) = (0, 0)

    func drawBanner() {
        self.console.output("""
            - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            | ROUND ID: \(self.votingRound.id)
            - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            """.consoleText(.warning))
    }

    // MARK: Overrides
    override func start() {
        defer {
            self.pop()
        }
        
        defer { self.console.popEphemeral() }
        self.console.pushEphemeral()
        
        self.drawBanner()
        
        self.console.pushEphemeral()
        self.autoBuyCards()
        self.console.popEphemeral()
        
        self.amounts = calculateAccruedInterest()

        self.votingRound.ballots.forEach {
            guard !$0.isBot else {
                let votes  = Int.random(in: 1...$0.availableVotes)
                let _      = try? $0.mark(choice: .random(withVotes: votes, levelCap: $0.highestCardLevel))
                return
            }
            
            defer { console.popEphemeral()}
            console.pushEphemeral()
            
            self.push(child: BallotController(with: context, votingRound: self.votingRound, displayAmounts: { self.draw(in: $0, accruedInterest: self.amounts.0, principleAmount: self.amounts.1) }, ballot: $0))
        }
        
        console.output("|> Finalizing Round #\(votingRound.id):".consoleText(.info))
        drawCalculatedVotingPower()
        drawCalculatedEarnedInterest(amounts.0)
        if votingRound.burnedValue > 0 {
            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            console.output("|> Burned Value : \(String(format: "%.4f", votingRound.burnedValue))".consoleText(.info))
            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        }

        _ = self.console.ask("Press 'any' key...")
    }
    
    private func autoBuyCards() {
        var didDealCards = false
        self.dealCards { player, cards in
            didDealCards = true
            self.console.output("|> \(player.name ?? player.id.description) received:\t\(cards.count) cards".consoleText(.info))
        }
        
        if didDealCards {
            _ = self.console.ask("Press 'any' key...")
        }
    }

    private func dealCards(_ callback: ((Player, [Card]) -> Void)? = nil) {
        for player in votingRound.ballots
            .compactMap({ $0.playerSession })
            .compactMap({ $0.player }) {
                var dealACard = true
                var cardsDealt = [Card]()
                while dealACard {
                    let card  = Card()
                    
                    if player.isBot {
                        dealACard = player.receive(card)
                    } else if context.signature.autoBuys {
                        dealACard = player.receive(card)
                    } else {
                        dealACard = false
                    }

                    if dealACard {
                        cardsDealt.append(card)
                    }
                }

                if cardsDealt.count > 0 {
                    callback?(player, cardsDealt)
                }
        }
    }

    private func calculateAccruedInterest() -> (Double, Double) {
        /// FIXME: This is a **HUGE** hack :(
        guard let gameSession = GameServer.shared.gameSessions.first else {
            return (0.0, 0.0)
        }
        
        let interestRate    = gameSession.settings.interestRate
        let frequency       = gameSession.settings.compoundFrequency
        let accruedInterest = gameSession.accrueInterest(atRate: interestRate, occuring: frequency)

        return (accruedInterest, gameSession.principleAmount)
    }
    
    private func draw(in console: Console, accruedInterest: Double, principleAmount: Double) {
        console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        console.output("|> Interest Accrued : \(String(format: "%.4f", accruedInterest))".consoleText(.info))
        console.output("|> New Principle    : \(String(format: "%.4f", principleAmount))".consoleText(.info))
        console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
    }

    private func drawCalculatedEarnedInterest(_ accruedInterest: Double) {
        console
            .output("|> Distributing \(String(format: "%.2f", accruedInterest)) ETH to these eligible cards..."
            .consoleText(.info))
        
        choicesRatio(inFavorOf: "earnInterest")
            .sorted(by: { (arg0, arg1) in arg0.value > arg1.value })
            .forEach { (characteristic, percent) in
            let cardsMatching = votingRound.playableCards.filter { card in
                switch characteristic {
                case .level(let level) : if level == card.level { return true}
                case .color(let color) : if color == card.color { return true }
                case .pip(let pip)     : if pip == card.pip { return true }
                default                : return false
                }
                
                return false
            }
            
            guard cardsMatching.count > 0 else {
                return
            }
            
            let percentString = String(format: "%.2f", percent * 100.0)
            let reward = (percent * accruedInterest) / Double(cardsMatching.count)
            console.output("|>\t- \(percentString)%:\t\"\(characteristic)\" has \(cardsMatching.count) eligible cards (+\(String(format: "%.6f", reward)) ETH ea.)".consoleText())

            cardsMatching.forEach { card in
                card.value += reward
            }
        }
    }
    
    private func drawCalculatedVotingPower() {
        console
            .output("|> Increasing exp. points to these eligible cards..."
            .consoleText(.info))
        
        /// FIXME: This is a **HUGE** hack :(
        guard let valueAwardedThisRound = GameServer.shared.gameSessions.first?.settings.xpAwardAmount else {
            return
        }

        choicesRatio(inFavorOf: "increaseVotingPower")
            .sorted(by: { (arg0, arg1) in arg0.value > arg1.value })
            .forEach { (characteristic, percent) in
            let cardsMatching = votingRound.playableCards.filter { card in
                switch characteristic {
                    case .level(let level) : if level == card.level { return true}
                    case .color(let color) : if color == card.color { return true }
                    case .pip(let pip)     : if pip == card.pip { return true }
                    default                : return false
                }
                
                return false
            }
            
            guard cardsMatching.count > 0 else {
                return
            }
            
            let percentString = String(format: "%.2f", percent * 100.0)
            let reward = (percent * valueAwardedThisRound)
            console.output("|>\t- \(percentString)%:\t\"\(characteristic)\" has \(cardsMatching.count) eligible cards (+\(percentString) XP ea.)".consoleText())
            cardsMatching.forEach { card in
                card.points += reward
            }
        }
    }
}

extension VotingRoundController {
    var allBallotChoices: [VotingRound.Choice] {
        votingRound.ballots.flatMap { $0.choices }
    }
    
    fileprivate var votesFromAllEligibleCards: [String: [VotingRound.Choice]] {
        Dictionary(grouping: allBallotChoices, by: { $0.proposal.label })
    }
    
    fileprivate var votesInFavorOfEarningInterest: Int {
        choices(inFavorOf: "earnInterest").reduce(0) { result, next in
            result + next.votes
        }
    }
    
    fileprivate var votesInFavorOfIncreasedVotingPower: Int {
        choices(inFavorOf: "increaseVotingPower").reduce(0) { result, next in
            result + next.votes
        }
    }
    
    fileprivate func choices(inFavorOf proposal: String) -> [VotingRound.Choice] {
        votesFromAllEligibleCards[proposal] ?? []
    }
    
    fileprivate func choicesGrouped(inFavorOf proposal: String) -> [VotingRound.Proposal.Characteristic : [VotingRound.Choice]] {
        var totalVotesInFavor: Int = 0
        switch proposal {
            case "earnInterest"        : totalVotesInFavor = votesInFavorOfEarningInterest
            case "increaseVotingPower" : totalVotesInFavor = votesInFavorOfIncreasedVotingPower
            default: ()
        }
        
        guard totalVotesInFavor > 0 else {
            return [:]
        }
        
        return Dictionary(grouping: choices(inFavorOf: proposal), by: { $0.proposal.characteristic })
    }

    fileprivate func choicesRatio(inFavorOf proposal: String) -> [VotingRound.Proposal.Characteristic : Double] {
        var totalVotesInFavor: Int = 0
        switch proposal {
            case "earnInterest"        : totalVotesInFavor = votesInFavorOfEarningInterest
            case "increaseVotingPower" : totalVotesInFavor = votesInFavorOfIncreasedVotingPower
            default: ()
        }
        
        guard totalVotesInFavor > 0 else {
            return [:]
        }
        
        return Dictionary(grouping: choices(inFavorOf: proposal), by: { $0.proposal.characteristic })
            .mapValues({ choices in
                choices.reduce(0.0) { result, next in
                    result + Double(next.votes) / Double(totalVotesInFavor)
                }
            })
    }
}

extension VotingRoundController {
    fileprivate func draw(title: String) {
        console.output("|> \(String(repeating: "-", count: title.count))".consoleText(.warning))
        console.output(title.consoleText(.warning))
        console.output("|> \(String(repeating: "-", count: title.count))".consoleText(.warning))
        console.output("\n")
    }
}


fileprivate func display(in console: Console, card: Card, playerName name: String) {
    console
        .output("|> \(String(repeating: "- ", count: name.count + 20))"
            .consoleText(color: .brightYellow))
    console
        .output("|> \(name) received:"
            .consoleText(.info))
    console
        .output("|> \(String(repeating: "- ", count: name.count + 20))"
            .consoleText(color: .brightYellow))
    console
        .output(card.consoleText)
}

final class BallotController: BaseController {
    enum MenuChoice: String {
        case auto      = ""
        case viewCards = "View Cards"
        case burnCard  = "Burn Card"
        case buyACard  = "Buy a Card"
        case vote      = "Vote"
        
        static let allMenuChoices: [MenuChoice] = [
            .viewCards, .burnCard, .buyACard, .vote
        ]
    }
    
    init(with context: AppContext, votingRound: VotingRound, displayAmounts: ((Console) -> ())? = nil, ballot: VotingRound.Ballot) {
        self.displayAmounts = displayAmounts
        self.votingRound = votingRound
        self.ballot      = ballot
        super.init(with: context)
    }

    // MARK: Properties (Private)
    private let votingRound: VotingRound
    private var ballot: VotingRound.Ballot
    private var player: Player! { ballot.playerSession.player! }
    private var displayAmounts: ((Console) -> ())?

    func drawTurn(forPlayer player: Player) {
        let name = player.name ?? player.id.description
        let bank = String(format: "%.5f", player.bankRoll)
        let vals = String(format: "%.5f", player.totalCardValue)
        let hand = ballot.cardsPlayable
        let high = ballot.highestCard != nil ? "Highest: " + (ballot.highestCard?.consoleTextShort ?? "") : ""

        console
            .output("|> \(String(repeating: "- ", count: name.count + 20))"
            .consoleText(color: .brightYellow))
        console
            .output("|> \(name)'s turn:"
            .consoleText(.info))
        console
            .output("|> \(String(repeating: "- ", count: name.count + 20))"
                .consoleText(color: .brightYellow))
        console
            .output("|> Cards: \(hand.count) ct.\t".consoleText(.info) + high)
        console
            .output("|> Votes: \(ballot.availableVotes)"
            .consoleText(.info))
        console
            .output("|> Bank : \(bank) ETH"
            .consoleText(.info))
        console
            .output("|> Value: \(vals) ETH"
            .consoleText(.info))
        console
            .output("|> \(String(repeating: "- ", count: name.count + 20))"
            .consoleText(color: .brightYellow))
    }
    
    func drawBankRoll(forPlayer player: Player) {
        let bank = String(format: "%.2f", player.bankRoll)
        console.output("|> Bank : \(bank) ETH" .consoleText(.info))
    }
    
    func drawValue(forPlayer player: Player) {
        let vals = String(format: "%.2f", player.totalCardValue)
        console.output("|> Value: \(vals) ETH".consoleText(.info))
    }

    // MARK: Overrides
    override func start() {
        defer {
            self.pop()
        }
        
        defer { self.console.popEphemeral() }
        self.console.pushEphemeral()
        
        if ballot.playerCards.isEmpty {
            player.receive(Card())
        }
        
        while ballot.availableVotes > 0 {
            defer { self.console.popEphemeral() }
            self.console.pushEphemeral()
            
            // Show top-level stats
            //------------------------------------------------------------------
            if !player.isBot {
                self.displayAmounts?(self.console)
                drawCardStatistics(in: console, cardSet: self.votingRound.playableCards)
                self.drawTurn(forPlayer: player)
            }
            
            switch self.drawMenuChoices(for: player) {
            // Buy a card
            //------------------------------------------------------------------
            case .buyACard:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                let card = Card()
                guard self.player.receive(card) else {
                    console.error("|> Insufficient funds")
                    continue
                }

                display(        in: self.console,
                              card: card,
                        playerName: player.name ?? player.id.description)
                _ = console.ask("Press 'any' key...")
            // View cards
            //------------------------------------------------------------------
            case .viewCards:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                self.console.clear(.screen)

                drawCardStatistics(in: console, cardSet: ballot.playerCards.filter { $0.state == .playable})
                drawCardsInHand(for: player)
                
                _ = console.ask("Press 'any' key...")
            // Burn a card
            //------------------------------------------------------------------
            case .burnCard:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                drawCardsInHand(for: player)

                console.ask("Which card? (comma-separated)")
                    .components(separatedBy: ", ")
                    .compactMap(Int.init).forEach {
                        burnCard(atIndex: $0, forPlayer: player)
                }
                _ = console.ask("Press 'any' key...")
            // Vote for proposals
            //------------------------------------------------------------------
            case .vote:
                let choices = """
                |----------------------------------------------------|
                |                PLEASE MAKE A CHOICE                |
                |----------------------------------------------------|
                |     Earn Interest      |   Increate Voting Power   |
                | ---------------------  | ------------------------- |
                | A0) Reds     A2) White | B0) Reds     B2) White    |
                | A1) Magenta  A3) Green | B1) Magenta  B3) Green    |
                |                        |                           |
                | A4) All Hearts         | B4) All Hearts            |
                | A5) All Spades         | B5) All Spades            |
                | A6) All Clubs          | B6) All Clubs             |
                | A7) All Diamonds       | B7) All Diamonds          |
                |                        |                           |
                | A8) Specific Level     |                           |
                |----------------------------------------------------|
                """

                while ballot.availableVotes > 0 {
                    defer { self.console.popEphemeral() }
                    self.console.pushEphemeral()
                    
                    console.output(choices.consoleText(.warning))
                    console.output("|> Votes Remaining: \(ballot.availableVotes)".consoleText(.info))
                    drawCardsInHand(for: player)
                    
                    guard let votes = Int(console.ask("How many votes?")) else {
                        break
                    }
                    
                    var choice: VotingRound.Choice!
                    switch console.ask("Which choice?", isSecure: true).uppercased() {
                        case "A0": choice = VotingRound.Choice(proposal: .earnInterest(on: .color(.red)), votes: votes)
                        case "A1": choice = VotingRound.Choice(proposal: .earnInterest(on: .color(.magenta)), votes: votes)
                        case "A2": choice = VotingRound.Choice(proposal: .earnInterest(on: .color(.white)), votes: votes)
                        case "A3": choice = VotingRound.Choice(proposal: .earnInterest(on: .color(.green)), votes: votes)
                        case "A4": choice = VotingRound.Choice(proposal: .earnInterest(on: .pip(.hearts)), votes: votes)
                        case "A5": choice = VotingRound.Choice(proposal: .earnInterest(on: .pip(.spades)), votes: votes)
                        case "A6": choice = VotingRound.Choice(proposal: .earnInterest(on: .pip(.clubs)), votes: votes)
                        case "A7": choice = VotingRound.Choice(proposal: .earnInterest(on: .pip(.diamonds)), votes: votes)
                        case "A8":
                            let level = Int(console.ask("Level:"))!
                            choice = VotingRound.Choice(proposal: .earnInterest(on: .level(level)), votes: votes)
                        case "B0": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .color(.red)), votes: votes)
                        case "B1": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .color(.magenta)), votes: votes)
                        case "B2": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .color(.white)), votes: votes)
                        case "B3": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .color(.green)), votes: votes)
                        case "B4": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .pip(.hearts)), votes: votes)
                        case "B5": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .pip(.spades)), votes: votes)
                        case "B6": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .pip(.clubs)), votes: votes)
                        case "B7": choice = VotingRound.Choice(proposal: .increaseVotingPower(for: .pip(.diamonds)), votes: votes)
                        default: ()
                    }
                    do {
                        guard let choice = choice else {
                            continue
                        }
                        try ballot.mark(choice: choice)
                    } catch {
                        console.error("\(error)")
                    }
                }
            // Auto (BOT)
            //------------------------------------------------------------------
            case .auto:
                let votes = Int.random(in: 1...ballot.availableVotes)
                let _     = try? ballot.mark(choice: .random(withVotes: votes, levelCap: ballot.highestCardLevel))
            }
        }
    }
    
    private func drawCardsInHand(for player: Player) {
        ballot
            .playerCards
            .enumerated().forEach {
            console.output(
                    "|> \($0.1.state == .burned ? "🔥" : "\($0.0):") ".consoleText() +
                    "\($0.1.asPipAndLevel) ".consoleText(color: $0.1.color.consoleColor) +
                    "\t\(String(format: "%.5f", $0.1.value)) ETH".consoleText(.plain) +
                    "\t\(String(format: "%.5f", $0.1.points)) XP".consoleText(.plain)
            )
        }
    }

    private func burnCard(atIndex index: Int, forPlayer player: Player) {
        let card = ballot.playerCards[index]

        guard card.level > 0 else {
            console.error("|> Cannot burn a 'Level 0' card!")
            return
        }
        card.burn()
        
        let beginning = "|> \(player.name!) has burned #\(index) (".consoleText(color: .white)
        let middle = "\(card.pip.asPip)".consoleText(color: card.color.consoleColor)
        let end = ") for \(card.votes) votes!".consoleText(color: .white)
        console.output(beginning + middle + end)
    }

    private func drawMenuChoices(for player: Player) -> MenuChoice {
        guard player.isBot == false else {
            return .auto
        }
        
        let menuChoices = MenuChoice.allMenuChoices.map { $0.rawValue }
        let answer      = console.choose("|> ROUND ACTIONS".consoleText(.info), from: menuChoices)
        
        return MenuChoice(rawValue: answer) ?? .auto
    }
}
