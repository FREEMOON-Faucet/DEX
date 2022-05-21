// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/FreemoonDEXFactory.sol";
import "../src/FreemoonDEXPair.sol";

import "../src/interfaces/IFRC20.sol";
import "../src/libraries/FreemoonDEXLibrary.sol";

import "../src/mocks/MockFRC759.sol";
import "../src/mocks/TestUser.sol";


contract FreemoonDEXPairTest is Test {
    MockFRC759 token0;
    MockFRC759 token1;
    address pairAddr;
    IFreemoonDEXPair pair;
    TestUser testUser;
    
    function setUp() public {
        MockFRC759 tokenA = new MockFRC759("Token A", "TKNA");
        MockFRC759 tokenB = new MockFRC759("Token B", "TKNB");
        (address token0Addr, address token1Addr) = FreemoonDEXLibrary.sortTokens(address(tokenA), address(tokenB));
        token0 = MockFRC759(token0Addr);
        token1 = MockFRC759(token1Addr);
        testUser = new TestUser();
        FreemoonDEXFactory factory = new FreemoonDEXFactory(address(this));
        pairAddr = factory.createPair(address(token0), address(token1));
        pair = IFreemoonDEXPair(pairAddr);

        token0.mint(address(this), 10 ether);
        token1.mint(address(this), 10 ether);
        token0.mint(address(testUser), 10 ether);
        token1.mint(address(testUser), 10 ether);
    }

    function addLiquidity(uint256 amount0, uint256 amount1) public {
        token0.transfer(address(pair), amount0);
        token1.transfer(address(pair), amount1);
        pair.mint(address(this));
    }

    function removeLiquidity(uint256 liquidity) public {
        IFRC20(pairAddr).transfer(address(pair), liquidity);
        pair.burn(address(this));
    }

    function swap(uint256 in0, uint256 in1, uint256 out0, uint256 out1) public {
        token0.transfer(address(pair), in0);
        token1.transfer(address(pair), in1);
        pair.swap(out0, out1, address(this), new bytes(0));
    }

    function assertBalances(address account, uint256 expected0, uint256 expected1) public {
        (uint256 balance0, uint256 balance1) = balances(account);
        assertEq(balance0, expected0);
        assertEq(balance1, expected1);
    }

    function assertReserves(uint256 expected0, uint256 expected1) public {
        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();
        assertEq(uint256(reserve0), expected0);
        assertEq(uint256(reserve1), expected1);
    }

    function assertLpBalance(address account, uint256 expected) public {
        assertEq(IFRC20(pairAddr).balanceOf(account), expected);
    }

    function assertLpSupply(uint256 expected) public {
        assertEq(IFRC20(pairAddr).totalSupply(), expected);
    }

    function logBalance(uint256 balance) public view {
        console.log("BALANCE:", balance);
    }

    function logReserves(uint256 reserve0, uint256 reserve1) public view {
        console.log("RESERVES:", reserve0, reserve1);
    }

    function balances(address account) public view returns (uint256 balance0, uint256 balance1) {
        balance0 = token0.balanceOf(account);
        balance1 = token1.balanceOf(account);
    } 

    // MINT
    function testMintInitialLiquidity() public {
        (uint256 initialBal0, uint256 initialBal1) = balances(address(this));

        addLiquidity(1 ether, 1 ether);

        assertBalances(address(this), initialBal0 - 1 ether, initialBal1 - 1 ether);
        assertReserves(1 ether, 1 ether);
        assertLpSupply(1 ether);
        assertLpBalance(address(this), 1 ether - 1000);
        assertLpBalance(address(0), 1000);
    }

    function testMintBalancedLiquidity() public {
        (uint256 initialBal0, uint256 initialBal1) = balances(address(this));

        addLiquidity(1 ether, 1 ether);

        addLiquidity(1 ether, 1 ether);

        assertBalances(address(this), initialBal0 - 2 ether, initialBal1 - 2 ether);
        assertReserves(2 ether, 2 ether);
        assertLpSupply(2 ether);
        assertLpBalance(address(this), 2 ether - 1000);
    }

    function testMintUnbalancedLiquidity() public {
        (uint256 initialBal0, uint256 initialBal1) = balances(address(this));

        addLiquidity(1 ether, 1 ether);

        addLiquidity(2 ether, 1 ether);

        assertBalances(address(this), initialBal0 - 3 ether, initialBal1 - 2 ether);
        assertReserves(3 ether, 2 ether);
        assertLpSupply(2 ether);
        assertLpBalance(address(this), 2 ether - 1000);
    }

    // BURN
    function testBurnLiquidity() public {
        (uint256 initialBal0, uint256 initialBal1) = balances(address(this));

        addLiquidity(1 ether, 1 ether);

        removeLiquidity(1 ether - 1000);

        assertBalances(address(this), initialBal0 - 1000, initialBal1 - 1000);
        assertReserves(1000, 1000);
        assertLpSupply(1000);
        assertLpBalance(address(this), 0);
    }

    function testBurnUnbalancedLiquidity() public {
        (uint256 initialBal0, uint256 initialBal1) = balances(address(this));
        addLiquidity(1 ether, 1 ether);

        addLiquidity(2 ether, 1 ether);

        removeLiquidity(2 ether - 1000);

        assertBalances(address(this), initialBal0 - 1500, initialBal1 - 1000);
        assertReserves(1500, 1000);
        assertLpSupply(1000);
        assertLpBalance(address(this), 0);
    }

    function testBurnUnbalancedLiquidityUnowned() public {
        (uint256 initialBal0, uint256 initialBal1) = balances(address(this));
        (uint256 tuInitialBal0, uint256 tuInitialBal1) = balances(address(testUser));

        testUser.addLiquidity(address(pair), address(token0), address(token1), 1 ether, 1 ether);

        addLiquidity(2 ether, 1 ether);

        removeLiquidity(1 ether);

        testUser.removeLiquidity(address(pair), 1 ether - 1000);

        assertBalances(address(this), initialBal0 - 0.5 ether, initialBal1);
        assertBalances(address(testUser), tuInitialBal0 + 0.5 ether - 1500, tuInitialBal1 - 1000);
        assertReserves(1500, 1000);
        assertLpSupply(1000);
        assertLpBalance(address(this), 0);
        assertLpBalance(address(testUser), 0);
    }
}
