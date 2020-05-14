//import Web3 from "web3";
import SuicideKings from "./contracts/SuicideKings.json";
import CETH from "./external-contracts/Compound.json";

const options = {
  web3: {
    block: false,
    // REMOVED BELOW LINE so Drizzle uses Metamask (wasted too much time realizing this is what I had to do)
    //customProvider: new Web3("ws://localhost:8545")
  },
  contracts: [
    SuicideKings,
    CETH
  ],
  events: {
    SuicideKings: ["MintKing", "ValueSet"]
  },
};

export default options;


