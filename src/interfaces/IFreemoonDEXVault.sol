// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;


interface IFreemoonDEXVault {
    event LiquiditySliceBurned(address indexed account, address indexed pair, uint256 termEnd, uint256 amount);

    error InvalidTermEnd();
    error IdenticalAddresses();
    error ZeroAddress();

    function liquiditySliceAmountBurned(address tokenA, address tokenB, uint256 termEnd) external view returns (uint256);
    function burnedBy(address tokenA, address tokenB, uint256 termEnd, address account) external view returns (uint256);

    function MIN_TIME() external view returns (uint256);
    function MAX_TIME() external view returns (uint256);

    function factory() external view returns (address);
 
    function burnLiquiditySlice(address tokenA, address tokenB, uint256 termEnd, uint256 amount) external;
}

