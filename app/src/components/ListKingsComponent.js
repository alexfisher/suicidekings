import React from "react";
import { newContextComponents } from "@drizzle/react-components";

const { ContractData } = newContextComponents;

const ListKingsComponent = ({ drizzle, drizzleState }) => {
  return (
    <div className="ListKingsComponent">
      <div className="ComponentTitle">Your King(s): </div>

      <ContractData
        drizzle={drizzle}
        drizzleState={drizzleState}
        contract="SuicideKings"
        method="myKings"
      />

    </div>
  );
};

export default ListKingsComponent;