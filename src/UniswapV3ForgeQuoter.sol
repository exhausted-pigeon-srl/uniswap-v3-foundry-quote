// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';

/**
 * @title  Uniswap V3 Forge Test Quoter
 *
 * @notice A contract for getting Uniswap V3 quotes in Forge tests
 *
 * @dev    This contract is only meant to be used in Forge tests, do not use onchain
 *         Usage: import and inherit this contract, then use simulate (cf README.md).
 *         NB: as the swap is actually simulated, you will see a red line in the Forge trace
 *
 * @author DrGorilla_md for exhausted-pigeon.xyz
 */
contract UniswapV3ForgeQuoter {
    // Emit when bubbling up Uniswap-related errors
    event LogError(string reason);   

    // Dummy variable to avoid "can be restricted to pure" error for the reverting callback
    uint256 private dummyHolder;

    /**
     * @notice Simulate a swap on a Uniswap V3 pool
     *
     * @param  _pool      The Uniswap V3 pool
     * @param  _amountIn  The amount of tokenIn to swap
     * @param  _tokenIn   The address of the tokenIn
     *
     * @return _amountOut The amount of tokenOut received
     */
    function getAmountOut(IUniswapV3Pool _pool, uint256 _amountIn, address _tokenIn) public returns (uint256 _amountOut) {
        address _token0 = address(_pool.token0());
        address _token1 = address(_pool.token1());

        // Swapping from token0 to token1?
        bool _zeroForOne = _tokenIn == _token0;

        // Check token in as part of the pool, as it will not be checked during the swap (ie zeroForOne is used instead)
        require(_tokenIn == _token0 || _tokenIn == _token1, 'UniswapV3ForgeQuoter:INVALID_TOKEN_IN');

        try _pool.swap({
            recipient: address(this),
            zeroForOne: _zeroForOne,
            amountSpecified: int256(_amountIn),
            sqrtPriceLimitX96: _zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1, // Do not check the price limit
            data: abi.encode(_zeroForOne) // Encode the zeroForOne parameter for the callback
        }) {}
        // Catch and bubble up Uniswap errors
        catch Error(string memory _reason) {
            emit LogError(_reason);
        }
        // Catch and decode the amount from the callback
        catch (bytes memory _return) {
            _amountOut = abi.decode(_return, (uint256));
        }
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        // Determinate what's received and convert it to a uint256 (leaving the pool == negative delta)
        bool _zeroForOne = abi.decode(data, (bool));
        uint256 _amountReceived = uint256(-(_zeroForOne ?  amount1Delta : amount0Delta));

        // Prevent erroneous "can be restricted to pure"
        dummyHolder++;
        
        // Store the amount received and return it while reverting
        assembly {
            mstore(0, _amountReceived)
            revert(0, 32)
        }
    }

}