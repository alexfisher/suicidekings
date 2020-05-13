extension VotingRound {
    public struct Choice: Codable {
        public init(proposal: Proposal, votes: Int) {
            self.proposal = proposal
            self.votes = votes
        }

        public private(set) var proposal: Proposal
        public private(set) var votes: Int

        public static func random(withVotes votes: Int, levelCap: Int) -> Choice {
            .init(proposal: .random(levelCap: levelCap), votes: votes)
        }
    }
}
