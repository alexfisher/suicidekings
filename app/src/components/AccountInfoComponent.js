import React from "react";
import { Box, Select, Typography } from '@material-ui/core';
import { newContextComponents } from "@drizzle/react-components";
import { Card, EthAddress } from "rimble-ui";

const { ContractData } = newContextComponents;

class AccountInfoComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = { dataKey: null, id: 1 };

    this.handleIdChange = this.handleIdChange.bind(this);
  }

  componentDidMount() {
    // Destructure properties of the component 
    // (at least drizzle and drizzleState will be passed in JSX call, but you can add more)
    const { drizzle } = this.props;
    const SuicideKing = drizzle.contracts.SuicideKing;
    const dataKey = SuicideKing.methods["symbol"].cacheCall();
    this.setState({dataKey});
    
    // We can print our drizzle objects to the console if needed!
    // Or, just install React Developer Tools to your browser and view Components > props
    //console.log(drizzle);
    //console.log(drizzleState);
  }

  handleIdChange(event) {
    this.setState({id: event.target.value});
    console.log(event.target.value);
  }

  render() {
    const { drizzle, drizzleState } = this.props;
    const { SuicideKing } = drizzleState.contracts;
    const symbol = SuicideKing.symbol[this.state.dataKey];

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
          />&nbsp;{symbol && symbol.value}S
        </Box>      

      </Card>
    </Box>
    )
  }

} 

export default AccountInfoComponent;