// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/Terms.sol";


contract TermsScript is Script {
    address admin = 0x3eC6124e79383f759fC7b411ABFDF4dCB9A67d1A;

    function run() external {
        vm.startBroadcast();

        Terms terms = new Terms(admin);

        vm.stopBroadcast();
    }
}