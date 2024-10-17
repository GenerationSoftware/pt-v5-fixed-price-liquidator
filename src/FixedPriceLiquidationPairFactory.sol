// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ILiquidationSource, FixedPriceLiquidationPair } from "./FixedPriceLiquidationPair.sol";

/// @title FixedPriceLiquidationPairFactory
/// @author G9 Software Inc.
/// @notice Factory contract for deploying FixedPriceLiquidationPair contracts.
contract FixedPriceLiquidationPairFactory {
    /* ============ Events ============ */

    /// @notice Emitted when a new FixedPriceLiquidationPair is created
    /// @param pair The address of the new pair
    /// @param source The liquidation source that the pair is using
    /// @param tokenIn The input token for the pair
    /// @param tokenOut The output token for the pair
    /// @param targetAuctionPrice The minimum auction size in output tokens
    /// @param smoothingFactor The 18 decimal smoothing fraction for the liquid balance
    event PairCreated(
        FixedPriceLiquidationPair indexed pair,
        ILiquidationSource source,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 targetAuctionPrice,
        uint256 smoothingFactor
    );

    /* ============ Variables ============ */

    /// @notice Tracks an array of all pairs created by this factory
    FixedPriceLiquidationPair[] public allPairs;

    /* ============ Mappings ============ */

    /// @notice Mapping to verify if a FixedPriceLiquidationPair has been deployed via this factory.
    mapping(address pair => bool wasDeployed) public deployedPairs;

    /// @notice Creates a new FixedPriceLiquidationPair and registers it within the factory
    /// @param _source The liquidation source that the pair will use
    /// @param _tokenIn The input token for the pair
    /// @param _tokenOut The output token for the pair
    /// @param _targetAuctionPrice The initial auction price
    /// @param _smoothingFactor The degree of smoothing to apply to the available token balance
    /// @return The new liquidation pair
    function createPair(
        ILiquidationSource _source,
        address _tokenIn,
        address _tokenOut,
        uint256 _targetAuctionPrice,
        uint256 _smoothingFactor
    ) external returns (FixedPriceLiquidationPair) {
        FixedPriceLiquidationPair _liquidationPair = new FixedPriceLiquidationPair(
            _source,
            _tokenIn,
            _tokenOut,
            _targetAuctionPrice,
            _smoothingFactor
        );

        allPairs.push(_liquidationPair);
        deployedPairs[address(_liquidationPair)] = true;

        emit PairCreated(
            _liquidationPair,
            _source,
            _tokenIn,
            _tokenOut,
            _targetAuctionPrice,
            _smoothingFactor
        );

        return _liquidationPair;
    }

    /// @notice Total number of FixedPriceLiquidationPair deployed by this factory.
    /// @return Number of FixedPriceLiquidationPair deployed by this factory.
    function totalPairs() external view returns (uint256) {
        return allPairs.length;
    }
}
