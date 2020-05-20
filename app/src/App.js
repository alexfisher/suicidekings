//import Web3 from "web3";
import React from "react";
import Container from '@material-ui/core/Container';
import Typography from '@material-ui/core/Typography';
import Box from '@material-ui/core/Box';
import Link from '@material-ui/core/Link';
import ProTip from './ProTip';
import { DrizzleContext } from "@drizzle/react-plugin";
import { Drizzle } from "@drizzle/store";
import drizzleOptions from "./drizzleOptions";
import SuicideKingsComponent from "./components/SuicideKingsComponent";
import logo from "./logo.png";
//import "./App.css";

function Copyright() {
  return (
    <Typography variant="body2" color="textSecondary" align="center">
      {'Copyright © '}
      <Link color="inherit" href="https://material-ui.com/">
        The Crypto Bros
      </Link>{' '}
      {new Date().getFullYear()}
      {'.'}
    </Typography>
  );
}

const drizzle = new Drizzle(drizzleOptions);

const App = () => {
  return (
    <Container maxWidth="sm">
      <Box my={4}>
        <Typography variant="h4" component="h1" gutterBottom>
          Suicide Kings
        </Typography>
      </Box>
      <Box>
        <DrizzleContext.Provider drizzle={drizzle}>
          <DrizzleContext.Consumer>
            {drizzleContext => {
              const { drizzle, drizzleState, initialized } = drizzleContext;

              window.drizzle = drizzle;
              window.drizzleState = drizzleState;

              if (!initialized) {
                return (
                  <div className="Loading">
                    <img src={logo} alt="suicidekings-logo" />
                    <div>Loading...</div>
                  </div>
                )
              }

              return (
                <SuicideKingsComponent drizzle={drizzle} drizzleState={drizzleState} />
              )
            }}
          </DrizzleContext.Consumer>
        </DrizzleContext.Provider>
        <ProTip />
        <Copyright />
      </Box>
    </Container>
  );
}

export default App;
