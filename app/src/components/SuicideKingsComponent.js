import React from "react";
import { Box, Grid, Typography } from '@material-ui/core';
//import { newContextComponents } from "@drizzle/react-components";
import AccountInfoComponent from "./AccountInfoComponent";
import ListKingsComponent from "./ListKingsComponent";
import CompoundInfoComponent from "./CompoundInfoComponent";
import logo from "../logo.png";

// Drizzle Context provides three types of React Components (below) -- Loading Component not available in this version yet :-(
//const { AccountData, ContractData, ContractForm } = newContextComponents;
//const { ContractForm } = newContextComponents;

const SuicideKingsComponent = ({ drizzle, drizzleState }) => {
  return (
    <Grid container spacing={3}>
      <Grid item xs={3}>
        <img src={logo} alt="suicidekings-logo" width="116px"/>
      </Grid>
      <Grid item xs={9}>
        <Typography variant="h4" component="h1" gutterBottom>
          Suicide Kings
        </Typography>
        <AccountInfoComponent drizzle={drizzle} drizzleState={drizzleState} />
      </Grid>
      <Grid item xs={12}>
        <Box>
          <ListKingsComponent drizzle={drizzle} drizzleState={drizzleState} />
        </Box>
      </Grid>
      <Grid item xs={12}>
        <CompoundInfoComponent drizzle={drizzle} drizzleState={drizzleState} />
      </Grid>
    </Grid>
  );
};

export default SuicideKingsComponent;
