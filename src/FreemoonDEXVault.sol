// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "freemoon-frc759/interfaces/IFRC759.sol";

import "./interfaces/IFreemoonDEXVault.sol";
import "./interfaces/IFreemoonDEXFactory.sol";
import "./interfaces/IFreemoonDEXPair.sol";


contract FreemoonDEXVault is IFreemoonDEXVault {
    mapping(bytes32 => uint256) public positionAmount;
    mapping(address => mapping(address => uint256)) public pairAmount;

    uint256 public constant MIN_TIME = 0;
    uint256 public constant MAX_TIME = 18446744073709551615;

    address public factory;

    constructor(address factory_) {
        factory = factory_;
    }

    function burnLiquiditySlice(address tokenA, address tokenB, uint256 termEnd, uint256 amount) public {
        address pair = IFreemoonDEXFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) revert ZeroAddress();

        (address token0, address token1) = _sortTokens(tokenA, tokenB);

        uint256 min = MIN_TIME; // gas savings
        uint256 max = MAX_TIME; // gas savings

        if (termEnd < min || termEnd > max) revert InvalidTermEnd();

        bytes32 position = _getPositionId(msg.sender, pair, termEnd);
        positionAmount[position] += amount;
        pairAmount[token0][token1] += amount;

        IFRC759(pair).transferFrom(msg.sender, address(this), amount);
        IFRC759(pair).sliceByTime(amount, termEnd);
        IFreemoonDEXPair(pair).burnSlice(address(this), amount, min, termEnd);
        IFRC759(pair).timeSliceTransfer(msg.sender, amount, termEnd, max);

        emit LiquiditySliceBurned(msg.sender, token0, token1, pair, termEnd, amount);
    }

    function burnedAtPosition(address account, address tokenA, address tokenB, uint256 termEnd) public view returns (uint256) {
        address pair = IFreemoonDEXFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) return 0;

        bytes32 position = _getPositionId(account, pair, termEnd);
        return positionAmount[position];
    }

    // PRIVATE    
    function _getPositionId(address account, address pair, uint256 termEnd) private pure returns (bytes32) {
        return bytes32(keccak256(abi.encodePacked(account, pair, termEnd)));
    }

    function _sortTokens(address tokenA, address tokenB) private pure returns (address token0, address token1) {
        if (tokenA == tokenB) revert IdenticalAddresses();
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (token0 == address(0)) revert ZeroAddress();
    }
}

