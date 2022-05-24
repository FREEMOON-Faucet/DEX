#! /bin/bash

forge create \
src/mocks/MockFRC759.sol:MockFRC759 \
--rpc-url $RPCURL \
--private-key $PRIVATE_KEY \
--constructor-args "The FREE Token" "FREE"

