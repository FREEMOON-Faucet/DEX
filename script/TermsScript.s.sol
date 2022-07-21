// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/Terms.sol";


contract TermsScript is Script {
    address admin = 0xabcABACBaCBacBacBACBAcbaCbacBACbAcBacBAc;

    function run() external {
        vm.startBroadcast();

        Terms terms = new Terms(admin);

        vm.stopBroadcast();
    }
}