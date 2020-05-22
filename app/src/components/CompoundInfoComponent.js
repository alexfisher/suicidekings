import React from "react";
import { newContextComponents } from "@drizzle/react-components";
import { Box, Typography } from '@material-ui/core';
import { Card } from "rimble-ui";

const { ContractData, ContractForm } = newContextComponents;

export default class CompoundInfoComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};  // For local state in this component
  }

  componentDidMount() {
    // Destructure props to get Drizzle and DrizzleState if needed
    // const { drizzle, drizzleState } = this.props;
  }

  render() {
    const { drizzle, drizzleState } = this.props;

    return (
      <Box>
        <Box>
          <Typography variant="h5" component="h2" gutterBottom>
            Compound
          </Typography>      
        </Box>      
        <Card>
        <Box>
          <p>
            <span>Compound Contract Name: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="name"
            />
          </p>
          <p>
            <span>Total Borrows: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="totalBorrows"
            />
          </p>
          <p>
            <span>Total Supply: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="totalSupply"
            />
          </p>
          <div>
            <span>Mint 0.1 ETH worth of cETH: </span>
            <ContractForm
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="mint"
              sendArgs={{value: 100000000000000000}}
            />
          </div>          
          <div>
            <span>Your cETH balance: </span>
            <ContractData
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="balanceOf"
              methodArgs={[drizzleState.accounts[0]]}
            />
          </div>
          <div>
            <span>Convert cETH to ETH</span>
            <ContractForm
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="CETH"
              method="redeem"
              labels={["Amount of cETH"]}
            />
          </div>
        </Box>
      </Card>
      </Box>      
    )
  }
}