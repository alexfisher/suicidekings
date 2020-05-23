# How the game is played

## Joining the Game:
1. Players join the game by buying one or multiple Suicide King NFTs.
- If a new NFT is minted the cost of the card minus a small fee (1% or less) is placed into a community pool where it earns interest. The amount that goes into the pool is the initial backing of the NFT. Think of the NFT as a certificate of deposit which can be redeemed for its initial cost and any interest that the NFT wins.
- If the NFT is bought on a secondary market a small fee (1% or less) is donated to the community pool. Since, the NFT already has a backed amount, this fee is not added to it. However, the new owner can always redeem the initial backed amount and interest that the NFT has won.
2. There are 16 types of Suicide King NFTs. These two matrices below create their every possible combination (e.g. Red Spade, Black Spade): 
- [Red, Black, Green, Magenta] [Spade, Heart, Diamond, Club]
- NFT types are minted randomly.

## Voting:
1. Voting takes place regularly over a discrete interval of time (e.g. every 12 hours).
2. Players can vote with as many NFTs as they own. Votes can be split in anyway that they choose.
- 1 NFT (no matter the level) = 1 vote, OR
- Burning the NFT gives votes = the level squared (e.g. Lvl 2 = 4, Lvl 3 = 9). When the NFT is burned it returns all its initial capital and interest won to the owner of the NFT.
3. Players can vote for gaining XP or for distributing interest or both. Below is an example ballot:



|Distribute Interest                  | Distribute XP    |
| ----------------------------------- | ---------------- |
|  All Reds                           |  All Reds        |
|  All Blacks                         |  All Blacks      |
|  All Greens                         |  All Greens      |
|  All Magentas                       |  All Magentas    |
|  All Spades                         |  All Spades      |
|  All Hearts                         |  All Hearts      |
|  All Diamonds                       |  All Diamonds    |
|  All Clubs                          |  All Clubs       |
|  All of a certain Level (e.g. 0)    |                  |




## Distributing Interest:

At the end of each voting round interest is distributed to cards based on the following procedure:

1. Total all votes from all players that were under the Distribute Interest section of the ballot.
- For example, during the voting period 1,000 votes from all players went to Distributing Interest and 1000 votes from all players went to Distribute XP, this total would be 1,000 even though there were 2,000 total votes cast.
2. Calculate the percentage of votes that each category received under Distribute Interest.
- For example, during the voting period 1,000 votes were cast on Distribute Interest categories with 100 of these being cast on Red. Red would receive 10% for its percentage calculation.
3. Each category receives interest that was accrued since the last vote in proportion to its percentage.
- For example, in the last 12 hours 100 DAI of interest was accrued. Red received 10% of the votes and would receive 10 DAI.
4. Distribute each category's interest to the cards of that type. The account that holds the cards must have voted (e.g. shown Effort) that round.
- For example, there are 200 Red cards total minted. In the last round 100 voted for Red in Distribute Interest, 80 voted for Red in Distribute XP, and 20 were associated with accounts that did not vote. The 10 DAI would be equally distributed among the 180 cards that voted.


## Distribute XP:

At the end of each voting round XP is distributed to cards based on the following procedure:

1. Total all votes from all players that were under the Distribute XP section of the ballot.
- For example, during the voting period 1,000 votes from all players went to Distributing Interest and 1000 votes from all players went to Distribute XP, this total would be 1,000 even though there were 2,000 total votes cast.
2. Calculate the percentage of votes that each category received under Distribute XP.
- For example, during the voting period 1,000 votes were cast on Distribute XP categories with 80 of these being cast on Red. Red would receive 8% for its percentage calculation.
3. Each category receives XP in proportion to its percentage. Currently this is set at percentage * 100.
- For example, all Red cards would receive 8 XP because they received 8% of the vote.
4. Unlike Interest, XP is not divided amongst all cards. Any card that is associated with an account that voted receives full XP.
- For  example, there are 200 Red cards total minted. In the last round 100 voted for Red in Distribute Interest, 80 voted for Red in Distribute XP, and 20 were associated with accounts that did not vote. Each of the 180 cards that voted would receive 8 XP.


## Leveling-Up:

Players level-up quadratically as follows:

- Lvl 0 = 0-99 XP
- Lvl 1 = 100 - 399 XP
- Lvl 2 = 400 - 899 XP
- Lvl 3 = 900 - 1599 XP
- Etc.

## Burning:

1. At anytime the owner of an NFT can burn the NFT. When the NFT is burned the following happens:
- The NFT is destroyed.
- The owning account receives the initial capital and any interest that the NFT won.
- The NFT generates votes = its level squared (e.g. Lvl 2 = 4 votes). These votes are not automatically cast in the game. The owner of the account can choose to vote or do nothing with them
