#! /bin/bash

read -p "Deployer address: " DEP
read -p "Deployer PK: " PK
read -p "RPC URL: " RPCURL

read -p "Wrapped Fusion Address: " WFSN

export DEPLOYER=$DEP
export PRIVATE_KEY=$PK
export RPCURL=$RPCURL
export WFSN=$WFSN
