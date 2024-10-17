// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import { ILiquidationSource } from "pt-v5-liquidator-interfaces/ILiquidationSource.sol";

import { FixedPriceLiquidationPairFactory } from "../src/FixedPriceLiquidationPairFactory.sol";
import { FixedPriceLiquidationPair } from "../src/FixedPriceLiquidationPair.sol";

contract FixedPriceLiquidationPairFactoryTest is Test {
  /* ============ Variables ============ */
  FixedPriceLiquidationPairFactory public factory;
  address public source;
  address public target;
  address tokenIn;
  address tokenOut;
  uint256 auctionTargetPrice = 1e18;
  uint256 smoothing = 0.1e18;

  /* ============ Events ============ */

  event PairCreated(
    FixedPriceLiquidationPair indexed pair,
    ILiquidationSource source,
    address indexed tokenIn,
    address indexed tokenOut,
    uint256 targetAuctionPrice,
    uint256 smoothingFactor
  );

  /* ============ Set up ============ */

  function setUp() public {
    // Contract setup
    factory = new FixedPriceLiquidationPairFactory();
    tokenIn = makeAddr("tokenIn");
    tokenOut = makeAddr("tokenOut");
    source = makeAddr("source");
    vm.etch(source, "ILiquidationSource");
    target = makeAddr("target");
  }

  /* ============ External functions ============ */

  /* ============ createPair ============ */

  function testCreatePair() public {
    vm.expectEmit(false, false, false, true);
    emit PairCreated(
      FixedPriceLiquidationPair(0x0000000000000000000000000000000000000000),
      ILiquidationSource(source),
      tokenIn,
      tokenOut,
      auctionTargetPrice,
      smoothing
    );

    mockLiquidatableBalanceOf(0);

    assertEq(factory.totalPairs(), 0, "no pairs exist");

    FixedPriceLiquidationPair lp = factory.createPair(
      ILiquidationSource(source),
      tokenIn,
      tokenOut,
      auctionTargetPrice,
      smoothing
    );

    assertEq(factory.totalPairs(), 1, "one pair exists");
    assertEq(address(factory.allPairs(0)), address(lp), "pair is in array");

    assertTrue(factory.deployedPairs(address(lp)));

    assertEq(address(lp.source()), source);
    assertEq(address(lp.tokenIn()), tokenIn);
    assertEq(address(lp.tokenOut()), tokenOut);
  }

  function mockLiquidatableBalanceOf(uint256 amount) public {
    vm.mockCall(
      address(source),
      abi.encodeWithSelector(ILiquidationSource.liquidatableBalanceOf.selector, tokenOut),
      abi.encode(amount)
    );
  }
}
