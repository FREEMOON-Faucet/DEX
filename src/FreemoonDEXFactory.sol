// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


interface ISlice {
    event Transfer(address indexed sender, address indexed recipient, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function startTime() external view returns (uint256); 
    function endTime() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    function initialize(string memory name, string memory symbol, uint8 decimals, uint256 start, uint256 end) external;
    function approveByParent(address owner, address spender, uint256 amount) external returns (bool);
    function transferByParent(address sender, address recipient, uint256 amount) external returns (bool);
}


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


contract Slice is Context, ISlice {
    using SafeMath for uint256;
 
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public startTime;
    uint256 public endTime;

    bool private initialized;

    address public parent;

    constructor() {}

    function initialize(string memory name_, string memory symbol_, uint8 decimals_, uint256 start_, uint256 end_) public override {
        require(initialized == false, "Slice: already been initialized");
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        startTime = start_;
        endTime = end_;
        parent = _msgSender();
 
        initialized = true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function approveByParent(address owner, address spender, uint256 amount) public virtual override returns (bool) {
        require(_msgSender() == parent, "Slice: caller must be parent");
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance[sender][_msgSender()].sub(amount, "Slice: too less allowance"));
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferByParent(address sender, address recipipent, uint256 amount) public virtual override returns (bool) {
        require(_msgSender() == parent, "Slice: caller must be parent");
        _transfer(sender, recipipent, amount);
        return true;
    }

    function mint(address account, uint256 amount) public virtual override {
        require(_msgSender() == parent, "Slice: caller must be parent");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public override {
        require(_msgSender() == parent, "Slice: caller must be parent");
        require(balanceOf[account] >=  amount, "Slice: burn amount exceeds balance");
        _burn(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "Slice: transfer from the zero address");
        require(recipient != address(0), "Slice: transfer to the zero address");

        balanceOf[sender] = balanceOf[sender].sub(amount, "Slice: transfer amount exceeds balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Slice: approve from the zero address");
        require(spender != address(0), "Slice: approve to the zero address");

        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(amount > 0, "Slice: invalid amount to mint");
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        balanceOf[account] = balanceOf[account].sub(amount, "Slice: transfer amount exceeds balance");
        emit Transfer(account, address(0), amount);
    }
}


contract FRC759 is Context, IFRC759 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public maxSupply;
    address public fullTimeToken;

    bool public paused;
    bool public allowSliceTransfer;
    mapping(address => bool) public blocked;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 maxSupply_) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        maxSupply = maxSupply_;

        fullTimeToken = createSlice(MIN_TIME, MAX_TIME);
    }

    uint256 public constant MIN_TIME = 0;
    uint256 public constant MAX_TIME = 18446744073709551615;

    mapping(uint256 => mapping(uint256 => address)) internal timeSlice;

    function _mint(address account, uint256 amount) internal {
        if (maxSupply != 0) {
            require(totalSupply.add(amount) <= maxSupply, "FRC759: maxSupply exceeds");
        }

        totalSupply = totalSupply.add(amount);
        ISlice(fullTimeToken).mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        totalSupply = totalSupply.sub(amount);
        ISlice(fullTimeToken).burn(account, amount);
    }

    function _burnSlice(address account, uint256 amount, uint256 start, uint256 end) internal {
        address sliceAddr = timeSlice[start][end];
        require(sliceAddr != address(0), "FRC759: slice not exists");
        ISlice(sliceAddr).burn(account, amount);
    }

    function balanceOf(address account) public view returns (uint256) {
        return ISlice(fullTimeToken).balanceOf(account);
    }

    function timeBalanceOf(address account, uint256 start, uint256 end) public view returns (uint256) {
        address sliceAddr = timeSlice[start][end];
        require(sliceAddr != address(0), "FRC759: slice not exists");
        return ISlice(sliceAddr).balanceOf(account);
    }
 
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return ISlice(fullTimeToken).allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        return ISlice(fullTimeToken).approveByParent(_msgSender(), spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        ISlice(fullTimeToken).transferByParent(sender, recipient, amount);
        ISlice(fullTimeToken).approveByParent(sender, _msgSender(), ISlice(fullTimeToken).allowance(sender, _msgSender()).sub(amount, "FRC759: too less allowance"));
        return true;
    }

    function transferFromData(address sender, address recipient, uint256 amount, bytes calldata data) public virtual returns (bool) {
        ISlice(fullTimeToken).transferByParent(sender, recipient, amount);
        ISlice(fullTimeToken).approveByParent(sender, _msgSender(), ISlice(fullTimeToken).allowance(sender, _msgSender()).sub(amount, "FRC759: too less allowance"));
        emit DataDelivery(data);
        return true;
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        ISlice(fullTimeToken).transferByParent(_msgSender(), recipient, amount);
        return true;
    }

    function transferData(address recipient, uint256 amount, bytes calldata data) public virtual returns (bool) {
        ISlice(fullTimeToken).transferByParent(_msgSender(), recipient, amount);
        emit DataDelivery(data);
        return true;
    }

    function timeSliceTransferFrom(address sender, address recipient, uint256 amount, uint256 start, uint256 end) public virtual returns (bool) {
        address sliceAddr = timeSlice[start][end];
        require(sliceAddr != address(0), "FRC759: slice not exists");
        ISlice(sliceAddr).transferByParent(sender, recipient, amount);
        ISlice(fullTimeToken).approveByParent(sender, _msgSender(), ISlice(fullTimeToken).allowance(sender, _msgSender()).sub(amount, "FRC759: too less allowance"));
        return true;
    }

    function timeSliceTransfer(address recipient, uint256 amount, uint256 start, uint256 end) public virtual returns (bool) {
        address sliceAddr = timeSlice[start][end];
        require(sliceAddr != address(0), "FRC759: slice not exists");
        ISlice(sliceAddr).transferByParent(_msgSender(), recipient, amount);
        return true;
    }

    function createSlice(uint256 start, uint256 end) public returns (address sliceAddr) {
        require(end > start, "FRC759: tokenEnd must be greater than tokenStart");
        require(end <= MAX_TIME, "FRC759: tokenEnd must be less than MAX_TIME");
        require(timeSlice[start][end] == address(0), "FRC759: slice already exists");
        bytes memory bytecode = type(Slice).creationCode;

        bytes32 salt = keccak256(abi.encodePacked(start, end));
 
        assembly {
            sliceAddr := create2(0, add(bytecode, 32), mload(bytecode), salt)
            if iszero(extcodesize(sliceAddr)) {revert(0, 0)}
        }

        ISlice(sliceAddr).initialize(string(abi.encodePacked("TF_", name)), string(abi.encodePacked("TF_", symbol)), decimals, start, end);
 
        timeSlice[start][end] = sliceAddr;

        emit SliceCreated(sliceAddr, start, end);
    }

    function sliceByTime(uint256 amount, uint256 sliceTime) public {
        require(sliceTime >= block.timestamp, "FRC759: sliceTime must be greater than blockTime");
        require(sliceTime < MAX_TIME, "FRC759: sliceTime must be smaller than blockTime");
        require(amount > 0, "FRC759: amount cannot be zero");

        address _left = getSlice(MIN_TIME, sliceTime);
        address _right = getSlice(sliceTime, MAX_TIME);

        if (_left == address(0)) {
            _left = createSlice(MIN_TIME, sliceTime);
        }

        if (_right == address(0)) {
            _right = createSlice(sliceTime, MAX_TIME);
        }

        ISlice(fullTimeToken).burn(_msgSender(), amount);

        ISlice(_left).mint(_msgSender(), amount);
        ISlice(_right).mint(_msgSender(), amount);
    }
 
    function mergeSlices(uint256 amount, address[] calldata slices) public {
        require(slices.length > 0, "FRC759: empty slices array");
        require(amount > 0, "FRC759: amount cannot be zero");

        uint256 lastEnd = MIN_TIME;
 
        for (uint256 i = 0; i < slices.length; i++) {
            uint256 _start = ISlice(slices[i]).startTime();
            uint256 _end = ISlice(slices[i]).endTime();
            require(slices[i] == getSlice(_start, _end), "FRC759: invalid slice address");
            require(lastEnd == 0 || _start == lastEnd, "FRC759: continuous slices required");
            ISlice(slices[i]).burn(_msgSender(), amount);
            lastEnd = _end;
        }

        uint256 firstStart = ISlice(slices[0]).startTime();
        address sliceAddr;

        if (firstStart <= block.timestamp) {
            firstStart = MIN_TIME;
        }

        if (lastEnd > block.timestamp) {
            sliceAddr = getSlice(firstStart, lastEnd);

            if (sliceAddr == address(0)) {
                sliceAddr = createSlice(firstStart, lastEnd);
            }
        }

        if (sliceAddr != address(0)) {
            ISlice(sliceAddr).mint(_msgSender(), amount);
        }
    }

    function getSlice(uint256 start, uint256 end) public view returns (address) {
        return timeSlice[start][end];
    }
}


library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


library UQ112x112 {
    uint224 constant Q112 = 2**112;

    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112;
    }

    function uqdiv(uint224 x, uint224 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}


interface IFRC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IFreemoonDEXCallee {
    function uniswapV2Call(address sender, uint256 amount0Out, uint256 amount1Out, bytes calldata data) external;
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


contract FreemoonDEXPair is IFreemoonDEXPair, FRC759 {
    using UQ112x112 for uint224;

    uint256 public constant MINIMUM_LIQUIDITY = 1000;

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32 private blockTimestampLast;

    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast;

    uint256 private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, "FreemoonDEX: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() FRC759("FreemoonDEX", "FMN-DEX", 18, type(uint256).max) {
        factory = msg.sender;
    }

    function initialize(address token0_, address token1_) public {
        if (msg.sender != factory) revert Forbidden();

        token0 = token0_;
        token1 = token1_;
    }

    function mint(address to) external lock returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        uint256 balance0 = IFRC20(token0).balanceOf(address(this));
        uint256 balance1 = IFRC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings

        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY);
        } else {
            liquidity = Math.min(
                (amount0 * _totalSupply) / _reserve0,
                (amount1 * _totalSupply) / _reserve1
            );
        }

        if (liquidity <= 0) revert InsufficientLiquidityMinted();

        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);

        if (feeOn) kLast = uint256(reserve0) * reserve1;

        emit Mint(to, amount0, amount1);
    }

    function burn(address to) external lock returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        address _token0 = token0;                                 // gas savings
        address _token1 = token1;                                 // gas savings
        uint256 balance0 = IFRC20(_token0).balanceOf(address(this));
        uint256 balance1 = IFRC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf(address(this));

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings

        amount0 = (liquidity * balance0) / _totalSupply;
        amount1 = (liquidity * balance1) / _totalSupply;

        if (amount0 == 0 || amount1 == 0) revert InsufficientLiquidityBurned();

        _burn(address(this), liquidity);

        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);

        balance0 = IFRC20(_token0).balanceOf(address(this));
        balance1 = IFRC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);

        if (feeOn) kLast = uint256(reserve0) * reserve1;

        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external lock {
        if (amount0Out == 0 && amount1Out == 0) revert InsufficientOutputAmount();

        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings

        if (amount0Out >= _reserve0 || amount1Out >= _reserve1) revert InsufficientLiquidity();

        uint256 balance0;
        uint256 balance1;
        {
            address _token0 = token0;
            address _token1 = token1;
            if (to == _token0 || to == _token1) revert InvalidTo();

            if (amount0Out > 0) _safeTransfer(token0, to, amount0Out);
            if (amount1Out > 0) _safeTransfer(token1, to, amount1Out);
            if (data.length > 0) IFreemoonDEXCallee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);

            balance0 = IFRC20(token0).balanceOf(address(this));
            balance1 = IFRC20(token1).balanceOf(address(this));
        }

        uint256 amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;

        if (amount0In == 0 && amount1In == 0) revert InsufficientInputAmount();

        {
            uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 2);
            uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 2);

            if (balance0Adjusted * balance1Adjusted < uint256(_reserve0) * uint256(_reserve1) * (1000**2)) revert InvalidK();
        }

        _update(balance0, balance1, _reserve0, _reserve1);

        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IFRC20(_token0).balanceOf(address(this)) - reserve0);
        _safeTransfer(_token1, to, IFRC20(_token1).balanceOf(address(this)) - reserve1);
    }

    function sync() external lock {
        _update(IFRC20(token0).balanceOf(address(this)), IFRC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }

    function getReserves() public view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, blockTimestampLast);
    }

    function burnSlice(address account, uint256 amount, uint256 start, uint256 end) external {
        if (account != msg.sender) revert Forbidden();
        _burnSlice(account, amount, start, end);
    }

    // PRIVATE
    function _update(uint256 balance0, uint256 balance1, uint112 reserve0_, uint112 reserve1_) private {
        if (balance0 > type(uint112).max || balance1 > type(uint112).max) revert BalanceOverflow();

        unchecked {
            uint32 timeElapsed = uint32(block.timestamp) - blockTimestampLast;

            if (timeElapsed > 0 && reserve0_ > 0 && reserve1_ > 0) {
                price0CumulativeLast += uint256(UQ112x112.encode(reserve1_).uqdiv(reserve0_)) * timeElapsed;
                price1CumulativeLast += uint256(UQ112x112.encode(reserve0_).uqdiv(reserve1_)) * timeElapsed;
            }
        }

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = uint32(block.timestamp);

        emit Sync(reserve0, reserve1);
    }

    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IFreemoonDEXFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings

        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(_reserve0) * _reserve1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply * (rootK - rootKLast);
                    uint256 denominator = (rootK * 20) + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSignature("transfer(address,uint256)", to, value));
        if (!success || (data.length != 0 && !abi.decode(data, (bool)))) revert TransferFailed();
    }
}


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

    function setFeeTo(address feeTo_) external forbidden {
        feeTo = feeTo_;
    }

    function setFeeToSetter(address feeToSetter_) external forbidden {
        feeToSetter = feeToSetter_;
    }
}