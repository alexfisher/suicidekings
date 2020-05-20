// Frameworks
import React, { useContext, useEffect, useState } from 'react';
// import { ToastContainer } from 'react-toastify';
import * as _ from 'lodash';

// Material UI
import { ThemeProvider } from '@material-ui/core/styles';
import CssBaseline from '@material-ui/core/CssBaseline';
import Drawer from '@material-ui/core/Drawer';
import Hidden from '@material-ui/core/Hidden';

// Rimble UI
import { theme as rimbleTheme } from 'rimble-ui';

// Custom Styles
import './styles/app.overrides.css';
import theme from '../layout/styles/root.theme.js';
import useRootStyles from './styles/app.root.styles';

// App Components
import siteOptions from '../utils/site-options';
/*
import Wallet from '../wallets';
import { Helpers } from '../../utils/helpers';
import { GLOBALS } from '../../utils/globals';
import { Sidemenu } from '../components/Sidemenu';
*/

import { HeaderBar } from '../components/HeaderBar';

// REFERENCE
// https://github.com/robsecord/ChargedParticlesWeb/blob/master/src/app/layout/AppLayout.js

// Contract Data
/*
import {
    ChargedParticles,
    ChargedParticlesEscrow
} from '../blockchain/contracts';
import ChargedParticlesData from '../blockchain/contracts/ChargedParticles';
import ChargedParticlesEscrowData from '../blockchain/contracts/ChargedParticlesEscrow';

// Transactions Monitor
import Transactions from '../blockchain/transactions';
import TxStreamView from '../components/TxStreamView.js';

// Data Context for State
import { RootContext } from '../stores/root.store';
import { WalletContext } from '../stores/wallet.store';
import { TransactionContext } from '../stores/transaction.store';
*/


function AppLayout({ children }) {
    const classes = useRootStyles();
		/*
    const wallet = Wallet.instance();
    const [, rootDispatch] = useContext(RootContext);
    const [, txDispatch] = useContext(TransactionContext);
    const [walletState, walletDispatch] = useContext(WalletContext);
    const [mobileOpen, setMobileOpen] = useState(false);
    const { allReady: isWalletReady, networkId } = walletState;
    const siteTitle = siteOptions.metadata.title;
		*/

		/*
    const data = useStaticQuery(graphql`
        query SiteDataQuery {
            site {
                siteMetadata {
                    title
                    logoUrl
                }
            }
        }
    `);

    const correctNetwork = _.parseInt(GLOBALS.CHAIN_ID, 10);
    const correctNetworkName = _.upperFirst(Helpers.getNetworkName(correctNetwork));
		*/

		/*
    // Prepare Wallet Interface
    useEffect(() => {
        wallet.init({
            walletDispatch,
            siteTitle: data.site.siteMetadata.title,
            siteLogoUrl: data.site.siteMetadata.logoUrl
        });
    }, [wallet, walletDispatch]);

    // Reconnect to Contracts on network change
    useEffect(() => {
        if (isWalletReady) {
            const web3 = wallet.getWeb3();

            const chargedParticlesAddress = _.get(ChargedParticlesData.networks[networkId], 'address', '');
            const chargedParticlesEscrowAddress = _.get(ChargedParticlesEscrowData.networks[networkId], 'address', '');

            ChargedParticles.prepare({web3, address: chargedParticlesAddress});
            ChargedParticles.instance();

            ChargedParticlesEscrow.prepare({web3, address: chargedParticlesEscrowAddress});
            ChargedParticlesEscrow.instance();

            const transactions = Transactions.instance();
            transactions.init({rootDispatch, txDispatch});
            transactions.connectToNetwork({networkId});
            transactions.resumeIncompleteStreams();
        }
    }, [isWalletReady, networkId, wallet]);

    useEffect(() => {
        const isModernWeb3 = !!window.ethereum;
        const isLegacyWeb3 = (typeof window.web3 !== 'undefined');

        if (!isLegacyWeb3 && !isModernWeb3) {
            rootDispatch({type: 'CONNECTION_STATE', payload: {type: 'NON_WEB3', message: 'Not a Web3 capable browser'}});
        } else if (_.isUndefined(networkId) || networkId === 0) {
            rootDispatch({type: 'CONNECTION_STATE', payload: {type: 'WEB3_DISCONNECTED', message: 'Please connect your Web3 Wallet'}});
        } else if (networkId !== correctNetwork) {
            rootDispatch({type: 'CONNECTION_STATE', payload: {type: 'WEB3_WRONG_NETWORK', message: `Wrong Ethereum network, please connect to ${correctNetworkName}.`}});
        } else {
            rootDispatch({type: 'CONNECTION_STATE', payload: {}}); // Web3, Connected, Correct Network
        }
    }, [networkId, rootDispatch]);


		*/

    const _handleDrawerToggle = () => {
      alert('Alex Rules');
    };


    const _handleCloseDrawer = () => {
      alert('Alex Rules');
    };

    return (
        <ThemeProvider theme={{...rimbleTheme, ...theme}}>
            <div className={classes.root}>
                <HeaderBar
                    title={"SuicideKings"}
                    drawerToggle={_handleDrawerToggle}
                />
								<main className={classes.content}>
                    <div className={classes.toolbar} />
                    {children}
                </main>
								{/*
                <CssBaseline />
                <Hidden mdUp implementation="css">
                    <nav className={classes.drawer} aria-label="mailbox folders">
                        <Drawer
                            variant="temporary"
                            anchor={theme.direction === 'rtl' ? 'right' : 'left'}
                            open={mobileOpen}
                            onClose={_handleDrawerToggle}
                            classes={{
                                paper: classes.drawerPaper,
                            }}
                            ModalProps={{
                                keepMounted: true, // Better open performance on mobile.
                            }}
                        >
                            <Sidemenu title={siteTitle} closeDrawer={_handleCloseDrawer} />
                        </Drawer>
                    </nav>
                </Hidden>
                <main className={classes.content}>
                    <div className={classes.toolbar} />
                    {children}
                    <TxStreamView />
                </main>
						*/}
            </div>
						{/*
            <ToastContainer
                position="top-right"
                autoClose={5000}
                hideProgressBar={false}
                newestOnTop={true}
                closeOnClick
                rtl={false}
                draggable
                pauseOnHover
            />
						*/}
        </ThemeProvider>
    );
}

export default AppLayout;
