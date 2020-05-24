pragma solidity ^0.5.16;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import 'multi-token-standard/contracts/tokens/ERC1155/ERC1155.sol';
import 'multi-token-standard/contracts/tokens/ERC1155/ERC1155Metadata.sol';
import 'multi-token-standard/contracts/tokens/ERC1155/ERC1155MintBurn.sol';
import "./Strings.sol";

contract OwnableDelegateProxy { }

contract ProxyRegistry {
  mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title ERC1155Tradable
 */
contract ERC1155Tradable is ERC1155, ReentrancyGuard, ERC1155Metadata, Ownable {
  using Strings for string;
  /***********************************|
  |     Variables/Events/Modifiers    |
  |__________________________________*/

  address proxyRegistryAddress;
  
  /* ---------------------------------------- */
  /* DELETE THESE */
  /* ---------------------------------------- */
  uint256 private _currentTokenID = 0;
  mapping (uint256 => uint256) public kingBaseCounter;
  /* ---------------------------------------- */

  string public name;
  string public symbol;

  uint256 constant NUM_CARDTYPE = 16;
  uint256 seed;

  //
  // Events
  //
  event RandomBaseID(
    uint8 indexed _id
  );

  event KingCrowned(
    address indexed _sender,
    address indexed _receiver,
    uint256 indexed _tokenId,
    string _uri
  );

  event KingBurned(
    address indexed _from,
    uint256 indexed _tokenId
  );

  //
  // Modifiers
  //
  /**
   * @dev Require msg.sender to own more than 0 of the token id
   */
  modifier ownersOnly(uint256 _id) {
    require(balances[msg.sender][_id] > 0, "ERC1155Tradable#ownersOnly: ONLY_OWNERS_ALLOWED");
    _;
  }

  constructor(string memory _name, string memory _symbol, address _proxyRegistryAddress) public {
    name = _name;
    symbol = _symbol;
    proxyRegistryAddress = _proxyRegistryAddress;
  }

  function uri(uint256 _id) public view returns (string memory) {
    return Strings.strConcat(baseMetadataURI, Strings.uint2str(_id));
  }

  /**
   * @dev Improve pseudorandom number generator by letting the owner set the seed manually,
   * making attacks more difficult
   * @param _newSeed The new seed to use for the next transaction
   */
  function setSeed(uint256 _newSeed) public onlyOwner {
    seed = _newSeed;
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

  function randomTokenId() public returns (uint8) {
    uint8 value = uint8(_random().mod(NUM_CARDTYPE)) + 1;
    emit RandomBaseID(value);
    return value;
  }

  /**
   * @dev Will update the base URL of token's URI
   * @param _newBaseMetadataURI New base URL of token's URI
   */
  function setBaseMetadataURI(string memory _newBaseMetadataURI) public onlyOwner {
    _setBaseMetadataURI(_newBaseMetadataURI);
  }

  function crownNewKing(string calldata _uri, bytes calldata _data) external onlyOwner returns (uint256) {
    // Get King Base
    uint256 kingBase = uint256(randomTokenId()) << 248;

    // get Next King NFT ID
    kingBaseCounter[kingBase]++;
    uint256 _id = kingBaseCounter[kingBase] + kingBase;

    if (bytes(_uri).length > 0) {
      emit URI(_uri, _id);
    }

    address _to = msg.sender;
    uint256 _amount = 1;

    // Add _amount
    balances[_to][_id] = balances[_to][_id].add(_amount);

    // Emit event
    emit KingCrowned(msg.sender, msg.sender, _id, _uri);
    emit TransferSingle(msg.sender, address(0x0), _to, _id, _amount);

    // Calling onReceive method if recipient is contract
    _callonERC1155Received(address(0x0), _to, _id, _amount, gasleft(), _data);

    return _id;
  }

  /**
   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-free listings.
   */
  function isApprovedForAll( address _owner, address _operator) public view returns (bool isOperator) {
    // Whitelist OpenSea proxy contract for easy trading.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(_owner)) == _operator) {
      return true;
    }

    return ERC1155.isApprovedForAll(_owner, _operator);
  }
}
