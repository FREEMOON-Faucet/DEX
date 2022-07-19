// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/FreemoonDEXRouter.sol";


contract FreemoonDEXRouterScript is Script {    
    address factory = 0xABCDabcdABcDabcDaBCDAbcdABcdAbCdABcDABCd;
    address wfsn = 0xABCDabcdABcDabcDaBCDAbcdABcdAbCdABcDABCd;

    function run() external {
        vm.startBroadcast();

        FreemoonDEXRouter router = new FreemoonDEXRouter(address(factory), address(wfsn));

        vm.stopBroadcast();
    }
}