const path = require("path");
const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require('fs');

// NOTE: You will need a secrets.json (not checked into git repo) containing mnemonic and infuraApiKey:
//  { "mnemonic": "YOUR SECRET MNEMONIC", "infuraApiKey": "YOUR INFURA API KEY"}
// You can generate a new mnemonic with ganache/ganache-cli and you can sign-up for a free infura API key at https://infura.io
// To start ganache-cli using the same mnemonic use: ganache-cli -m "YOU MNEMONIC GOES HERE"
// Otherwise, ganache-cli -d will use the deterministic mnemonic

let secrets;

if(fs.existsSync('secrets.json')) {
  secrets = JSON.parse(fs.readFileSync('secrets.json', 'utf8'));
}

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!

  contracts_build_directory: path.join(__dirname, "app/src/contracts"),
  networks: {
    develop: { // Running locally, on-host
      host: "127.0.0.1",
      port: 8545,
      network_id: "999"
    },
    local: { // Running in a Docker container
      host: "0.0.0.0",
      port: 8545,
      network_id: "999",
      setTimeout: 90
    },
    docker: { // Running in a Docker container, as part of a `docker-compose` service
      host: "suicidekings_ganache_1",
      port: 8545,
      network_id: "999",
      setTimeout: 90
    },
    ropsten: {
      provider: new HDWalletProvider(secrets.mnemonic, "https://ropsten.infura.io/v3/"+secrets.infuraApiKey),
      network_id: 3
    },
    kovan: {
      provider: new HDWalletProvider(secrets.mnemonic, "https://kovan.infura.io/v3/"+secrets.infuraApiKey),
      network_id: 42
    },
    rinkeby: {
      provider: new HDWalletProvider(secrets.mnemonic, "https://rinkeby.infura.io/v3/"+secrets.infuraApiKey),
      network_id: "*"
    }
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.5.16"
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  }
};
