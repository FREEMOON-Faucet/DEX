#! /bin/bash

export DEPLOYER=0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export RPCURL=http://localhost:8545/
export WFSN=0x5fbdb2315678afecb367f032d93f642f64180aa3
export FACTORY=0xe7f1725e7734ce288f8367e1bb143e90bb3f0512
export ROUTER=0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0
export FMN=0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9
export FREE=0xdc64a140aa3e981100a9beca4e685f962f0cf6c9

pushd ../../time-wrapped-fusion/
./scripts/1_wfsn.sh
popd
./scripts/1_factory.sh
./scripts/2_router.sh
./scripts/3_tokenA.sh
./scripts/4_tokenB.sh

