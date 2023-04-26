// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;
pragma abicoder v2;


import "../lib/aave-v3-core/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {ISwapRouter as IUniswapRouterV3} from "./ISwapRouter.sol";
import {SwapRouter as IQuickswapRouterV3} from "./IQuickswapRouterV3.sol";
import "../lib/forge-std/src/console.sol" ;


contract Arbitrageur is IFlashLoanSimpleReceiver, Ownable {

    enum Direction { 
        UniswapV3ToQuickswapV3,
        QuickswapV3ToUniswapV3
    }

    // tokens
    address constant POLYGON_USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F ;
    address constant POLYGON_USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174 ;
    address constant POLYGON_WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619 ;

    // flash loan constants
    address constant MUMBAI_AAVE_POOL_ADDRESS_PROVIDER = 0xeb7A892BB04A8f836bDEeBbf60897A7Af1Bf5d7F ;
    address constant POLYGON_AAVE_POOL_ADDRESS_PROVIDER = 0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb ;

    // dexs constants
    address constant UNISWAPV3_SWAP_ROUTER_ADDRESS = 0xE592427A0AEce92De3Edee1F18E0157C05861564 ;
    address constant MUMBAI_QUICKSWAP_ROUTER_ADDRESS = 0x8954AfA98594b838bda56FE4C12a09D7739D179b ;
    address constant POLYGON_QUICKSWAP_ROUTER_ADDRESS = 0xf5b509bB0909a69B1c207E495f687a596C168E12 ;

    IPoolAddressesProvider public provider = IPoolAddressesProvider(POLYGON_AAVE_POOL_ADDRESS_PROVIDER);
    IPool public pool;
    IUniswapRouterV3 private uniswapRouterV3 = IUniswapRouterV3(UNISWAPV3_SWAP_ROUTER_ADDRESS);
    IQuickswapRouterV3 private quickswapRouterV3 = IQuickswapRouterV3(POLYGON_QUICKSWAP_ROUTER_ADDRESS);

    constructor() {
        pool = IPool(provider.getPool());
    }

    /**
     * @notice request a flashloan to execute an arbitrage operation on `baseAsset`/`quoteAsset`
     * @param  _quoteAssetAmount: amount of `quoteAssetAmount` to request in flashLoan
     * @param  _direction: set trade direction(where to buy and where to sell) 
     * @return true if function succeeds or false otherwise
     * @dev    executeOperation(where trade is executed) is called automatically
     *         afther this function by the aave pool contract
     */
    function arbitrage(
        address _baseAsset,
        address _quoteAsset,
        uint256 _quoteAssetAmount,
        uint8 _direction,
        uint24 _uniswapFee
    ) external onlyOwner returns (bool) {
        bytes memory flashLoanParams = abi.encode(
            _baseAsset,
            Direction(_direction),
            _uniswapFee
        );
        pool.flashLoanSimple({
            receiverAddress: address(this),
            asset: _quoteAsset,
            amount: _quoteAssetAmount,
            params: flashLoanParams,
            referralCode: 0
        });
        return true;
    }

    /**
     * @notice Executes an operation after receiving the flash-borrowed asset
     * @dev Ensure that the contract can return the debt + premium, e.g., has
     *      enough funds to repay and has approved the Pool to pull the total amount
     * @param quoteAsset The address of the flash-borrowed asset
     * @param amount The amount of the flash-borrowed asset
     * @param premium The fee of the flash-borrowed asset
     * @param initiator The address of the flashloan initiator
     * @param params The byte-encoded params passed when initiating the flashloan
     * @return True if the execution of the operation succeeds or false otherwise
     */
    function executeOperation(
        address quoteAsset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        (address baseAsset,Direction direction,uint24 uniswapFee) = abi.decode(params, (address, Direction,uint24));
        console.log("loaned amount: ",amount) ;
        console.log("after loan base aasset balance: ",getBalance(baseAsset)) ;
        console.log("after loan quoted asset balance: ",getBalance(quoteAsset)) ;

        uint256 income ;
        if (direction == Direction.UniswapV3ToQuickswapV3) {
            uint256 tradeAmount = tradeInUniswapV3(quoteAsset,baseAsset,amount,uniswapFee) ;
            income = tradeInQuickswapV3(baseAsset,quoteAsset,tradeAmount) ;
        } else if (direction == Direction.QuickswapV3ToUniswapV3) {
            uint256 tradeAmount = tradeInQuickswapV3(quoteAsset,baseAsset,amount) ;
            income = tradeInUniswapV3(baseAsset,quoteAsset,tradeAmount,uniswapFee) ;
        }

        uint256 amountOwed = amount + premium;
        console.log("income: ",income);
        console.log("amountOwed: ",amountOwed);
        console.log("quoteAsset: ",IERC20(quoteAsset).balanceOf(address(this)));
        if (income < amountOwed) {
            console.log("reverse operation due insuficient profit");
            return false;
        }
        IERC20(quoteAsset).approve(address(pool), amountOwed);
        return true;
    }

    /**
     * @notice utility function to execute a swap on uniswap
     * @return swaped amount of `_quoteAsset` 
     */
    function tradeInUniswapV3(
        address _baseAsset,
        address _quoteAsset,
        uint256 _amount,
        uint24  _fee
    ) private returns (uint256) {
        IERC20(_baseAsset).approve(address(uniswapRouterV3), _amount);
        IUniswapRouterV3.ExactInputSingleParams memory swapParams = IUniswapRouterV3.ExactInputSingleParams({
            tokenIn: _baseAsset,
            tokenOut: _quoteAsset,
            fee: _fee,
            recipient: address(this),
            deadline: block.timestamp + 300,
            amountIn: _amount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });
        uint256 amount = uniswapRouterV3.exactInputSingle(swapParams);
        console.log("trade in uniswap out: ",amount);
        return amount ;
    }

    /**
     * @return swaped amount of `_quoteAsset` 
     * @dev router address: https://github.com/QuickSwap/interface-v2/blob/d468894069f60368d57ff3a5ac670bd5390f051d/src/constants/v3/addresses.ts
     */
    function tradeInQuickswapV3(
        address _baseAsset,
        address _quoteAsset,
        uint256 _amount
    ) private returns (uint256) {
        IERC20(_baseAsset).approve(address(quickswapRouterV3), _amount);
        IQuickswapRouterV3.ExactInputSingleParams memory swapParams = IQuickswapRouterV3.ExactInputSingleParams({
            tokenIn: _baseAsset,
            tokenOut: _quoteAsset,
            recipient: address(this),
            deadline: block.timestamp + 300,
            amountIn: _amount,
            amountOutMinimum: 0,
            limitSqrtPrice: 0
        });
        uint256 amount = quickswapRouterV3.exactInputSingle(swapParams);
        console.log("trade in quickswap out: ",amount);
        return  amount ; 
    }

    /**
     * @notice withdraw asset `_asset` from contract
     * @param _asset: address of asset to withdraw
     * @return true if function succeeds or false otherwise
     */
    function withdraw(address _asset) public onlyOwner returns (bool) {
        uint256 amount = getBalance(_asset);
        return IERC20(_asset).transfer(owner(), amount);
    }

    // /**
    //  * @dev   utility function to approve address `spender` to
    //           withdraw certain amount `amount` of asset `asset`
    //  * @param _spender: address to allow spend funds
    //  * @param _asset: asset to approve
    //  * @param _amount: amount of asset `asset` to approve spend
    //  */
    // function approve(address _spender,address _asset,uint256 _amount) private {
    //     IERC20(_asset).approve(_spender,_amount);
    //     // IERC20 asset = IERC20(_asset) ;
    //     // if (asset.allowance(address(this),_spender) != _amount) {
    //     //     revert();
    //     // }
    // }

    /**
     * @return contract balance of asset `asset`
     * @param _asset: address of asset to check balance
     */
    function getBalance(address _asset) public view returns (uint256) {
        return IERC20(_asset).balanceOf(address(this));
    }

    /**
     * @return pool address provider of contract
     */
    function ADDRESSES_PROVIDER()
        external
        view
        returns (IPoolAddressesProvider)
    {
        return provider;
    }

    /**
     * @return pool of contract
     */
    function POOL() external view returns (IPool) {
        return pool;
    }

    receive() external payable {}

}
