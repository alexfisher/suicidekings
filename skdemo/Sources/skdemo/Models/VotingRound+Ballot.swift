import Foundation

extension VotingRound {
    public class Ballot: Identifiable, Codable {
        public init(playerSession: PlayerSession) {
            self.playerSession = playerSession
        }

        public enum Error: Swift.Error {
            case insufficentVotes
        }

        public enum State: String, Codable {
            case incomplete
            case finalized
        }

        public private(set) var choices       : [Choice] = []
        public private(set) var id            : UUID = UUID()
        public private(set) var playerSession : PlayerSession
        public private(set) var state         : State = .incomplete

        @CardPile(filter: .burned)
        var burntCards: [Card] = []
        
        public func autoVote() throws {
            while self.canVote {
                let votes  = Int.random(in: 1...self.availableVotes)
                let _      = try mark(choice: .random(withVotes: votes, levelCap: self.highestCardLevel))
            }
        }
        
        public var canVote: Bool {
            self.availableVotes > 0 && self.cardsPlayable.count > 0
        }

        public var castedVotes: Int {
            choices.reduce(0) { result, next in
                result + next.votes
            }
        }
        
        public var isBot: Bool {
            playerSession.player?.isBot ?? false
        }
        
        public var playerCards: [Card] {
            playerSession.player?
                .cards
                .filter({ $0.state != .discarded })
                .sorted()
                ?? []
        }
        
        public var cardsPlayable: [Card] {
            playerCards.filter { $0.state == .playable }
        }
        
        public var cardsBurned: [Card] {
            playerCards.filter { $0.state == .burned}
        }
        
        public var burnedCardsValue: Double {
            cardsBurned.reduce(0.0) { result, next in
                result + next.value
            }
        }
        
        public var availableVotes: Int {
            (playerSession.player?.votes ?? 0) - castedVotes
        }

        @discardableResult
        public func mark(choice: Choice) throws -> Choice {
            guard availableVotes - choice.votes >= 0 else {
                throw Error.insufficentVotes
            }
            self.choices.append(choice)
            return choice
        }

        public func finalize() {
            defer { self.state = .finalized }
            /// Each player needs to update burned cards
            self.playerSession.player?.discard()
        }
        
        public var highestCard: Card? {
            cardsPlayable.sorted(by: >).first
        }
        
        public var highestCardLevel: Int {
            highestCard?.level ?? 0
        }
    }
}

@propertyWrapper
public final class CardPile: Collection, Codable {
    init<S: Sequence>(wrappedValue: S, filter: Element.State) where S.Element == Card {
        self._filter = filter
        self._cards  = Array(wrappedValue)
    }
    
    private lazy var _cards: [Card] = []
    private var _filter: Card.State
    
    public var wrappedValue: [Card] {
        get { _cards.filter { $0.state == self._filter } }
        set { _cards = newValue.sorted(by: >) }
    }
    
    public var startIndex  : Int { _cards.startIndex }
    public var endIndex    : Int { _cards.endIndex   }
    
    public func index(after i: Int) -> Int {
        _cards.index(after: i)
    }
    
    public subscript(bounds: Range<Int>) -> Slice<CardPile> {
        .init(base: self, bounds: bounds)
    }
    
    public subscript(position: Int) -> Card {
        _cards[position]
    }
}

