import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import AccountInfoComponent from "./AccountInfoComponent";
import ListKingsComponent from "./ListKingsComponent";
import logo from "../logo.png";

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
        <div className="MintKing">
        <div className="ComponentTitle">Mint King: </div>
          <ContractForm drizzle={drizzle} contract="SuicideKings" method="mintKing" sendArgs={{gas: 800000}} />      
        </div>
        <div className="ListKings">
          <ListKingsComponent drizzle={drizzle} drizzleState={drizzleState} />
        </div>
      </div>

    </div>
  );
};

export default SuicideKingsComponent;