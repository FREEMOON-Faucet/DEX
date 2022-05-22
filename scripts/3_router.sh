#! /bin/bash
forge create \
src/FreemoonDEXRouter.sol:FreemoonDEXRouter \
--rpc-url $RPCURL \
--private-key $PRIVATE_KEY \
--constructor-args $FACTORY $WFSN
