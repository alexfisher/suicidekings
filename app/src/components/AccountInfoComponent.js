import React from "react";
import { newContextComponents } from "@drizzle/react-components";

const { AccountData, ContractData } = newContextComponents;

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
          Select type id:&nbsp; 
          <span>
            <select value={this.state.id} onChange={this.handleIdChange}>
              <option value="1">1</option>
              <option value="2">2</option>
              <option value="3">3</option>
            </select>
          </span>&nbsp; 

          Total Supply:&nbsp;   
          <ContractData
            drizzle={this.props.drizzle}
            drizzleState={this.props.drizzleState}
            contract="SuicideKing"
            method="totalSupply"
            methodArgs={[this.state.id]}
          />&nbsp;{symbol && symbol.value}S
        </div>
      </div>
    )
  }

} 

export default AccountInfoComponent;