// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;


interface IFRC759 {
    event DataDelivery(bytes data);
    event SliceCreated(address indexed sliceAddr, uint256 start, uint256 end);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function maxSupply() external view returns (uint256);
    function fullTimeToken() external view returns (address);

    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function timeSliceTransferFrom(address spender, address recipient, uint256 amount, uint256 start, uint256 end) external returns (bool);
    function timeSliceTransfer(address recipient, uint256 amount, uint256 start, uint256 end) external returns (bool);

    function createSlice(uint256 start, uint256 end) external returns (address);
    function sliceByTime(uint256 amount, uint256 sliceTime) external;
    function mergeSlices(uint256 amount, address[] calldata slices) external;
    function getSlice(uint256 start, uint256 end) external view returns (address);
    function timeBalanceOf(address account, uint256 start, uint256 end) external view returns (uint256);

    function paused() external view returns (bool);
    function allowSliceTransfer() external view returns (bool);
    function blocked(address account) external view returns (bool);

    function MIN_TIME() external view returns (uint256);
    function MAX_TIME() external view returns (uint256);
}


interface IFreemoonDEXFactory {
    error IdenticalAddresses();
    error ZeroAddress();
    error PairExists();
    error Forbidden();

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);
 
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IFreemoonDEXPair {
    error Forbidden();
    error BalanceOverflow();
    error InsufficientInputAmount();
    error InsufficientLiquidity();
    error InsufficientLiquidityBurned();
    error InsufficientLiquidityMinted();
    error InsufficientOutputAmount();
    error InvalidK();
    error InvalidTo();
    error TransferFailed();

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);
    function burn(address to) external returns (uint256 amount0, uint256 amount1);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function burnSlice(address account, uint256 amount, uint256 start, uint256 end) external;

    function initialize(address, address) external;
}


interface IFreemoonDEXVault {
    event LiquiditySliceBurned(address indexed account, address indexed pair, uint256 amount, uint256 termEnd);

    error InvalidTermEnd();
    error IdenticalAddresses();
    error ZeroAddress();

    function liquiditySliceAmountBurnedETH(address token, uint256 termEnd) external view returns (uint256);
    function liquiditySliceAmountBurned(address tokenA, address tokenB, uint256 termEnd) external view returns (uint256);
    function burnedByETH(address token, uint256 termEnd, address account) external view returns (uint256);
    function burnedBy(address tokenA, address tokenB, uint256 termEnd, address account) external view returns (uint256);

    function MIN_TIME() external view returns (uint256);
    function MAX_TIME() external view returns (uint256);

    function factory() external view returns (address);
    function wfsn() external view returns (address);

    function burnLiquiditySliceETH(address token, uint256 amount, uint256 termEnd) external;
    function burnLiquiditySlice(address tokenA, address tokenB, uint256 amount, uint256 termEnd) external;
}


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