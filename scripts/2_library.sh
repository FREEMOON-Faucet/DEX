#! /bin/bash

forge create \
--legacy \
--gas-price 3gwei \
src/libraries/FreemoonDEXLibrary.sol:FreemoonDEXLibrary \
--rpc-url $RPCURL \
--private-key $PRIVATE_KEY

