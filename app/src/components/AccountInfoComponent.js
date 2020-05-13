import React from "react";
import { newContextComponents } from "@drizzle/react-components";

const { AccountData, ContractData } = newContextComponents;

const AccountInfoComponent = ({ drizzle, drizzleState }) => {
  return (
    <div className="AccountInfo">
      <div className="AccountBalance">
        <AccountData
          drizzle={drizzle}
          drizzleState={drizzleState}
          accountIndex={0}
          units="ether"
          precision={3}
        />
      </div>      
      <div className="KingBalance">
        <ContractData
          drizzle={drizzle}
          drizzleState={drizzleState}
          contract="SuicideKings"
          method="balanceOf"
          methodArgs={[drizzleState.accounts[0]]}
        />
        &nbsp;King(s)
      </div>
    {/*
      <div>
        Web3 Connection Status: {drizzleState.drizzleStatus.initialized.toString()}
      </div>
      <div>
        Web3 Connection Status: {drizzleState.drizzleStatus.initialized ? 'online' : 'offline'}
      </div>          
    */}

    </div>
  );
};

export default AccountInfoComponent;