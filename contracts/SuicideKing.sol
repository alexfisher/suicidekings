pragma solidity ^0.5.16;

import "./ERC1155Tradable.sol";

/**
 * @title SuicideKing
 * SuicideKing - a contract for my semi-fungible tokens.
 */
contract SuicideKing is ERC1155Tradable {
  constructor(address _proxyRegistryAddress)
  ERC1155Tradable(
    "SuicideKing",
    "KING",
    _proxyRegistryAddress
  ) public {
    _setBaseMetadataURI("https://creatures-api.opensea.io/api/creature/");
  }

  // AJDF - Changed this from view to pure due to compiler warning
  function contractURI() public pure returns (string memory) {
    return "https://creatures-api.opensea.io/contract/opensea-erc1155";
  }
}
