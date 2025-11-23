//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;



contract UsdcUsdtPay {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    // USDT payment
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

    //  USDC payment 
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
