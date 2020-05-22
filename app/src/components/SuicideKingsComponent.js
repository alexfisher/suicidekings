import React from "react";
import { Grid, Typography } from '@material-ui/core';
import NetworkIndicator from '@rimble/network-indicator';
import AccountInfoComponent from "./AccountInfoComponent";
import KingsComponent from "./KingsComponent";
import CompoundInfoComponent from "./CompoundInfoComponent";
import logo from "../logo.png";

// Drizzle Context provides three types of React Components, e.g. destructure example:
// const { AccountData, ContractData, ContractForm } = newContextComponents;

// Material-ui Grid info: https://material-ui.com/api/grid/
// NetworkIndicator info: https://rimble.consensys.design/components/web3-components/NetworkIndicator

export default class SuicideKingsComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};  // For local state in this component
  }  

  componentDidMount() {
    // Destructure props to get Drizzle and DrizzleState if needed
    // const { drizzle, drizzleState } = this.props;

    // We can print our drizzle objects to the console if needed!
    // Or, just install React Developer Tools to your browser and view Components > props
    //console.log(drizzle);
    //console.log(drizzleState);    
  }

  render() {
    const { drizzle, drizzleState } = this.props;

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
      <Grid item xs={6}>
        <KingsComponent drizzle={drizzle} drizzleState={drizzleState} />
      </Grid>
      <Grid item xs={6}>
        <CompoundInfoComponent drizzle={drizzle} drizzleState={drizzleState} />
      </Grid>
    </Grid>      
    )
  }
}
