#! /bin/bash
forge create \
src/FreemoonDEXFactory.sol:FreemoonDEXFactory \
--rpc-url $RPCURL \
--private-key $PRIVATE_KEY \
--constructor-args $DEPLOYER
