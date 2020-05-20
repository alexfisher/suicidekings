import React from "react";
import { newContextComponents } from "@drizzle/react-components";

const { ContractForm } = newContextComponents;

const ListKingsComponent = ({ drizzle, drizzleState }) => {
  return (
    <div className="ListKingsComponent">
      <div className="ComponentTitle">Your King(s): </div>

      <ContractForm
        drizzle={drizzle}
        drizzleState={drizzleState}
        contract="SuicideKingCardFactory"
        method="pickRandomCardType"
      />

    </div>
  );
};

export default ListKingsComponent;
