// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./interfaces/IFreemoonDEXPair.sol";
import "./interfaces/IFRC20.sol";


contract TestUser {
    function addLiquidity(
        address pair,
        address token0,
        address token1,
        uint256 amount0,
        uint256 amount1
    ) public {
        IFRC20(token0).transfer(pair, amount0);
        IFRC20(token1).transfer(pair, amount1);
        IFreemoonDEXPair(pair).mint(address(this));
    }

    function removeLiquidity(
        address pair,
        uint256 liquidity
    ) public {
        IFRC20(pair).transfer(pair, liquidity);
        IFreemoonDEXPair(pair).burn(address(this));
    }
}