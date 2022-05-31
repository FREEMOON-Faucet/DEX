#! /bin/bash

forge create \
--legacy \
--gas-price 3gwei \
src/FreemoonDEXFactory.sol:FreemoonDEXFactory \
--rpc-url $RPCURL \
--private-key $PRIVATE_KEY \
--constructor-args $DEPLOYER \
