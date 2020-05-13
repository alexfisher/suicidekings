import Foundation
import ConsoleKit
class VotingRoundController: BaseController, BallotControllerDelegate {
    // MARK: Initialization
    init(with context: AppContext, votingRound: VotingRound) {
        self.votingRound = votingRound
        super.init(with: context)
    }
    
    // MARK: Properties (Private)
    fileprivate var votingRound: VotingRound
    private var amounts: (Double, Double) = (0, 0)

    // MARK: Overrides
    override func start() {
        defer {
            self.pop()
        }
        
        defer { self.console.popEphemeral() }
        self.console.pushEphemeral()
        
        self.dealFirstRoundCards()
        self.autoBuyCards()
        
        self.console.clear(.screen)
        
        self.amounts = calculateAccruedInterest()

        self.votingRound.ballots.forEach {
            defer { self.console.popEphemeral() }
            self.console.pushEphemeral()
            
            self.push(child: BallotController(with: context, ballot: $0, delegate: self))
        }
        
        console.output("|> Finalizing Round #\(votingRound.id):".consoleText(.info))
        drawCalculatedEarnedInterest(amounts.0)
        drawCalculatedVotingPower()
        drawBurntCardValue()

        _ = self.console.ask("Press 'any' key...")
    }
    
    func controllerWillAppear(_ controller: BallotController) {
        self.console.output("""
            | ROUND #\(self.votingRound.id)
            - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            """.consoleText(color: .brightWhite))
        
        draw(in: controller.console, accruedInterest: self.amounts.0, principleAmount: self.amounts.1)

        self.console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            .consoleText(color: .brightWhite))
    }
    
    func controllerWillViewAllCards(_ controller: BallotController) {
        drawCardStatistics(in: controller.console, title: "ALL CARDS", cardSet: self.votingRound.playableCards)
        
        self.console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            .consoleText(color: .brightWhite))
        
        _ = controller.console.ask("Press 'any' key...")
    }
    
    private func dealFirstRoundCards() {
        if self.votingRound.id == 0, let cardsToStart = self.context.signature.cardsToStart, cardsToStart > 0 {
            self.votingRound.ballots.forEach { ballot in
                guard let player = ballot.playerSession.player else {
                    return
                }
                var card: Card?
                repeat {
                    card = ballot.playerSession.draw()
                } while (player.cards.count < cardsToStart) || card == nil
            }
        }
    }
    
    private func drawBurntCardValue() {
        let burntThisRound = votingRound
            .ballots
            .flatMap { $0.burntCards }
            .reduce(0.0) { result, next in
                result + next.value
        }
        if burntThisRound > 0 {
            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
            console.output("|> Deposits Returned This Round: \(String(format: "%.4f", burntThisRound))".consoleText(.info))
            console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        }
    }
    
    private func autoBuyCards() {
        defer { self.console.popEphemeral() }
        self.console.pushEphemeral()
        
        var didDealCards = false
        self.votingRound.ballots.forEach { ballot in
            guard let player = ballot.playerSession.player else {
                return
            }

            var cards = [Card]()
            
            switch (context.signature.autoBuys, player.isBot) {
                case (_,      true) : fallthrough
                case (true,  false) : cards = ballot.playerSession.autoDraw()
                default: break
            }
            
            if cards.count > 0 && !player.isBot {
                didDealCards = true
                self.console.output("|> \(player.name ?? player.id.description) received:\t\(cards.count) cards".consoleText(.info))
            }
        }

        if didDealCards {
            _ = self.console.ask("Press 'any' key...")
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
        // console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        console.output("|> Interest Accrued : \(String(format: "%.4f", accruedInterest))".consoleText(.info))
        console.output("|> New Principle    : \(String(format: "%.4f", principleAmount))".consoleText(.info))
        // console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
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
            let rewardString = String(format: "%.2f", reward)
            console.output("|>\t- \(percentString)%:\t\"\(characteristic)\" has \(cardsMatching.count) eligible cards (+\(rewardString) XP ea.)".consoleText())
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

protocol BallotControllerDelegate: class {
    func controllerWillAppear(_ controller: BallotController)
    func controllerWillViewAllCards(_ controller: BallotController)
}

final class BallotController: BaseController {
    enum MenuChoice: String {
        case auto      = ""
        case viewHand  = "View My Cards"
        case viewCards = "View All Cards"
        case burnCard  = "Burn Card"
        case buyACard  = "Buy a Card"
        case vote      = "Vote"
        
        static let allMenuChoices: [MenuChoice] = [
            .viewHand, .viewCards, .burnCard, .buyACard, .vote
        ]
    }
    
    init(with context: AppContext, ballot: VotingRound.Ballot, delegate: BallotControllerDelegate? = nil) {
        self.ballot   = ballot
        self.delegate = delegate
        super.init(with: context)
    }
    
    // MARK: Properties (Private)
    private weak var delegate: BallotControllerDelegate?
    public private(set) var ballot: VotingRound.Ballot
    private var player: Player! { ballot.playerSession.player! }

    func drawTurn(forPlayer player: Player) {
        let name = (player.name ?? player.id.description).uppercased()
        let bank = String(format: "%.5f", player.bankRoll)
        let vals = String(format: "%.5f", player.totalCardValue)
        let hand = ballot.cardsPlayable
        let high = ballot.highestCard != nil ? "Highest: " + (ballot.highestCard?.consoleTextShort ?? "") : ""

        /*
        console
            .output("|> \(String(repeating: "- ", count: name.count + 20))"
            .consoleText(color: .brightYellow))
         */
        
        var output: ConsoleText = "\n"
        output += "| \(name)'s turn:\n".consoleText(color: .brightWhite)
        output += "|  - Cards: ".consoleText(color: .brightBlack) +
                "\(hand.count) ct.\t".consoleText(color: .brightWhite) +
                high + "\n"
        output += "|  - Votes: ".consoleText(color: .brightBlack) +
                "\(ballot.availableVotes)\n".consoleText(color: .brightWhite)
        output += "|  - Bank : ".consoleText(color: .brightBlack) +
                "\(bank) ETH\n".consoleText(color: .brightWhite)
        output += "|  - Value: ".consoleText(color: .brightBlack) +
                "\(vals) ETH\n".consoleText(color: .brightWhite)
        
        console.output(output)

        /*
        console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            .consoleText(color: .brightWhite))
         */
        

        drawCardStatistics(in: console, title: "YOUR CARDS", cardSet: ballot.cardsPlayable)
        
        self.console.output("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
            .consoleText(color: .brightWhite))
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
        
        guard !self.ballot.isBot else {
            self.ballot.playerSession.autoDraw()
            try! self.ballot.autoVote()
            return
        }
        
        while ballot.canVote {
            defer { self.console.popEphemeral() }
            self.console.pushEphemeral()
            
            // Show top-level stats
            //------------------------------------------------------------------
            self.delegate?.controllerWillAppear(self)
            self.drawTurn(forPlayer: player)

            switch self.drawMenuChoices(for: player) {
            // Buy a card
            //------------------------------------------------------------------
            case .buyACard:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                guard let card = ballot.playerSession.draw() else {
                    console.error("|> Insufficient funds")
                    continue
                }

                display(        in: self.console,
                              card: card,
                        playerName: player.name ?? player.id.description)
                _ = console.ask("Press 'any' key...")
            // View cards
            //------------------------------------------------------------------
            case .viewHand:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                self.drawCardsInHand(for: player)
                _ = console.ask("Press 'any' key...")

            case .viewCards:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                self.delegate?.controllerWillViewAllCards(self)
                
                // self.console.clear(.screen)

                // drawCardStatistics(in: console, cardSet: ballot.playerCards.filter { $0.state == .playable})
                // drawCardsInHand(for: player)
                
                // _ = console.ask("Press 'any' key...")
            // Burn a card
            //------------------------------------------------------------------
            case .burnCard:
                defer { self.console.popEphemeral() }
                self.console.pushEphemeral()
                
                drawCardsInHand(for: player)

                console
                    .ask("Burn which cards? (comma-separated)")
                    .components(separatedBy: ", ")
                    .compactMap(Int.init)
                    .map { (self.ballot.playerCards[$0], $0) }
                    .forEach { (card: Card?, index: Int) in
                        guard let card = card else {
                            return
                        }
                        self.burnCard(card, atIndex: index, forPlayer: player)
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
                let indexText  = $0.1.state == .burned ? "🔥" : "#\($0.0)"
                let levelText  = "\(indexText)  LVL \($0.1.level)"
                let idxPadding = String(repeating: " ", count: max(2, (6 - (indexText.count + levelText.count))))
                
                let pipText  = "\($0.element.pip.description) (\($0.element.color.rawValue) \($0.element.pip.rawValue))"
                let pipColor = $0.element.color.consoleColor
                let pipPadding = String(repeating: " ", count: max(2, (22 - pipText.count)))
                
                let valText    = "\(String(format: "%.5f", $0.1.value)) ETH"
                let valPadding = String(repeating: " ", count: max(2, (8 - valText.count)))
                
                console.output(
                    "|  - ".consoleText(color: .brightBlack)
                    + levelText.consoleText(color: .brightCyan)
                    + idxPadding.consoleText()
                    + pipText.consoleText(color: pipColor)
                    + pipPadding.consoleText()
                    + valText.consoleText(color: .brightBlack)
                    + valPadding.consoleText()
                    + "   \(String(format: "%.5f", $0.1.points)) XP".consoleText(color: .brightBlack)
                )
        }
    }

    private func burnCard(_ card: Card, atIndex index: Int, forPlayer player: Player) {
        guard card.level > 0 else {
            console.error("|> Cannot burn a 'Level 0' card!")
            return
        }
        
        guard let _ = ballot.playerSession.burn(card: card.id) else {
            return
        }
        
        ballot.burntCards.append(card)

        let beginning = "|> \(player.name!) has burned #\(index) (".consoleText(color: .white)
        let middle = "\(card.pip)".consoleText(color: card.color.consoleColor)
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
