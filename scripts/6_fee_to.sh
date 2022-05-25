#! /bin/bash

cast send \
$FACTORY \
"setFeeTo(address)()" \
$ADDRESS_USER \
--legacy \
--gas-price 3gwei \
--rpc-url $RPCURL \
--private-key $PRIVATE_KEY \

