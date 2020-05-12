import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import AccountInfoComponent from "./AccountInfoComponent";
import logo from "../logo.png";

//const { AccountData, ContractData, ContractForm } = newContextComponents;
const { ContractData, ContractForm } = newContextComponents;

const SuicideKingsComponent = ({ drizzle, drizzleState }) => {
  return (
    <div className="App">

      <div>
        <img src={logo} alt="suicidekings-logo" />
        <h1>Suicide Kings</h1>
      </div>

      <AccountInfoComponent drizzle={drizzle} drizzleState={drizzleState} />

      <div className="section">
        <h2>SuicideKings</h2>
        <p>
          <strong>Stored Value: </strong>
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="SuicideKings"
            method="getValue"
          />
        </p>
        <ContractForm drizzle={drizzle} contract="SuicideKings" method="setValue" />
        <ContractForm drizzle={drizzle} contract="SuicideKings" method="mintKing" sendArgs={{gas: 800000}} />
        <p>
          <strong>King Count: </strong>
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="SuicideKings"
            method="balanceOf"
            methodArgs={[drizzleState.accounts[0]]}
          />
        </p>        
      </div>

    </div>
  );
};

export default SuicideKingsComponent;