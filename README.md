# Suicide Kings
![Suicide Kings Logo](/app/src/logo.png)

## Quickstart Instructions ##
Prerequisites/Versions I've used:

* Ubuntu 18.04
* Node v10.20.1
* npm 6.14.5  
* truffle v5.1.24 (`npm install -g truffle`)
* ganache-cli v6.9.1 (`npm install -g ganache-cli`)

To get the project running:

1. Download git repo locally and optionally _Open folder_ in Visual Studio

2. Terminal #1 - Run ganache-cli in deterministic mode on port 8545

`ganache-cli -d`

3. Terminal #2 - Start truffle and connect to ganache blockchain

`truffle console --network develop`

4. Terminal #3 - Run the react front-end at http://localhost:3000

`cd app`

`npm run start`

## More Information ##
* Initially, the dapp just looks for a web3 instance running at localhost:8545, but we'll be updating it soon to use Metamask, Web3Modal, or something else.

* The project currently uses Open Zeppelin 2.5.1 even though the latest version is 3.x (you can confirm via `npm list`).

* Notes on how I built the initial project skeleton with React, Drizzle, Truffle, and Open Zeppelin's libraries [can be found in our team folder](https://docs.google.com/document/d/1I7B9iST4kpjjlLcyr6ArD9XWojdH8XJXWWMRTyZ4SWQ/edit) on Google Drive.
