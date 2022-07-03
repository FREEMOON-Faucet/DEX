// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "freemoon-frc759/interfaces/IFRC759.sol";

import "./interfaces/IFreemoonDEXVault.sol";
import "./interfaces/IFreemoonDEXFactory.sol";
import "./interfaces/IFreemoonDEXPair.sol";


contract FreemoonDEXVault is IFreemoonDEXVault {
    mapping(bytes32 => uint256) private _liquiditySliceBurned;
    mapping(bytes32 => mapping(address => uint256)) private _burnedBy;

    uint256 public constant MIN_TIME = 0;
    uint256 public constant MAX_TIME = 18446744073709551615;

    address public factory;

    uint256 private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, "FreemoonDEX: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(address factory_) {
        factory = factory_;
    }

    function burnLiquiditySlice(address tokenA, address tokenB, uint256 termEnd, uint256 amount) public lock {
        address pair = IFreemoonDEXFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) revert ZeroAddress();

        uint256 min = MIN_TIME; // gas savings
        uint256 max = MAX_TIME; // gas savings

        if (termEnd < min || termEnd > max) revert InvalidTermEnd();

        bytes32 liquiditySliceId = _getLiquiditySliceId(tokenA, tokenB, termEnd);
        _liquiditySliceBurned[liquiditySliceId] += amount;
        _burnedBy[liquiditySliceId][msg.sender] += amount;

        IFRC759(pair).transferFrom(msg.sender, address(this), amount);
        IFRC759(pair).sliceByTime(amount, termEnd);
        IFreemoonDEXPair(pair).burnSlice(address(this), amount, min, termEnd);
        IFRC759(pair).timeSliceTransfer(msg.sender, amount, termEnd, max);

        emit LiquiditySliceBurned(msg.sender, pair, termEnd, amount);
    }

    function liquiditySliceAmountBurned(address tokenA, address tokenB, uint256 termEnd) public view returns (uint256) {
        address pair = IFreemoonDEXFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) return 0;

        bytes32 liquiditySliceId = _getLiquiditySliceId(tokenA, tokenB, termEnd);
        return _liquiditySliceBurned[liquiditySliceId];
    }

    function burnedBy(address tokenA, address tokenB, uint256 termEnd, address account) public view returns (uint256) {
        address pair = IFreemoonDEXFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) return 0;

        bytes32 liquiditySliceId = _getLiquiditySliceId(tokenA, tokenB, termEnd);
        return _burnedBy[liquiditySliceId][account];
    }    

    // PRIVATE
    function _sortTokens(address tokenA, address tokenB) private pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
    
    function _getLiquiditySliceId(address tokenA, address tokenB, uint256 termEnd) private pure returns (bytes32) {
        (address token0, address token1) = _sortTokens(tokenA, tokenB);
        return bytes32(keccak256(abi.encodePacked(token0, token1, termEnd)));
    }
}

