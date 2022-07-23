// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/FreemoonDEXFactory.sol";


contract FreemoonDEXFactoryScript is Script {
    address admin = 0x3eC6124e79383f759fC7b411ABFDF4dCB9A67d1A;

    function run() external {
        vm.startBroadcast();

        FreemoonDEXFactory factory = new FreemoonDEXFactory(admin);

        vm.stopBroadcast();
    }
}