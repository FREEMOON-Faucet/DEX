// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "time-wrapped-fusion/WFSN.sol";

import "../src/FreemoonDEXFactory.sol";
import "../src/FreemoonDEXRouter.sol";
import "../src/FreemoonDEXVault.sol";


contract FreemoonDEXScript is Script {
    function run() external {
        vm.startBroadcast();

        WFSN wfsn = new WFSN();
        FreemoonDEXFactory factory = new FreemoonDEXFactory(msg.sender);
        FreemoonDEXRouter router = new FreemoonDEXRouter(address(factory), address(wfsn));
        FreemoonDEXVault vault = new FreemoonDEXVault(address(factory), address(wfsn));

        vm.stopBroadcast();
    }
}

