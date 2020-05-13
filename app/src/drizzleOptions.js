//import Web3 from "web3";
import ComplexStorage from "./contracts/ComplexStorage.json";
import SimpleStorage from "./contracts/SimpleStorage.json";
import TutorialToken from "./contracts/TutorialToken.json";
import SuicideKings from "./contracts/SuicideKings.json";

const options = {
  web3: {
    block: false,
    // REMOVED BELOW LINE so Drizzle uses Metamask (wasted too much time realizing this is what I had to do)
    //customProvider: new Web3("ws://localhost:8545")
  },
  contracts: [
    SimpleStorage, 
    ComplexStorage, 
    TutorialToken, 
    SuicideKings
  ],
  events: {
    SimpleStorage: ["StorageSet"],
    SuicideKings: ["MintKing", "ValueSet"]
  },
};

export default options;


