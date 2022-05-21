// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./interfaces/IFreemoonDEXFactory.sol";
import "./FreemoonDEXPair.sol";


contract FreemoonDEXFactory is IFreemoonDEXFactory {

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    modifier forbidden() {
        if (msg.sender != feeToSetter) revert Forbidden();
        _;
    }

    constructor(address feeToSetter_) {
        feeToSetter = feeToSetter_;
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        if (tokenA == tokenB) revert IdenticalAddresses();

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        if (token0 == address(0)) revert ZeroAddress();

        if (getPair[token0][token1] != address(0)) revert PairExists();

        bytes memory bytecode = type(FreemoonDEXPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        IFreemoonDEXPair(pair).initialize(token0, token1);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address feeTo_) external {
        feeTo = feeTo_;
    }

    function setFeeToSetter(address feeToSetter_) external {
        feeToSetter = feeToSetter_;
    }
}
