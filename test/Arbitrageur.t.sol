//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;


import "../lib/forge-std/src/Test.sol";
import "./TestUtil.t.sol";
import "../src/Arbitrageur.sol";
import { IERC20 } from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";


contract ArbitrageurTest is Test , TestUtil {

    // mumbai constants
    address constant MUMBAI_USDT = 0xe583769738b6dd4E7CAF8451050d1948BE717679 ;
    address constant MUMBAI_USDT_MINTABLE = 0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0 ;
    address constant MUMBAI_USDC_MINTABLE = 0xe9DcE89B076BA6107Bb64EF30678efec11939234 ;

    // polygon constants
    address constant POLYGON_USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F ;
    address constant POLYGON_USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174 ;
    address constant POLYGON_WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619 ;
    address constant POLYGON_WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270 ;

    // arbitrage
    uint256 constant LOAN_AMOUNT = 10000 ;
    uint24  constant UNISWAP_FEE = 500 ;
    uint8  constant UNI_TO_QUICK_DIRECTION = 0 ;
    uint8  constant QUICK_TO_UNI_DIRECTION = 1 ;
    address QUICKSWAP_POOL = 0x9CEff2F5138fC59eB925d270b8A7A9C02a1810f2 ;

    Arbitrageur testContract ;

    function setUp() public {
        uint256 polygonFork = vm.createFork(vm.rpcUrl("polygon")) ;
        vm.selectFork(polygonFork) ;
        testContract = new Arbitrageur() ;
    }

    function testFail_NotCalledByOwner() public {
        address baseAsset = POLYGON_WETH ;
        address quoteAsset = POLYGON_USDT ;
        uint256 amount = LOAN_AMOUNT ;
        uint24  fee = 500 ;
        deal(quoteAsset,address(testContract), amount) ;
        address user = makeAddr("NotOwner");
        console.log("testContract address: ",address(testContract)) ;
        console.log("caller address: ",user) ;
        console.log("testContract balance: ",IERC20(quoteAsset).balanceOf(address(testContract))) ;
        vm.prank(user);
        testContract.arbitrage( baseAsset,quoteAsset, amount,UNI_TO_QUICK_DIRECTION,fee) ;
    }

    function testFail_ArbitrageWithoutFundsToPayFees() public {
        console.log("testContract balance: ",IERC20(POLYGON_USDT).balanceOf(address(testContract))) ;
        testContract.arbitrage(
            POLYGON_USDC,
            POLYGON_USDT,
            LOAN_AMOUNT,
            QUICK_TO_UNI_DIRECTION,
            uint24(500)
        ) ;
    }

    function test_ArbitrageUni2Quick_LoanUsdtBuyAndSellWeth() public {
        address baseAsset = POLYGON_WETH ;
        address quoteAsset = POLYGON_USDT ;
        uint256 amount = LOAN_AMOUNT ;
        uint24  fee = UNISWAP_FEE ;
        // deal(quoteAsset,address(testContract), amount) ;
        console.log("testContract balance: ",IERC20(quoteAsset).balanceOf(address(testContract))) ;
        testContract.arbitrage( baseAsset, quoteAsset, amount, UNI_TO_QUICK_DIRECTION,fee) ;
    }

    function test_ArbitrageQuick2Uni_LoanUsdtBuyAndSellWeth() public {
        address baseAsset = POLYGON_WETH ;
        address quoteAsset = POLYGON_USDT ;
        uint256 amount = LOAN_AMOUNT ;
        uint24  fee = UNISWAP_FEE ;
        // deal(quoteAsset,address(testContract), amount) ;
        console.log("testContract balance: ",IERC20(quoteAsset).balanceOf(address(testContract))) ;
        testContract.arbitrage( baseAsset, quoteAsset, amount, QUICK_TO_UNI_DIRECTION,fee) ;
    }

    function test_ArbitrageUni2Quick_LoanUsdcBuyAndSellWeth() public {
        address baseAsset = POLYGON_WETH ;
        address quoteAsset = POLYGON_USDC ;
        uint256 amount = LOAN_AMOUNT ;
        uint24  fee = UNISWAP_FEE ;
        // deal(quoteAsset,address(testContract), amount) ;
        console.log("testContract balance: ",IERC20(quoteAsset).balanceOf(address(testContract))) ;
        testContract.arbitrage( baseAsset, quoteAsset, amount, UNI_TO_QUICK_DIRECTION,fee) ;
    }

    function test_ArbitrageQuick2Uni_LoanUsdcBuyAndSellWeth() public {
        address baseAsset = POLYGON_WETH ;
        address quoteAsset = POLYGON_USDC ;
        uint256 amount = LOAN_AMOUNT ;
        uint24  fee = UNISWAP_FEE ;
        // deal(quoteAsset,address(testContract), amount) ;
        console.log("testContract balance: ",IERC20(quoteAsset).balanceOf(address(testContract))) ;
        testContract.arbitrage( baseAsset, quoteAsset, amount, QUICK_TO_UNI_DIRECTION,fee) ;
    }

    function test_ArbitrageUni2Quick_LoanWmaticBuyAndSellWeth() public {
        address baseAsset = POLYGON_WETH ;
        address quoteAsset = POLYGON_WMATIC ;
        uint256 amount = LOAN_AMOUNT ;
        uint24  fee = UNISWAP_FEE ;
        // deal(quoteAsset,address(testContract), amount) ;
        console.log("testContract balance: ",IERC20(quoteAsset).balanceOf(address(testContract))) ;
        testContract.arbitrage( baseAsset, quoteAsset, amount, UNI_TO_QUICK_DIRECTION,fee) ;
    }

    function test_ArbitrageQuick2Uni_LoanWmaticBuyAndSellWeth() public {
        address baseAsset = POLYGON_WETH ;
        address quoteAsset = POLYGON_WMATIC ;
        uint256 amount = LOAN_AMOUNT ;
        uint24  fee = UNISWAP_FEE ;
        // deal(quoteAsset,address(testContract), amount) ;
        console.log("testContract balance: ",IERC20(quoteAsset).balanceOf(address(testContract))) ;
        testContract.arbitrage( baseAsset, quoteAsset, amount, QUICK_TO_UNI_DIRECTION,fee) ;
    }

}
