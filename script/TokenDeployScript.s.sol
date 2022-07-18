// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/MockFRC759.sol";

contract FreemoonDEXScript is Script {
    function run() external {
        vm.startBroadcast();

        MockFRC759 mockFrc759 = new MockFRC759("Fusion", "FSN");

        vm.stopBroadcast();
    }
}

