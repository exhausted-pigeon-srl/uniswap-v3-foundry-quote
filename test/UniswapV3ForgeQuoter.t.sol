// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/UniswapV3ForgeQuoter.sol";

contract UniswapV3ForgeQuoterTest is Test, UniswapV3ForgeQuoter {
    UniswapV3ForgeQuoter target;

    IUniswapV3Pool usdcEth5bps = IUniswapV3Pool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/eth", 17264847);
        target = new UniswapV3ForgeQuoter();
    }

    function test_quoteZeroToOne() public {
        assertEq(target.getAmountOut(usdcEth5bps, 1 ether, weth), 1827918526);
    }

    function test_quoteOneToZero() public {
        assertEq(target.getAmountOut(usdcEth5bps, 1827918526, usdc), 998997389161430615);
    }

    function test_revertIfWrongTokenInAddress() public {
        vm.expectRevert(abi.encodePacked("UniswapV3ForgeQuoter:INVALID_TOKEN_IN"));
        target.getAmountOut(usdcEth5bps, 1 ether, address(69420));
    }
}