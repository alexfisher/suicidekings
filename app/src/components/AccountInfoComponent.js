import React from "react";
import { newContextComponents } from "@drizzle/react-components";

const { AccountData, ContractData } = newContextComponents;

class AccountInfoComponent extends React.Component {
  state = { dataKey: null };

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

  render() {
    const { drizzle, drizzleState } = this.props;
    const { SuicideKing } = drizzleState.contracts;
    const symbol = SuicideKing.symbol[this.state.dataKey];

    return (
      <div className="AccountInfo">
        <div className="AccountBalance">
          <AccountData
            drizzle={this.props.drizzle}
            drizzleState={this.props.drizzleState}
            accountIndex={0}
            units="ether"
            precision={3}
          />
        </div>      
        <div className="KingBalance">
          Total Supply:&nbsp;   
          <ContractData
            drizzle={this.props.drizzle}
            drizzleState={this.props.drizzleState}
            contract="SuicideKing"
            method="totalSupply"
            methodArgs={[2]}
          />&nbsp;{symbol && symbol.value}S
          
        </div>
      </div>
    )
  }

} 

/*
({ drizzle, drizzleState }) => {
  return (
    <div className="AccountInfo">
      <div className="AccountBalance">
        <AccountData
          drizzle={drizzle}
          drizzleState={drizzleState}
          accountIndex={0}
          units="ether"
          precision={3}
        />
      </div>      
      <div className="KingBalance">
        Total Supply:&nbsp;   
        <ContractData
          drizzle={drizzle}
          drizzleState={drizzleState}
          contract="SuicideKing"
          method="totalSupply"
          methodArgs={[2]}
        />
        &nbsp;KINGS 
      </div>
    </div>
  );
};
*/

export default AccountInfoComponent;