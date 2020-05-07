pragma solidity >=0.4.21 <0.7.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Enumerable.sol";
import "@openzeppelin/contracts/drafts/Counters.sol";

contract SuicideKings is ERC721Full {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  event MintKing(uint256 id);
  event ValueSet(string message);
  uint256 public _value;

  constructor() ERC721Full ("SuicideKing", "KING") public {
  }

  function mintKing(address player, string memory tokenURI) public returns (uint256) {
    _tokenIds.increment();

    uint256 newItemId = _tokenIds.current();
    _mint(player, newItemId);
    _setTokenURI(newItemId, tokenURI);

    emit MintKing(newItemId);

    return newItemId;
  }

  // TODO: Let's add a function to enumerate a list of all our NFTs, e.g.
  /*
  function myKings() public view returns (uint256[]) {
    return _tokensOfOwner(msg.sender);
  }
  */

  function setValue(uint256 value) public {
    _value = value;

    emit ValueSet("Value stored successfully!");
  }

  function getValue() public view returns (uint256) {
    return _value;
  }
}