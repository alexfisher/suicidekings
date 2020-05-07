import Web3 from "web3";
import ComplexStorage from "./contracts/ComplexStorage.json";
import SimpleStorage from "./contracts/SimpleStorage.json";
import TutorialToken from "./contracts/TutorialToken.json";
import SuicideKings from "./contracts/SuicideKings.json";

// Set web3 provider to connect directly via web socket to localhost
// TODO: Change this to use metamask, web3modal, or something better.
const web3Provider = new Web3("ws://localhost:8545");

const options = {
  web3: {
    block: false,
    customProvider: web3Provider,
  },
  contracts: [SimpleStorage, ComplexStorage, TutorialToken, SuicideKings],
  events: {
    SimpleStorage: ["StorageSet"],
    SuicideKings: ["MintKing", "ValueSet"]
  },
};

export default options;
