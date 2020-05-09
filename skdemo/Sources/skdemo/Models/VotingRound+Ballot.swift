import Foundation

extension VotingRound {
    class Ballot: Identifiable, Codable {
        struct Result: Codable {

        }

        enum Error: Swift.Error {
            case insufficentVotes
        }

        enum State: String, Codable {
            case incomplete
            case finalized
        }

        init(playerSession: PlayerSession) {
            self.playerSession = playerSession
        }

        private(set) var id: UUID = UUID()
        private(set) var playerSession: PlayerSession
        private(set) var state: State = .incomplete
        private(set) var choices: [Choice] = []

        var castedVotes: Int {
            choices.reduce(0) { result, next in
                result + next.votes
            }
        }

        var availableVotes: Int {
            (playerSession.player?.votes ?? 0) - castedVotes
        }

        @discardableResult
        func mark(choice: Choice) throws -> Choice {
            guard availableVotes - choice.votes >= 0 else {
                throw Error.insufficentVotes
            }
            self.choices.append(choice)
            return choice
        }

        func finalize() -> Result {
            defer { self.state = .finalized }
            /// Each player needs to update burned cards
            self.playerSession.player?.update()
            return Result()
        }
        
        var highestCardLevel: Int {
            playerSession.player?.cards.sorted(by: >).first?.level ?? 0
        }
    }
}
