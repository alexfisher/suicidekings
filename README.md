# Suicide Kings
![Suicide Kings Logo](/app/src/logo.png)

HackMoney 2020 Hackathon Project

Group Members: Alex Fisher, Wade Kimbrough, Kevin Vitale

## Quickstart Instructions ##
Prerequisites/Versions I've used:

* Ubuntu 18.04, Windows 10
* VSCode 1.44.2 (w/ extensions: solidity 0.0.72, Solidity Contract Flattener 0.0.7, Solidity Visual Auditor 0.0.24)
* Node v10.20.1
* npm 6.14.5  
* truffle v5.1.24 (`npm install -g truffle`)
* ganache-cli v6.9.1 (`npm install -g ganache-cli`)

To get the project running:

1. Download git repo locally and optionally _Open folder_ in Visual Studio

2. Terminal #1 - Install project dependencies

`npm install`

3. Terminal #1 - Run ganache-cli in deterministic mode on port 8545

`ganache-cli -d`

4. Terminal #2 - Start truffle,  compile/migrate the project to the blockchain

`truffle console --network develop`

_truffle(develop)>_`migrate --reset`

5. Terminal #3 - Install dependencies and run the react front-end at http://localhost:3000

`cd app`

`npm install`

`npm run start`

## Running on Local Blockchain Forked from Mainnet ##

1. Start Ganache-cli (terminal 1):

`ganache-cli -f https://mainnet.infura.io/v3/3b0206f022a6462cacf91dc79e2b9833 -m "myth like bonus scare over problem client lizard pioneer submit female collect" -i 999`

2. Connect on Truffle and deploy (terminal 2):

`truffle console --network mainnetfork`

`migrate`

3. Start web app (terminal 3):

`cd app`

`npm run start`

4. Configure Metamask:

Seed with the same mnemonic as you used in ganache-cli, and change network to use localhost:8545 and Network ID 999.

## Running on Testnets/Infura ##
Create a `secrets.json` file in the project root (same level as truffle-config.js).  It should contain a mnemonic (you can generate via ganache/ganache-cli) and infura API Key (sign-up for free at infura.io)

```
{
  "mnemonic": "iron skate call erode fly crunch spirit minute cloth advice horse smooth",
  "infuraApiKey": "3b0206f022a6462cacf91dc79e2b9833"
}
```
Then, be sure to start truffle using:

`truffle console --network kovan`

Also support for `ropsten`, but it has been very slow lately.  Like, Bitcoin slow.

And, in your browser be sure to switch Metamask to Ropsten and seed it with the correct mnemonic (Logout and Restore).

## More Information ##
* Initially, the dapp just looks for a web3 instance running at localhost:8545, but we'll be updating it soon to use Metamask, Web3Modal, or something else.

* The project currently uses Open Zeppelin 2.5.1 even though the latest version is 3.x (you can confirm via `npm list`).

* Notes on how I built the initial project skeleton with React, Drizzle, Truffle, and Open Zeppelin's libraries [can be found in our team folder](https://docs.google.com/document/d/1I7B9iST4kpjjlLcyr6ArD9XWojdH8XJXWWMRTyZ4SWQ/edit) on Google Drive.
