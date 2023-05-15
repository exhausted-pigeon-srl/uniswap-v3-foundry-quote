# Uniswap V3 Forge Test Quoter

Get a Uniswap V3 quote (amount of token received for an exact amount of token sent), by simulating the actual swap.

This contract is meant to be used within Forge test.

## Installation
either `npm i @exhausted-pigeon/uniswap-v3-forge-quoter` or `forge install exhausted-pigeon-srl/uniswap-v3-foundry-quote`

## Usage

```solidity

import "exhausted-pigeon/UniswapV3ForgeQuoter.sol";

contract MyTest is UniswapV3ForgeQuoter {
    IUniswapV3Pool usdcEth5bps = IUniswapV3Pool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function test_myTest() external {
        uint256 _amountOut = getAmountOut(usdcEth5bps, 1 ether, weth);
    }
}
```
