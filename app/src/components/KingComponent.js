import React from "react";
import PropTypes from 'prop-types';
import { Box, Select, Typography } from '@material-ui/core';
import { Button, Card, Modal } from "rimble-ui";
import { newContextComponents } from "@drizzle/react-components";

const { ContractData, ContractForm } = newContextComponents;

export class KingsCrownedModal extends Modal {
  constructor(props) {
    super(props);

  }

  componentDidMount() {
    const { drizzle } = this.props;
  }
}

KingsCrownedModal.defaultProps = {
};

KingsCrownedModal.propTypes = {
};

export default class KingsComponent extends React.Component {
  constructor(props) {
    super(props);
    this.state = { id: 1, tokenId: null, tokenSymbol: null };

    this.handleIdChange = this.handleIdChange.bind(this);
  }

  componentDidMount() {
    // Destructure properties of the component 
    const { drizzle } = this.props;
    const SuicideKing = drizzle.contracts.SuicideKing;
    const tokenSymbol = SuicideKing.methods["symbol"].cacheCall();
    this.setState({tokenSymbol});
  }

  handleIdChange(tokenId) {
    this.setState({tokenId: tokenId});
  }

  handleMintKing = (event) => {
    const { drizzle, drizzleState } = this.props;
    console.log(drizzle);
    console.log(drizzleState);    

    drizzle.contracts.SuicideKing.methods
      .crownNewKing("http://", [])
      .send({ from: drizzleState.accounts[0] })
      .then(function (result) {
        return result.events;
    })
    .then(function(events) {
      return events.KingCrowned.returnValues._tokenId
    })
    .then(function(tokenId) {
      var decimal = drizzle.web3.utils.toBN(tokenId).words[9] >> 14;
      var output = "";
      switch(decimal) {
        case 1: output = "Spades; Red";  break;
        case 2: output = "Spades; White";  break;
        case 3: output = "Spades; Green";  break;
        case 4: output = "Spades; Yellow";  break;

        case 5: output = "Clubs; Red";  break;
        case 6: output = "Clubs; White";  break;
        case 7: output = "Clubs; Green";  break;
        case 8: output = "Clubs; Yellow";  break;

        case 9: output = "Diamonds; Red";  break;
        case 10: output = "Diamonds; White";  break;
        case 11: output = "Diamonds; Green";  break;
        case 12: output = "Diamonds; Yellow";  break;
        
        case 13: output = "Hearts; Red";  break;
        case 14: output = "Hearts; White";  break;
        case 15: output = "Hearts; Green";  break;
        case 16: output = "Hearts; Yellow";  break;

        default:
          // code block
      }
      var bigNum  =

      alert(`${output}\n\nID: ${tokenId}`)

      // alert(drizzle.web3.utils.toHex(decimal));
      // this god-damn, stupid-ass call...the VERY basis of how React is supposed to work...
      // won't work because fucking Javascript can't find 'this', and no amount of 'BINDING'
      // or switching to dumbass ES6 function syntax is doing a damn thing:
      //
      // this.setState({tokenId: tokenId})
    });
  }


  render() {
    const { drizzle, drizzleState } = this.props;
    const { SuicideKing } = drizzleState.contracts;
    const tokenSymbol = SuicideKing.symbol[this.state.tokenSymbol];

    return (
      <Box>
        <Box>
          <Typography variant="h5" component="h2" gutterBottom>
            Kings
          </Typography>      
        </Box>
        <Card>  
          <Box>
            <ContractForm
              drizzle={drizzle}
              drizzleState={drizzleState}
              contract="SuicideKing"
              method="crownNewKing"
              render={({ inputs, inputTypes, state, handleInputChange, handleSubmit }) => (
                <Button size="small" type="submit" onClick={this.handleMintKing}>
                  Mint KING
                </Button>
              )} 
            />
          </Box> 
        </Card>
      </Box>
    )
    
  }

}