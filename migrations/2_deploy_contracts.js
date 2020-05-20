const SuicideKing = artifacts.require("SuicideKing");
const SuicideKingCardFactory = artifacts.require("SuicideKingCardFactory");

module.exports = function(deployer, network) {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress;
  if (network === 'rinkeby') {
    proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
  } else {
    proxyRegistryAddress = "0xa5409ec958c83c3f309868babaca7c86dcb077c1";
  }

  deployer.deploy(SuicideKing, proxyRegistryAddress,  {gas: 5000000});
  deployer.deploy(SuicideKingCardFactory);
};
