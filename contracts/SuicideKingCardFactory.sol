// SPDX-License-Identifier: MIT

pragma solidity ^0.5.16;

import "multi-token-standard/contracts/tokens/ERC1155/ERC1155.sol";
import "multi-token-standard/contracts/utils/Ownable.sol";

contract SuicideKingCardFactory is Ownable {
  using SafeMath for uint256;

  /**
   * Card types. Combination of:
   *  - suit (pip) + color
   */
  enum CardType {
    Suit1Color1, Suit1Color2, Suit1Color3, Suit1Color4,
    Suit2Color1, Suit2Color2, Suit2Color3, Suit2Color4,
    Suit3Color1, Suit3Color2, Suit3Color3, Suit3Color4,
    Suit4Color1, Suit4Color2, Suit4Color3, Suit4Color4
  }

  uint256 constant NUM_CARDTYPE = 16;
  uint256 seed;


  function numCardTypes() external pure returns (uint256) {
    return NUM_CARDTYPE;
  }

  /**
   * @dev Improve pseudorandom number generator by letting the owner set the seed manually,
   * making attacks more difficult
   * @param _newSeed The new seed to use for the next transaction
   */
  function setSeed(uint256 _newSeed) public onlyOwner {
    seed = _newSeed;
  }

  function pickRandomCardType() public returns (uint256) {
    CardType cardType = _pickRandomCardType();
    return uint256(cardType);
  }

   /**
   * @dev Pseudo-random number generator
   * NOTE: to improve randomness, generate it with an oracle
   */
  function _random() internal returns (uint256) {
    uint256 randomNumber = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, seed)));
    seed = randomNumber;
    return randomNumber;
  }

  /**
    If using `ganache`, be sure to specify "blockTime". From the docs:
    Using the --blockTime flag is discouraged unless you have tests which require a specific mining interval.
    
    We do, because `_random()` relies on the block number.
   */
  function _pickRandomCardType() internal returns (CardType) {
    uint16 value = uint16(_random().mod(NUM_CARDTYPE));
    return CardType(value);
  }
}
