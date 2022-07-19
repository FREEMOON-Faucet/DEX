// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "freemoon-frc759/interfaces/IFRC759.sol";
// import "time-wrapped-fusion/WFSN.sol";
// import "time-wrapped-fusion/interfaces/IWFSN.sol";

// import "../src/FreemoonDEXFactory.sol";
// import "../src/FreemoonDEXVault.sol";

// import "../src/interfaces/IFreemoonDEXPair.sol";
// import "../src/interfaces/IFreemoonDEXFactory.sol";
// import "../src/libraries/FreemoonDEXLibrary.sol";

// import "../src/MockFRC759.sol";


// contract FreemoonDEXVaultTest is Test {
//     MockFRC759 token0;
//     MockFRC759 token1;
//     IWFSN wfsn;
//     IFreemoonDEXFactory factory;
//     IFreemoonDEXPair pair;
//     IFreemoonDEXPair pairETH;
//     IFreemoonDEXVault vault;

//     uint256 termEnd = 1672531199;
//     uint256 min;
//     uint256 max;

//     function setUp() public {
//         MockFRC759 tokenA = new MockFRC759("Token A", "TKNA");
//         MockFRC759 tokenB = new MockFRC759("Token B", "TKNB");
//         (address token0Addr, address token1Addr) = FreemoonDEXLibrary.sortTokens(address(tokenA), address(tokenB));
//         token0 = MockFRC759(token0Addr);
//         token1 = MockFRC759(token1Addr);
 
//         wfsn = new WFSN();

//         factory = new FreemoonDEXFactory(address(this));

//         address pairAddr = factory.createPair(address(token0), address(token1));
//         pair = IFreemoonDEXPair(pairAddr);
//         address pairETHAddr = factory.createPair(address(token0), address(wfsn));
//         pairETH = IFreemoonDEXPair(pairETHAddr);

//         vault = new FreemoonDEXVault(address(factory), address(wfsn));
//         min = vault.MIN_TIME();
//         max = vault.MAX_TIME();

//         token0.mint(address(this), 10 ether);
//         token1.mint(address(this), 10 ether);
//     }

//     function testBurnLiquiditySlice() public {
//         token0.transfer(address(pair), 1 ether);
//         token1.transfer(address(pair), 1 ether);

//         pair.mint(address(this));
//         IFRC20(address(pair)).approve(address(vault), 1 ether - 1000);

//         uint256 pairFullBalanceBefore = IFRC20(address(pair)).balanceOf(address(this));

//         vault.burnLiquiditySlice(address(token0), address(token1), 1 ether - 1000, termEnd);

//         uint256 pairFullBalanceAfter = IFRC20(address(pair)).balanceOf(address(this));
//         uint256 pairTimeBalanceAfter = IFRC759(address(pair)).timeBalanceOf(address(this), termEnd, max);

//         assertEq(pairFullBalanceBefore, 1 ether - 1000);
//         assertEq(pairFullBalanceAfter, 0);
//         assertEq(pairTimeBalanceAfter, 1 ether - 1000);

//         uint256 burnedByAfter = vault.burnedBy(address(token0), address(token1), termEnd, address(this));
//         uint256 liquiditySliceAmountBurned = vault.liquiditySliceAmountBurned(address(token0), address(token1), termEnd);

//         assertEq(burnedByAfter, 1 ether - 1000);
//         assertEq(liquiditySliceAmountBurned, 1 ether - 1000);
//     }

//     function testBurnLiquiditySliceETH() public {
//         wfsn.deposit{value: 1 ether}();

//         token0.transfer(address(pairETH), 1 ether);
//         wfsn.transfer(address(pairETH), 1 ether);

//         pairETH.mint(address(this));
//         IFRC20(address(pairETH)).approve(address(vault), 1 ether - 1000);

//         uint256 pairFullBalanceBefore = IFRC20(address(pairETH)).balanceOf(address(this));

//         vault.burnLiquiditySliceETH(address(token0), 1 ether - 1000, termEnd);

//         uint256 pairFullBalanceAfter = IFRC20(address(pairETH)).balanceOf(address(this));
//         uint256 pairTimeBalanceAfter = IFRC759(address(pairETH)).timeBalanceOf(address(this), termEnd, max);

//         assertEq(pairFullBalanceBefore, 1 ether - 1000);
//         assertEq(pairFullBalanceAfter, 0);
//         assertEq(pairTimeBalanceAfter, 1 ether - 1000);

//         uint256 burnedByAfter = vault.burnedByETH(address(token0), termEnd, address(this));
//         uint256 liquiditySliceAmountBurned = vault.liquiditySliceAmountBurnedETH(address(token0), termEnd);

//         assertEq(burnedByAfter, 1 ether - 1000);
//         assertEq(liquiditySliceAmountBurned, 1 ether - 1000);
//     }

// }