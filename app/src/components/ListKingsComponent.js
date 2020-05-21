import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import { Box, Button, Typography } from '@material-ui/core';
import { Card } from "rimble-ui";

const { ContractData } = newContextComponents;

/*
function genRandom() {
  const randomNum = drizzle.contracts.SuicideKingCardFactory.methods.pickRandomCardType.cacheSend({from: drizzleState.accounts[0]});
}
*/

const ListKingsComponent = ({ drizzle, drizzleState }) => {
  return (
    <Box>
      <Box>
        <Typography variant="h5" component="h2" gutterBottom>
          Kings
        </Typography>      
      </Box>
      <Card>  
        <Box>
          Number of Card Types:{' '} 
          <ContractData
            drizzle={drizzle}
            drizzleState={drizzleState}
            contract="SuicideKingCardFactory"
            method="numCardTypes"
          />
        </Box>
        <Box>
          <Button variant="contained" color="primary">Generate Random Number</Button>
          <Box>
            Random number: 
          </Box>
        </Box>
      </Card>
    </Box>
  );
};

export default ListKingsComponent;
