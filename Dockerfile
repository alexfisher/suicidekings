FROM node:11

WORKDIR /truffle

RUN yarn add truffle \
      @truffle/hdwallet-provider \
      @openzeppelin/contracts@2.5.1 \
      multi-token-standard

COPY ./migrations ./migrations
COPY ./secrets.json .
COPY ./test ./test
COPY ./truffle-config.js .

ENTRYPOINT yarn run truffle console --network docker
