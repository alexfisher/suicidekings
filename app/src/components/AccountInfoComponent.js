import React from "react";
import { newContextComponents } from "@drizzle/react-components";

const { AccountData } = newContextComponents;

const AccountInfoComponent = ({ drizzle, drizzleState }) => {
  return (
    <div className="AccountInfo">
      <AccountData
        drizzle={drizzle}
        drizzleState={drizzleState}
        accountIndex={0}
        units="ether"
        precision={3}
      />  
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