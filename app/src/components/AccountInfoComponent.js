import React from "react";
import { Box, Select, Typography } from '@material-ui/core';
import { newContextComponents } from "@drizzle/react-components";
import { Button, Card, EthAddress } from "rimble-ui";

const { ContractData } = newContextComponents;

class AccountInfoComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = { id: 1, tokenSymbol: null };

    this.handleIdChange = this.handleIdChange.bind(this);
    this.handleMintKing = this.handleMintKing.bind(this);
  }

  componentDidMount() {
    // Destructure properties of the component 
    // (at least drizzle and drizzleState will be passed in JSX call, but you can add more)
    const { drizzle } = this.props;
    const SuicideKing = drizzle.contracts.SuicideKing;
    const tokenSymbol = SuicideKing.methods["symbol"].cacheCall();
    this.setState({tokenSymbol});
    
    // We can print our drizzle objects to the console if needed!
    // Or, just install React Developer Tools to your browser and view Components > props
    //console.log(drizzle);
    //console.log(drizzleState);
  }

  handleIdChange(event) {
    this.setState({id: event.target.value});
    console.log(event.target.value);
  }

  handleMintKing(event) {
    const { drizzle, drizzleState } = this.props;
    console.log(drizzle);
    console.log(drizzleState);    

    if(drizzleState.drizzleStatus.initialized) {
      const stackId = drizzle.contracts.SuicideKing.methods["create"].cacheSend(drizzleState.accounts[0], 1, "http://TODO_API_URL_HERE", []);

      if(drizzleState.transactionStack[stackId]) {
        const txHash = drizzleState.transactionStack[stackId];
        console.log('New King id minted, txHash: ' + txHash);
      }
    }
    
  }

  render() {
    const { drizzle, drizzleState } = this.props;
    const { SuicideKing } = drizzleState.contracts;
    const tokenSymbol = SuicideKing.symbol[this.state.tokenSymbol];

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
        <Box>
          ERC1155 type (_id):&nbsp; 
          <Select value={this.state.id} onChange={this.handleIdChange}>
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3">3</option>
            <option value="4">4</option>
            <option value="5">5</option>
          </Select>&nbsp;Total Supply:&nbsp;
          <ContractData
          drizzle={drizzle}
          drizzleState={drizzleState}
          contract="SuicideKing"
          method="totalSupply"
          methodArgs={[this.state.id]}
          />&nbsp;{tokenSymbol && tokenSymbol.value}S
        </Box>
        <Box>
          <Button size="small" type="submit" onClick={this.handleMintKing}>
            Mint KING
          </Button>
        </Box> 

      </Card>
    </Box>
    )
  }

} 

export default AccountInfoComponent;