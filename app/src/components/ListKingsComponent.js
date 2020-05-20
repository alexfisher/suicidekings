import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import Button from '@material-ui/core/Button';

const { ContractForm } = newContextComponents;

const ListKingsComponent = ({ drizzle, drizzleState }) => {
  return (
    <div className="ListKingsComponent">
      <div className="ComponentTitle">Your King(s): </div>

      <Button variant="contained" color="primary">
        Hellow World
      </Button>

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
