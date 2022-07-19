// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/FreemoonDEXFactory.sol";
import "../src/FreemoonDEXRouter.sol";
import "../src/FreemoonDEXVault.sol";


contract FreemoonDEXScript is Script {
    
    address wfsn = 0xABCDabcdABcDabcDaBCDAbcdABcdAbCdABcDABCd;

    function run() external {
        vm.startBroadcast();

        FreemoonDEXFactory factory = new FreemoonDEXFactory(msg.sender);
        FreemoonDEXRouter router = new FreemoonDEXRouter(address(factory), address(wfsn));
        FreemoonDEXVault vault = new FreemoonDEXVault(address(factory), address(wfsn));

        vm.stopBroadcast();
    }
}