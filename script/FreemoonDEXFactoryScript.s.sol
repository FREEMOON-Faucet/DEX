// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/FreemoonDEXFactory.sol";


contract FreemoonDEXFactoryScript is Script {
    function run() external {
        vm.startBroadcast();

        FreemoonDEXFactory factory = new FreemoonDEXFactory(msg.sender);

        vm.stopBroadcast();
    }
}