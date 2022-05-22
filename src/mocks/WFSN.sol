// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";


contract WFSN is ERC20 {
    error AmountExceedsBalance();
    error SafeTransferFailed();

    constructor() ERC20("Wrapped Fusion", "WFSN", 18) {}

    receive() external payable {
        _mint(msg.sender, msg.value);
    }

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 value) external payable {
        uint256 balance = balanceOf[msg.sender]; // gas savings
        if (balance < value) revert AmountExceedsBalance();
        _burn(msg.sender, value);
        (bool success, ) = msg.sender.call{value: value}(new bytes(0));
        if (!success) revert SafeTransferFailed();
    }
}
