extension VotingRound {
    struct Choice: Codable {
        init(proposal: Proposal, votes: Int) {
            self.proposal = proposal
            self.votes = votes
        }

        private(set) var proposal: Proposal
        private(set) var votes: Int

        static func random(withVotes votes: Int, levelCap: Int) -> Choice {
            .init(proposal: .random(levelCap: levelCap), votes: votes)
        }
    }
}
