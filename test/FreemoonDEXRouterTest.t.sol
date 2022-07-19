// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

// import "forge-std/Test.sol";

// import "time-wrapped-fusion/WFSN.sol";
// import "../src/FreemoonDEXRouter.sol";


// contract MockFRC759 is FRC759 {
//     constructor(string memory name, string memory symbol) FRC759(name, symbol, 18, type(uint256).max) {}

//     function mint(address to, uint256 amount) public {
//         _mint(to, amount);
//     }
// }


// contract FreemoonDEXRouterTest is Test {
//     MockFRC759 token0;
//     MockFRC759 token1;
//     FreemoonDEXRouter router;

//     function setUp() public {
//         MockFRC759 tokenA = new MockFRC759("Token A", "TKNA");
//         MockFRC759 tokenB = new MockFRC759("Token B", "TKNB");
//         (address token0Addr, address token1Addr) = FreemoonDEXLibrary.sortTokens(address(tokenA), address(tokenB));
//         token0 = MockFRC759(token0Addr);
//         token1 = MockFRC759(token1Addr);
//         FreemoonDEXFactory factory = new FreemoonDEXFactory(msg.sender);
//         WFSN wfsn = new WFSN();
//         router = new FreemoonDEXRouter(address(factory), address(wfsn));

//         token0.mint(address(this), 1000 ether);
//         token1.mint(address(this), 100000000 ether);

//         token0.approve(address(router), uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff));
//         token1.approve(address(router), uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff));
//     }

//     function testAddLiquidity() public {
//         (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidity(address(token0), address(token1), 0.01 ether, 100000 ether, 0.01 ether, 100000 ether, address(this), block.timestamp + 600);
//         console.log(amountA, amountB, liquidity);
//     }
// }