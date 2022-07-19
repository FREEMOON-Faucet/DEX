// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/FreemoonDEXVault.sol";


contract FreemoonDEXVaultScript is Script {    
    address factory = 0xABCDabcdABcDabcDaBCDAbcdABcdAbCdABcDABCd;
    address wfsn = 0xABCDabcdABcDabcDaBCDAbcdABcdAbCdABcDABCd;

    function run() external {
        vm.startBroadcast();

        FreemoonDEXVault vault = new FreemoonDEXVault(address(factory), address(wfsn));

        vm.stopBroadcast();
    }
}