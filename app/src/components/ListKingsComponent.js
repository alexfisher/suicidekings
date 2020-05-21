import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import { Box, Button, Typography } from '@material-ui/core';

const { ContractData } = newContextComponents;

const ListKingsComponent = ({ drizzle, drizzleState }) => {
  return (
    <Box>
      <Box>
        <Typography variant="h5" component="h2" gutterBottom>
          SuicideKingCardFactory
        </Typography>      
      </Box>
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
        Number of Card Types:{' '} 
      </Box>
    </Box>
  );
};

export default ListKingsComponent;
