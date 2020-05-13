import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import AccountInfoComponent from "./AccountInfoComponent";
import ListKingsComponent from "./ListKingsComponent";
import logo from "../logo.png";

//const { AccountData, ContractData, ContractForm } = newContextComponents;
const { ContractForm, ContractData } = newContextComponents;

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
        <div className="CompoundInfo">
          <div className="ComponentTitle">Compound Info:</div>
          <p>
            <span>Compound Contract Name: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="name"
            />
          </p>
          <p>
            <span>Total Borrows: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="totalBorrows"
            />
          </p>
          <p>
            <span>Total Supply: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="totalSupply"
            />
          </p>
          <p>
            <span>Your cETH balance: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="balanceOf"
              methodArgs={[drizzleState.accounts[0]]}
            />
          </p>
          <div>
            <span>Mint 0.1 ETH worth of cETH: </span>
            <ContractForm
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="mint"
              sendArgs={{value: 100000000000000000}}
            />
          </div>
        </div>
      </div>

    </div>
  );
};

export default SuicideKingsComponent;