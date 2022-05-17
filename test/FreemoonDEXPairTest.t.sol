// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/interfaces/IFRC20.sol";
import "../src/mocks/MockFRC759.sol";
import "../src/FreemoonDEXPair.sol";


contract TestUser {
    function provideLiquidity(
        address pair_,
        address token0_,
        address token1_, 
        uint256 amount0,
        uint256 amount1
    ) public
    {
        IFRC20(token0_).transfer(pair_, amount0);
        IFRC20(token1_).transfer(pair_, amount1);
        IFreemoonDEXPair(pair_).mint(address(this));
    }
}

contract FreemoonDEXPairTest is Test {
    MockFRC759 token0;
    MockFRC759 token1;
    FreemoonDEXPair pair;
    TestUser testUser;
    
    function setUp() public {
        token0 = new MockFRC759("Token A", "TKNA");
        token1 = new MockFRC759("Token B", "TKNB");
        token0.mint(address(this), 10 ether);
        token1.mint(address(this), 10 ether);

        pair = new FreemoonDEXPair();
        pair.initialize(address(token0), address(token1));

        testUser = new TestUser();
    }

    function addLiquidity(uint256 amount0, uint256 amount1) public {
        token0.transfer(address(pair), amount0);
        token1.transfer(address(pair), amount1);
        pair.mint(address(this));
    }

    function removeLiquidity(uint256 liquidity) public {
        pair.transfer(address(pair), liquidity);
        pair.burn(address(this));
    }

    function assertReserves(uint256 expected0, uint256 expected1) public {
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        assertEq(uint256(reserve0), expected0);
        assertEq(uint256(reserve1), expected1);
    }

    function logBalance(address account, address token) public view {
        console.log("BALANCE:", IFRC20(token).balanceOf(account));
    }

    function logReserves() public view {
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        console.log("RESERVES:", reserve0, reserve1);
    }

    // MINT
    function testMintInitialLiquidity() public {
        addLiquidity(1 ether, 1 ether);

        assertReserves(1 ether, 1 ether);
        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);
        assertEq(pair.totalSupply(), 1 ether);
    }

    function testMintBalancedLiquidity() public {
        addLiquidity(1 ether, 1 ether);

        assertReserves(1 ether, 1 ether);
        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);

        addLiquidity(1 ether, 1 ether);

        assertReserves(2 ether, 2 ether);
        assertEq(pair.balanceOf(address(this)), 2 ether - 1000);
        assertEq(pair.totalSupply(), 2 ether);
    }

    function testMintUnbalancedLiquidity() public {
        addLiquidity(1 ether, 1 ether);

        assertReserves(1 ether, 1 ether);
        assertEq(pair.balanceOf(address(this)), 1 ether - 1000);

        addLiquidity(2 ether, 1 ether);

        assertReserves(3 ether, 2 ether);
        assertEq(pair.balanceOf(address(this)), 2 ether - 1000);
        assertEq(pair.totalSupply(), 2 ether);
    }

    // BURN
    function testBurnLiquidity() public {
        addLiquidity(1 ether, 1 ether);

        assertReserves(1 ether, 1 ether);
        assertEq(token0.balanceOf(address(pair)), 1 ether);
        assertEq(token1.balanceOf(address(pair)), 1 ether);

        removeLiquidity(1 ether - 1000);

        assertReserves(1000, 1000);
        assertEq(token0.balanceOf(address(pair)), 1000);
        assertEq(token1.balanceOf(address(pair)), 1000);
    }
}
