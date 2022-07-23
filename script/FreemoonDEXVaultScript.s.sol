// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/FreemoonDEXVault.sol";


contract FreemoonDEXVaultScript is Script {
    address factory = 0x43958B7B6bDC198Fe2381049e2A408081269bDfc;
    address wfsn = 0x0C05C5710aF74D36B4d3BD5460475c20CEcA8FE3;

    function run() external {
        vm.startBroadcast();

        FreemoonDEXVault vault = new FreemoonDEXVault(address(factory), address(wfsn));

        vm.stopBroadcast();
    }
}