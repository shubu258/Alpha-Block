//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "src/Interface/IUsdcUsdtPay.sol";
import "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


/// @title UsdcUsdtPay
/// @notice Calculates token purchase amounts in USDT, USDC, or native currency
/// @dev Uses Chainlink price feeds for native currency pricing
/// @dev All stablecoin prices are scaled to 6 decimals
contract UsdcUsdtPay is IUsdcUsdtPay{
    address public owner;

    /// @notice Initialize the contract with an owner address
    /// @param _owner Address of the contract owner
    constructor(address _owner) {
        owner = _owner;
    }

    /// @notice Calculate USDT cost for purchasing tokens
    /// @param tokenAmount Raw token amount including decimals
    /// @param tokenDecimals Number of decimals the token uses
    /// @param tokenPriceUsdt Token price in USDT scaled to 6 decimals
    /// @return USD value in USDT's 6 decimals
    function buyFromUsdt(
        uint256 tokenAmount,          // raw units including decimals
        uint256 tokenDecimals,        // e.g. 18 or 6
        uint256 tokenPriceUsdt        // price scaled to 6 decimals
    ) external pure returns (uint256) {

        require(tokenAmount > 0, "tokenAmount cannot be zero");

        uint256 usdValue =
            (tokenAmount * tokenPriceUsdt) / (10 ** tokenDecimals);

        return usdValue;  // returns in USDT's 6 decimals
    }

    /// @notice Calculate USDC cost for purchasing tokens
    /// @param tokenAmount Raw token amount including decimals
    /// @param tokenDecimals Number of decimals the token uses
    /// @param tokenPriceUsdc Token price in USDC scaled to 6 decimals
    /// @return USD value in USDC's 6 decimals
    function buyFromUsdc(
        uint256 tokenAmount,
        uint256 tokenDecimals,
        uint256 tokenPriceUsdc       // price scaled to 6 decimals
    ) external pure returns (uint256) {

        require(tokenAmount > 0, "tokenAmount cannot be zero");

        uint256 usdValue =
            (tokenAmount * tokenPriceUsdc) / (10 ** tokenDecimals);

        return usdValue;  // returns in USDC's 6 decimals
    }


    /// @notice Calculate native currency cost using Chainlink price feed
    /// @param tokenAmount Raw token amount including decimals
    /// @param tokenDecimals Number of decimals the token uses
    /// @param nativeCurrency Address of Chainlink price feed for native/USD pair
    /// @return Native currency amount needed (18 decimals)
    function buyTokenNative(uint256 tokenAmount, uint256 tokenDecimals, address nativeCurrency) external pure returns(uint256){
        require(tokenAmount != 0, "Token Amount should not be zero");

        address nativeUsdFeed = AggregatorV3Interface(nativeCurrency);

        ( uint80 roundId,int256 price, uint256 updatedAt, uint80 answeredInRound ) = nativeUsdFeed.latestRoundData();

        require(price != 0, "price canot be zero");
        require(answeredInRound >= roundId, " Not good ");

        
        uint8 feedDecimals = nativeUsdFeed.decimals();
        if (feedDecimals > 18) revert PublicSale__InvalidDecimals();

        uint256 normalizedPrice;
        if (feedDecimals <= 18) {
            normalizedPrice = uint256(price) * (10 ** (18 - feedDecimals));
        } else {
            // This shouldn't happen with the require above, but defensive programming
            normalizedPrice = uint256(price) / (10 ** (feedDecimals - 18));
        }

        if (normalizedPrice == 0) revert PublicSale__PriceInvalid();
        return (tokenAmount * 1e18) / normalizedPrice;
    }

    

}
   