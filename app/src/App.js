//import Web3 from "web3";
import React from "react";
import { DrizzleContext } from "@drizzle/react-plugin";
import { Drizzle } from "@drizzle/store";
import drizzleOptions from "./drizzleOptions";
import SuicideKingsComponent from "./components/SuicideKingsComponent";

// Page Templates
import AppLayout from './layout/AppLayout';

import logo from "./logo.png";
import "./App.css";

const drizzle = new Drizzle(drizzleOptions);

const App = () => {
  return (
    <AppLayout>
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
    </AppLayout>
  );
}

export default App;
