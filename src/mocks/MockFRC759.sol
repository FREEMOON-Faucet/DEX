// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "freemoon-frc759/FRC759.sol";


contract MockFRC759 is FRC759 {
    address public deployer;

    constructor(string memory name, string memory symbol) FRC759(name, symbol, 18, type(uint256).max) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

