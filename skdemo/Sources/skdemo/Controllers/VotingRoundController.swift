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
        
        self.dealCards { player, card in
            defer { self.console.popEphemeral() }
            self.console.pushEphemeral()
            
            display(in: self.console, card: card, playerName: player.name ?? player.id.description)
            
            if !player.isBot {
                _ = self.console.ask("Press 'any' key...")
            }
        }
        
        self.votingRound.ballots.forEach {
            defer { console.popEphemeral()}
            console.pushEphemeral()
            
            drawCardStatistics(in: console, cardSet: allEligibleCards)
            self.push(child: BallotController(with: context, ballot: $0))
        }
        
        self.finalize()
        _ = self.console.ask("Press 'any' key...")
    }

    private func dealCards(_ callback: ((Player, Card) -> Void)? = nil) {
        for player in votingRound.ballots
            .compactMap({ $0.playerSession })
            .compactMap({ $0.player }) {
                let card = Card()
                
                player.receive(card)
                callback?(player, card)
        }
    }
    
    private func finalize() {
        console.output("|> Finalizing Round #\(votingRound.id):".consoleText(.info))
        drawCalculatedVotingPower()
        drawCalculatedEarnedInterest(calculateAccruedInterest())
    }
    
    private func calculateAccruedInterest() -> Double {
        /// FIXME: This is a **HUGE** hack :(
        guard let gameSession = GameServer.shared.gameSessions.first else {
            return 0.0
        }
        
        let interestRate    = gameSession.settings.interestRate
        let frequency       = gameSession.settings.compoundFrequency
        let accruedInterest = gameSession.accrueInterest(atRate: interestRate, occuring: frequency)
        console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        console.output("|> Interest Accrued : \(accruedInterest)".consoleText(.info))
        console.output("|> New Principle    : \(gameSession.principleAmount)".consoleText(.info))
        console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        
        return accruedInterest
    }
    
    private func drawCalculatedEarnedInterest(_ accruedInterest: Double) {
        console.output("| Distributing earned interest to these eligble cards...")
        choicesRatio(inFavorOf: "earnInterest").forEach { (characteristic, percent) in
            let percentString = String(format: "%.2f", percent * accruedInterest)
            console.output("|\t- \(percentString)ETH \tto: \(characteristic)".consoleText())
            
            allEligibleCards
                .forEach { card in
                switch characteristic {
                    case .level(let level):
                        if level == card.level {
                            card.value += percent * accruedInterest
                    }
                    case .color(let color):
                        if color == card.color {
                            card.value += percent * accruedInterest
                    }
                    case .pip(let pip):
                        if pip == card.pip {
                            card.value += percent * accruedInterest
                    }
                    case .unknown: ()
                }
            }
        }
    }
    
    private func drawCalculatedVotingPower() {
        console.output("| Increasing exp. points to these eligble cards...")
        choicesRatio(inFavorOf: "increaseVotingPower").forEach { (characteristic, percent) in
            let valueAwardedThisRound = 100.0
            let percentString = String(format: "%.2f", percent * 100.0)
            console.output("|\t- \(percentString)XP\tto: \(characteristic)".consoleText())

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
    }
}

extension VotingRoundController {
    var allEligibleCards: [Card] {
        votingRound.ballots
            .compactMap { $0.playerSession.player?.cards }
            .flatMap { $0 }
            .filter { $0.state == .playable }
    }
    
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
        .output("|> \(String(repeating: "- ", count: name.count + 16))"
            .consoleText(color: .brightYellow))
    console
        .output("|> \(name) received:"
            .consoleText(.info))
    console
        .output("|> \(String(repeating: "- ", count: name.count + 16))"
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
    
    init(with context: AppContext, ballot: VotingRound.Ballot) {
        self.ballot = ballot
        super.init(with: context)
    }

    // MARK: Properties (Private)
    private var ballot: VotingRound.Ballot
    private var player: Player! { ballot.playerSession.player! }
    private var allEligibleCards: [Card] {
        ballot.playerSession
            .player?.cards
            .filter { $0.state == .playable }
        ?? []
    }

    func drawTurn(forPlayer player: Player) {
        let name = player.name ?? player.id.description
        let bank = String(format: "%.2f", player.bankRoll)
        let vals = String(format: "%.2f", player.totalCardValue)

        console
            .output("|> \(String(repeating: "- ", count: name.count + 16))"
            .consoleText(color: .brightYellow))
        console
            .output("|> \(name)'s turn:"
            .consoleText(.info))
        console
            .output("|> \(String(repeating: "- ", count: name.count + 16))"
                .consoleText(color: .brightYellow))
        console
            .output("|> Bank : \(bank) ETH"
                .consoleText(.info))
        console
            .output("|> Value: \(vals) ETH"
                .consoleText(.info))
        console
            .output("|> \(String(repeating: "- ", count: name.count + 16))"
            .consoleText(color: .brightYellow))
    }

    // MARK: Overrides
    override func start() {
        defer {
            self.pop()
        }
        
        defer { self.console.popEphemeral() }
        self.console.pushEphemeral()
        
        if !player.isBot {
            self.drawTurn(forPlayer: player)
        }
        
        while ballot.availableVotes > 0 {
            switch self.drawMenuChoices(for: player) {
            // Buy a card
            //------------------------------------------------------------------
            case .buyACard:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                let card = Card()
                self.player.receive(card)

                display(        in: self.console,
                              card: card,
                        playerName: player.name ?? player.id.description)
                _ = console.ask("Press 'any' key...")
            // View cards
            //------------------------------------------------------------------
            case .viewCards:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                drawCardStatistics(in: console, cardSet: allEligibleCards)
                drawCardsInHand(for: player)
                
                _ = console.ask("Press 'any' key...")
            // Burn a card
            //------------------------------------------------------------------
            case .burnCard:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                drawCardsInHand(for: player)

                let response = console.ask("Which card?")
                guard let idx = Int(response) else {
                    continue
                }

                burnCard(atIndex: idx, forPlayer: player)
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
                let votes  = Int.random(in: 1...ballot.availableVotes)
                let _      = try? ballot.mark(choice: .random(withVotes: votes, levelCap: ballot.highestCardLevel))
            }
        }
    }
    
    private func drawCardsInHand(for player: Player) {
        allEligibleCards
            .sorted(by: { (left, right) in left.pip.rawValue < right.pip.rawValue })
            .enumerated().forEach {
            console.output(
                    "|> #\($0.0): ".consoleText() +
                    "\($0.1.pip.asPip) ".consoleText(color: $0.1.color.consoleColor) +
                    "+\($0.1.votes)".consoleText() +
                    "\t\(String(format: "%.2f", $0.1.value)) ETH".consoleText(.plain) +
                    "\t\(String(format: "%.2f", $0.1.points)) XP".consoleText(.plain)
            )
        }
    }
    
    private func burnCard(atIndex index: Int, forPlayer player: Player) {
        let card = player.cards[index]
        guard card.level > 0 else {
            console.error("|> Cannot burn a 'Level 0' card!")
            return
        }
        card.burn()
        console
            .output("|> \(player.name!) has burned a card for \(card.votes) votes! (\(card.id))"
            .consoleText(color: .white))
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
