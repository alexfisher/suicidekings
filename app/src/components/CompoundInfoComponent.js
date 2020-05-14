import React from "react";
import { newContextComponents } from "@drizzle/react-components";

//const { AccountData, ContractData, ContractForm } = newContextComponents;
const { ContractData, ContractForm } = newContextComponents;

const CompoundInfoComponent = ({ drizzle, drizzleState }) => {
  return (
    <div className="CompoundInfoComponent">
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
          <div>
            <span>Your cETH balance: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="balanceOf"
              methodArgs={[drizzleState.accounts[0]]}
            />
          </div>
          <div>
            <span>Convert cETH to ETH</span>
            <ContractForm
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="redeem"
              labels={["Amount of cETH"]}
            />
          </div>
    </div>
  );
};

export default CompoundInfoComponent;