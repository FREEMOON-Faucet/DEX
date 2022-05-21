// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "freemoon-frc759/interfaces/IFRC759.sol";

import "../src/FreemoonDEXFactory.sol";
import "../src/FreemoonDEXPair.sol";

import "../src/interfaces/IFRC20.sol";
import "../src/interfaces/IFreemoonDEXPair.sol";
import "../src/libraries/FreemoonDEXLibrary.sol";

import "../src/mocks/MockFRC759.sol";


contract FreemoonDEXFactoryTest is Test {
    MockFRC759 token0;
    MockFRC759 token1;
    IFreemoonDEXFactory factory;
    IFreemoonDEXPair pair;

    function setUp() public {
        MockFRC759 tokenA = new MockFRC759("Token A", "TKNA");
        MockFRC759 tokenB = new MockFRC759("Token B", "TKNB");
        (address token0Addr, address token1Addr) = FreemoonDEXLibrary.sortTokens(address(tokenA), address(tokenB));
        token0 = MockFRC759(token0Addr);
        token1 = MockFRC759(token1Addr);
        factory = new FreemoonDEXFactory(address(this));
        address pairAddr = factory.createPair(address(token0), address(token1));
        pair = IFreemoonDEXPair(pairAddr);

        token0.mint(address(this), 10 ether);
        token1.mint(address(this), 10 ether);
    }

    function testAllPairsLength() public {
        uint256 allPairsLength = factory.allPairsLength();
 
        assertEq(allPairsLength, 1);
    }

    function testGetPair() public {
        address pairAddr01 = factory.getPair(address(token0), address(token1));
        address pairAddr10 = factory.getPair(address(token1), address(token0));
       
        assertEq(address(pair), pairAddr01);
        assertEq(pairAddr01, pairAddr10);
    }

    function testCreatePair() public {
        MockFRC759 tokenC = new MockFRC759("Token C", "TKNC");
        MockFRC759 tokenD = new MockFRC759("Token D", "TKND");
        address createPair = factory.createPair(address(tokenC), address(tokenD));
        address createPairRef = FreemoonDEXLibrary.pairFor(address(factory), address(tokenC), address(tokenD));

        assertEq(createPair, createPairRef);
    }
}
