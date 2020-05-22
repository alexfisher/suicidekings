import React from "react";
import { Box, Typography } from '@material-ui/core';
//import { newContextComponents } from "@drizzle/react-components";
import { Card, EthAddress } from "rimble-ui";

//const { ContractData } = newContextComponents;

export default class AccountInfoComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = { id: 1, tokenSymbol: null };
  }

  componentDidMount() {
    // Destructure props to get Drizzle and DrizzleState if needed
    // const { drizzle, drizzleState } = this.props;
  }

  render() {
    const { drizzleState } = this.props;

    return (
    <Box>
      <Box>
        <Typography variant="h5" component="h2" gutterBottom>
          Account Info
        </Typography>      
      </Box>      
      <Card>
        <EthAddress address={drizzleState.accounts[0]} textLabels />
        <Box>
          Balance: {drizzleState.accountBalances[drizzleState.accounts[0]]} Wei
        </Box>
      </Card>
    </Box>
    )
  }
}