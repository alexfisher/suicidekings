//import Web3 from "web3";
import SuicideKing from "./contracts/SuicideKing.json";
import CETH from "./external-contracts/Compound.json";

const options = {
  web3: {
    block: false,
    // REMOVED BELOW LINE so Drizzle uses Metamask (wasted too much time realizing this is what I had to do)
    //customProvider: new Web3("ws://localhost:8545")
  },
  contracts: [
    SuicideKing,
    CETH
  ],
  events: {
    SuicideKing: ["URI"]
  },
};

export default options;


