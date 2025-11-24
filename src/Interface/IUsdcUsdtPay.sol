// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IUsdcUsdtPay
/// @notice Interface for USDT/USDC/native currency price calculation module
interface IUsdcUsdtPay {

    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    error PublicSale__InvalidDecimals();
    error PublicSale__PriceInvalid();

    /* -------------------------------------------------------------------------- */
    /*                              VIEW / PURE CALLS                             */
    /* -------------------------------------------------------------------------- */

    /// @notice Calculate USDT cost for purchasing tokens
    /// @param tokenAmount Raw token amount including decimals
    /// @param tokenDecimals Token decimals (e.g., 18 or 6)
    /// @param tokenPriceUsdt Token price in USDT scaled to 6 decimals
    /// @return USD value in USDT's 6 decimals
    function buyFromUsdt(
        uint256 tokenAmount,
        uint256 tokenDecimals,
        uint256 tokenPriceUsdt
    ) external pure returns (uint256);


    /// @notice Calculate USDC cost for purchasing tokens
    /// @param tokenAmount Raw token amount including decimals
    /// @param tokenDecimals Token decimals
    /// @param tokenPriceUsdc Token price in USDC scaled to 6 decimals
    /// @return USD value in USDC's 6 decimals
    function buyFromUsdc(
        uint256 tokenAmount,
        uint256 tokenDecimals,
        uint256 tokenPriceUsdc
    ) external pure returns (uint256);


    /// @notice Calculate native currency cost using Chainlink price feed
    /// @param tokenAmount Raw token amount including decimals
    /// @param tokenDecimals Token decimals
    /// @param nativeCurrency Address of Chainlink price feed
    /// @return Required native token amount (18 decimals)
    function buyTokenNative(
        uint256 tokenAmount,
        uint256 tokenDecimals,
        address nativeCurrency
    ) external view returns (uint256);


    /* -------------------------------------------------------------------------- */
    /*                                  OWNER VIEW                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns contract owner
    function owner() external view returns (address);
}
