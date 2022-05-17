// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;


interface IFreemoonDEXCallee {
    function uniswapV2Call(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata data) external;
}
