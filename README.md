# Fixed Price Auction Liquidation Pair

[![Code Coverage](https://github.com/generationsoftware/pt-v5-fixed-price-liquidator/actions/workflows/coverage.yml/badge.svg)](https://github.com/generationsoftware/pt-v5-fixed-price-liquidator/actions/workflows/coverage.yml?)
![MIT license](https://img.shields.io/badge/license-MIT-blue)

The FixedPriceLiquidationPair is designed to liquidate accrued yield on PoolTogether V5 vaults.  The Fixed Price Auction has a fixed price for the yield. Once the yield accrues to the fixed price value, arbitrageurs are motivated to swap.

## Deployments

| Chain | Contract | Address |
| ---- | ----- | ------ |
| Ethereum | FixedPriceLiquidationPairFactory | [0xa1739ECE7a90243443543EA57EB5bfB5f4f8E606](https://etherscan.io/address/0xa1739ECE7a90243443543EA57EB5bfB5f4f8E606) |
| Ethereum | FixedPriceLiquidationRouter | [0x91b718F250A74Ad80da828d7D60b13993275d43c](https://etherscan.io/address/0x91b718F250A74Ad80da828d7D60b13993275d43c) |

## Motivation

The fixed price lets us efficiently liquidate yield for vaults that have very low amounts of TVL.

## How it works

At any time a liquidator can swap the liquidatable balance for the fixed price of tokens.

## Smoothing

The fixed-price Liquidation Pair offers smoothing, so that spikes in yield do not result in inefficient auctions.

Some yield sources may accrue in bursts; this means there would be periods of time where there is no yield, then large bursts of yield. This is not ideal, as the algorithm works best with consistent yield growth.

For example, the Prize Pool in PoolTogether V5 will accrue reserve when the draw occurs. For a daily draw, this means that the reserve increases once per day.

The fixed-price Liquidation Pair also takes a "smoothing" parameter during construction. Smoothing is applied as a multiplier of the currently available balance.

$$auctionTokens = (1 - smoothing) * availableBalance$$

For example, if smoothing = 0.9 and there are 100 tokens available to auction, then only 10 will be auctioned. Each subsequent auction will be for 10% of the remaining tokens.
