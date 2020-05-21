import React from "react";
import { Grid, Typography } from '@material-ui/core';
import NetworkIndicator from '@rimble/network-indicator';
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
        <Typography variant="h4" component="h1">
          Suicide Kings
        </Typography>
        <NetworkIndicator currentNetwork={drizzleState.web3.networkId} requiredNetwork={4}>
          {{
            onNetworkMessage: "Connected to correct network",
            noNetworkMessage: "Not connected to anything",
            onWrongNetworkMessage: "Wrong network"
          }}
        </NetworkIndicator>        
      </Grid>
      <Grid item xs={12}>
        <AccountInfoComponent drizzle={drizzle} drizzleState={drizzleState} />
      </Grid>
      <Grid item xs={12}>
        <ListKingsComponent drizzle={drizzle} drizzleState={drizzleState} />
      </Grid>
      <Grid item xs={12}>
        <CompoundInfoComponent drizzle={drizzle} drizzleState={drizzleState} />
      </Grid>
    </Grid>
  );
};

export default SuicideKingsComponent;
