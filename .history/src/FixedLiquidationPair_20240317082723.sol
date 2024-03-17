// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ILiquidationSource } from "pt-v5-liquidator-interfaces/interfaces/ILiquidationSource.sol";
import { ILiquidationPair } from "pt-v5-liquidator-interfaces/interfaces/ILiquidationPair.sol";

contract FixedLiquidationPair is ILiquidationPair {

    ILiquidationSource public immutable source;
    uint32 public immutable targetAuctionPeriod;
    uint224 public immutable minimumAuctionAmount;

    IERC20 internal _tokenIn;
    uint48 public lastAuctionAt;
    uint192 public lastAuctionPrice;  

    constructor (
        ILiquidationSource _source,
        uint256 _targetAuctionPeriod,
        uint256 _minimumAuctionAmount,
        address __tokenIn) {
        source = _source;
        _tokenIn = __tokenIn;
        targetAuctionPeriod = _targetAuctionPeriod;
        minimumAuctionAmount = _minimumAuctionAmount;
    }

    function _computePrice() {
        
    }

  /**
   * @notice Returns the token that is used to pay for auctions.
   * @return address of the token coming in
   */
  function tokenIn() external returns (address);

  /**
   * @notice Returns the token that is being auctioned.
   * @return address of the token coming out
   */
  function tokenOut() external returns (address);

  /**
   * @notice Get the address that will receive `tokenIn`.
   * @return Address of the target
   */
  function target() external returns (address);

  /**
   * @notice Gets the maximum amount of tokens that can be swapped out from the source.
   * @return The maximum amount of tokens that can be swapped out.
   */
  function maxAmountOut() external returns (uint256);

  /**
   * @notice Swaps the given amount of tokens out and ensures the amount of tokens in doesn't exceed the given maximum.
   * @dev The amount of tokens being swapped in must be sent to the target before calling this function.
   * @param _receiver The address to send the tokens to.
   * @param _amountOut The amount of tokens to receive out.
   * @param _amountInMax The maximum amount of tokens to send in.
   * @param _flashSwapData If non-zero, the _receiver is called with this data prior to
   * @return The amount of tokens sent in.
   */
  function swapExactAmountOut(
    address _receiver,
    uint256 _amountOut,
    uint256 _amountInMax,
    bytes calldata _flashSwapData
  ) external returns (uint256);

  /**
   * @notice Computes the exact amount of tokens to send in for the given amount of tokens to receive out.
   * @param _amountOut The amount of tokens to receive out.
   * @return The amount of tokens to send in.
   */
  function computeExactAmountIn(uint256 _amountOut) external returns (uint256);
}