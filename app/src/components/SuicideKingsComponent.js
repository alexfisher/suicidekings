import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import AccountInfoComponent from "./AccountInfoComponent";
import ListKingsComponent from "./ListKingsComponent";
import CompoundInfoComponent from "./CompoundInfoComponent";
import logo from "../logo.png";

// Drizzle Context provides three types of React Components (below) -- Loading Component not available in this version yet :-(
//const { AccountData, ContractData, ContractForm } = newContextComponents;
const { ContractForm } = newContextComponents;

const SuicideKingsComponent = ({ drizzle, drizzleState }) => {
  return (
    <div className="App">

      <div className="AppHeader">
        <div className="AppTitle">
          <img src={logo} alt="suicidekings-logo" />
          <h1>Suicide Kings</h1>
          <AccountInfoComponent drizzle={drizzle} drizzleState={drizzleState} />
        </div>
      </div>
      <div className="AppMain">
        <div className="MintKing section">
        <div className="ComponentTitle">Mint King: </div>
          <ContractForm drizzle={drizzle} contract="SuicideKings" method="mintKing" sendArgs={{gas: 800000}} />      
        </div>
        <div className="ListKings section">
          <ListKingsComponent drizzle={drizzle} drizzleState={drizzleState} />
        </div>
        <div className="CompoundInfo section">
          <CompoundInfoComponent drizzle={drizzle} drizzleState={drizzleState} />
        </div>
      </div>

    </div>
  );
};

export default SuicideKingsComponent;