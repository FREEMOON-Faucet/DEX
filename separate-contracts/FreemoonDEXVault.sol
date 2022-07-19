// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "freemoon-frc759/interfaces/IFRC759.sol";

import "./interfaces/IFreemoonDEXVault.sol";
import "./interfaces/IFreemoonDEXFactory.sol";
import "./interfaces/IFreemoonDEXPair.sol";


contract FreemoonDEXVault is IFreemoonDEXVault {
    mapping(bytes32 => uint256) private _idLiquiditySliceBurned;
    mapping(bytes32 => mapping(address => uint256)) private _idBurnedBy;

    uint256 public constant MIN_TIME = 0;
    uint256 public constant MAX_TIME = 18446744073709551615;

    address public factory;
    address public wfsn;

    uint256 private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, "FreemoonDEX: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor(address factory_, address wfsn_) {
        factory = factory_;
        wfsn = wfsn_;
    }

    function burnLiquiditySliceETH(address token, uint256 amount, uint256 termEnd) external lock {
        _burnLiquiditySlice(token, wfsn, amount, termEnd);
    }

    function burnLiquiditySlice(address tokenA, address tokenB, uint256 amount, uint256 termEnd) external lock {
        _burnLiquiditySlice(tokenA, tokenB, amount, termEnd);
    }

    function liquiditySliceAmountBurnedETH(address token, uint256 termEnd) external view returns (uint256) {
        return _liquiditySliceAmountBurned(token, wfsn, termEnd);
    }

    function liquiditySliceAmountBurned(address tokenA, address tokenB, uint256 termEnd) external view returns (uint256) {
        return _liquiditySliceAmountBurned(tokenA, tokenB, termEnd);
    }

    function burnedByETH(address token, uint256 termEnd, address account) external view returns (uint256) {
        return _burnedBy(token, wfsn, termEnd, account);
    }

    function burnedBy(address tokenA, address tokenB, uint256 termEnd, address account) external view returns (uint256) {
        return _burnedBy(tokenA, tokenB, termEnd, account);
    }

    // PRIVATE
    function _burnLiquiditySlice(address tokenA, address tokenB, uint256 amount, uint256 termEnd) private {
        address pair = IFreemoonDEXFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) revert ZeroAddress();

        uint256 min = MIN_TIME; // gas savings
        uint256 max = MAX_TIME; // gas savings

        if (termEnd < min || termEnd > max) revert InvalidTermEnd();

        bytes32 liquiditySliceId = _getLiquiditySliceId(tokenA, tokenB, termEnd);
        _idLiquiditySliceBurned[liquiditySliceId] += amount;
        _idBurnedBy[liquiditySliceId][msg.sender] += amount;

        IFRC759(pair).transferFrom(msg.sender, address(this), amount);
        IFRC759(pair).sliceByTime(amount, termEnd);
        IFreemoonDEXPair(pair).burnSlice(address(this), amount, min, termEnd);
        IFRC759(pair).timeSliceTransfer(msg.sender, amount, termEnd, max);

        emit LiquiditySliceBurned(msg.sender, pair, amount, termEnd);
    }

    function _liquiditySliceAmountBurned(address tokenA, address tokenB, uint256 termEnd) private view returns (uint256) {
        address pair = IFreemoonDEXFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) return 0;

        bytes32 liquiditySliceId = _getLiquiditySliceId(tokenA, tokenB, termEnd);
        return _idLiquiditySliceBurned[liquiditySliceId];
    }

    function _burnedBy(address tokenA, address tokenB, uint256 termEnd, address account) private view returns (uint256) {
        address pair = IFreemoonDEXFactory(factory).getPair(tokenA, tokenB);
        if (pair == address(0)) return 0;

        bytes32 liquiditySliceId = _getLiquiditySliceId(tokenA, tokenB, termEnd);
        return _idBurnedBy[liquiditySliceId][account];
    }

    function _sortTokens(address tokenA, address tokenB) private pure returns (address token0, address token1) {
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }
    
    function _getLiquiditySliceId(address tokenA, address tokenB, uint256 termEnd) private pure returns (bytes32) {
        (address token0, address token1) = _sortTokens(tokenA, tokenB);
        return bytes32(keccak256(abi.encodePacked(token0, token1, termEnd)));
    }
}