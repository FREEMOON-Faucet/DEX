#! /bin/bash

forge create \
--legacy \
--gas-price 3gwei \
src/FreemoonDEXRouter.sol:FreemoonDEXRouter \
--rpc-url $RPCURL \
--private-key $PRIVATE_KEY \
--constructor-args $FACTORY $WFSN \

