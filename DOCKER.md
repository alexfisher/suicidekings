# Overview

This repo uses `docker-compose` to run an isolated `truffle` console session against a local `ganache` instance.

To begin, run:
  1. `$ docker-compose build --force-rm --compress truffle`
  2. `$ docker-compose run --rm truffle`

## Details of `docker-compose`

There are two services which defined by this file:

  - `truffle`; and,
  - `ganache`

`truffle` depends on `ganche`, so the latter service will automatically be started before the former will work.

### `truffle` service

Again, to use:

  1. run the command: `$ docker-compose run --rm truffle`
  2. use the console: `$ truffle(ganache) > ...`

Running the service drops you into a `truffle-cli` console, and you can `compile`, `migrate`, etc. I have found the _Truffle_ documentation to be quite helpful from this point on: [Truffle Documentation](https://www.trufflesuite.com/docs/truffle/getting-started/interacting-with-your-contracts).

### What is shared between host & Docker?

`docker-compose` shares the `./contracts` folder, so any changes to `.sol` files on the host while the service is running will be reflected inside the container in real-time.

_**NOTE:**_: You will never see a `yarn.lock` or `node_modules` folder appear on your host machine; any external dependencies or tools (e.g., `openzeppelin`, or `truffle-cli`) are fetched when building the image, and persist only within the built image.

#### Rebuilding the image

Rebuilding the image is only necessary if `yarn` needs to perform some new action (such as `add`, `remove` dependencies), 
or if there's changes to files other than what's inside `./contracts` (such as `truffle-config.js`).

First, make whatever changes to `truffle-config.js` you need, or add a new `RUN yarn add ...` in the `Dockerfile`; then, to rebuild the container, run the command:

`$ docker-compose build truffle`

### Additional notes

Some key notes about the image:
  - it uses `node v11`;
  - it uses `yarn`;
  - starts up with `truffle console --network ganache`.

### `ganache` service

This service runs without requiring building any images. It will start automatically when attempting to run `truffle`. Lastly, don't be afraid to start/stop the service (`docker-compose run --rm truffle, and/or CTRL ^C`) as much as you'd like.

## `.env`  File

Be aware that `docker-compose` references values in the `.env` file. Some of these are described in the following sections; view `.env` for a complete list of defines.

### Setting a predefined mnemonic
Set `MNEMONIC` with a phrase that _Ganache_ can use to generate accounts deterministically.

### Fork a chain
Set `FORKCHAIN` in `.env` to start _Ganache_ with a forked chain of another node.
