pragma solidity ^0.8.10;

interface SwapRouter {
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 limitSqrtPrice;
    }

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 limitSqrtPrice;
    }

    function WNativeToken() external view returns (address);
    function algebraSwapCallback(int256 amount0Delta, int256 amount1Delta, bytes memory _data) external;
    function exactInput(ExactInputParams memory params) external payable returns (uint256 amountOut);
    function exactInputSingle(ExactInputSingleParams memory params) external payable returns (uint256 amountOut);
    function exactInputSingleSupportingFeeOnTransferTokens(ExactInputSingleParams memory params)
        external
        returns (uint256 amountOut);
    function exactOutput(ExactOutputParams memory params) external payable returns (uint256 amountIn);
    function exactOutputSingle(ExactOutputSingleParams memory params) external payable returns (uint256 amountIn);
    function factory() external view returns (address);
    function multicall(bytes[] memory data) external payable returns (bytes[] memory results);
    function poolDeployer() external view returns (address);
    function refundNativeToken() external payable;
    function selfPermit(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
        payable;
    function selfPermitAllowed(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)
        external
        payable;
    function selfPermitAllowedIfNecessary(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)
        external
        payable;
    function selfPermitIfNecessary(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
        payable;
    function sweepToken(address token, uint256 amountMinimum, address recipient) external payable;
    function sweepTokenWithFee(
        address token,
        uint256 amountMinimum,
        address recipient,
        uint256 feeBips,
        address feeRecipient
    ) external payable;
    function unwrapWNativeToken(uint256 amountMinimum, address recipient) external payable;
    function unwrapWNativeTokenWithFee(uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient)
        external
        payable;
}

