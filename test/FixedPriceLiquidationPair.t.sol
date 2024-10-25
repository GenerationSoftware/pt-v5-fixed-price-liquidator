// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";

import {
    FixedPriceLiquidationPair,
    IERC20,
    ILiquidationSource,
    IFlashSwapCallback,
    SwapExceedsMax,
    InsufficientBalance,
    SmoothingGteOne,
    ReceiverIsZero
} from "../src/FixedPriceLiquidationPair.sol";

contract FixedPriceLiquidationPairTest is Test {
    
    event SwappedExactAmountOut(
        address indexed sender,
        address indexed receiver,
        uint256 amountOut,
        uint256 amountInMax,
        uint256 amountIn,
        bytes flashSwapData
    );

    FixedPriceLiquidationPair pair;

    ILiquidationSource source;
    IERC20 tokenIn;
    IERC20 tokenOut;
    uint256 targetAuctionPrice;

    IFlashSwapCallback receiver;
    address target;

    function setUp() public {
        target = makeAddr("target");
        source = ILiquidationSource(makeAddr("ILiquidationSource"));
        vm.etch(address(source), "source"); // ensure call failures if not mocked
        tokenIn = IERC20(makeAddr("tokenIn"));
        vm.etch(address(tokenIn), "tokenIn"); // ensure call failures if not mocked
        vm.mockCall(address(source), abi.encodeWithSelector(source.targetOf.selector, address(tokenIn)), abi.encode(target));
        tokenOut = IERC20(makeAddr("tokenOut"));
        vm.etch(address(tokenOut), "tokenOut"); // ensure call failures if not mocked
        targetAuctionPrice = 0.01e18;
        receiver = IFlashSwapCallback(makeAddr("receiver"));
        vm.etch(address(receiver), "receiver"); // ensure call failures if not mocked
        pair = new FixedPriceLiquidationPair(
            source,
            address(tokenIn),
            address(tokenOut),
            targetAuctionPrice,
            0
        );
    }

    function test_constructor() public {
        assertEq(pair.tokenIn(), address(tokenIn), "tokenIn");
        assertEq(pair.tokenOut(), address(tokenOut), "token out");
    }

    function test_constructor_SmoothingGteOne() public{ 
        vm.expectRevert(abi.encodeWithSelector(SmoothingGteOne.selector));
        new FixedPriceLiquidationPair(
            source,
            address(tokenIn),
            address(tokenOut),
            targetAuctionPrice,
            1e18
        );
    }

    function test_target() public {
        assertEq(pair.target(), target, "target");
    }

    function test_maxAmountOut() public {
        mockLiquidatableBalance(1000e18);
        assertEq(pair.maxAmountOut(), 1000e18, "max amount out");
    }

    function test_nonZeroPrice() public {
        vm.warp(1e20 days);
        assertGt(pair.computeExactAmountIn(0), 0, "non-zero price");
    }

    function test_computePrice_onTarget() public {
        assertEq(pair.computeExactAmountIn(0), targetAuctionPrice, "target achieved");
    }

    function test_swapExactAmountOut() public {
        mockTransferTokensOut(1234e18);

        uint firstTime = block.timestamp + 4 weeks;

        vm.warp(firstTime);
        vm.expectEmit(true, true, true, true);
        emit SwappedExactAmountOut(
            address(this),
            address(receiver),
            1234e18,
            100e18,
            pair.computeExactAmountIn(0),
            ""
        );
        pair.swapExactAmountOut(address(receiver), 1234e18, 100e18, "");
    }

    function test_swapExactAmountOut_ReceiverIsZero() public {
        vm.expectRevert(abi.encodeWithSelector(ReceiverIsZero.selector));
        pair.swapExactAmountOut(address(0), 0, 1110e18, "");
    }

    function test_swapExactAmountOut_flashSwapCallback() public {
        mockTransferTokensOut(1234e18);
        uint price = pair.computeExactAmountIn(0);
        vm.mockCall(address(receiver), abi.encodeWithSelector(receiver.flashSwapCallback.selector, address(this), price, 1234e18, "hello"), abi.encode());
        pair.swapExactAmountOut(address(receiver), 1234e18, price, "hello");
    }

    function test_swapExactAmountOut_SwapExceedsMax() public {
        vm.expectRevert(abi.encodeWithSelector(SwapExceedsMax.selector, 0.001e18, targetAuctionPrice));
        pair.swapExactAmountOut(address(receiver), 0, 0.001e18, "");
    }

    function test_swapExactAmountOut_InsufficientBalance() public {
        mockLiquidatableBalance(0);
        vm.expectRevert(abi.encodeWithSelector(InsufficientBalance.selector, 1234e18, 0));
        pair.swapExactAmountOut(address(receiver), 1234e18, 1000e18, "");
    }

    function mockLiquidatableBalance(uint256 balance) internal {
        vm.mockCall(address(source), abi.encodeWithSelector(source.liquidatableBalanceOf.selector, address(tokenOut)), abi.encode(balance));
    }

    function mockTransferTokensOut(uint256 balance) internal {
        mockLiquidatableBalance(balance);
        vm.mockCall(address(source), abi.encodeWithSelector(source.transferTokensOut.selector, address(this), receiver, address(tokenOut), balance), abi.encode(""));
    }

    function mockVerify(uint amount) internal {
        vm.mockCall(address(source), abi.encodeWithSelector(source.verifyTokensIn.selector, address(tokenIn), amount, ""), abi.encode(""));
    }

}