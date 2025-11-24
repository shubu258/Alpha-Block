//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ILoopAirDrop {
    /* -------------------------------------------------------------------------- */
    /*                               VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Check whether a user is blacklisted
    /// @param user address to check
    function isBlackListed(address user) external view returns (bool);

    /* -------------------------------------------------------------------------- */
    /*                              ADMIN FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Add an address to the blacklist
    /// @param user address to blacklist
    function addBlacklist(address user) external;

    /// @notice Remove an address from the blacklist
    /// @param user address to unblacklist
    function removeBlacklist(address user) external;

    /* -------------------------------------------------------------------------- */
    /*                             AIRDROP FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Distribute tokens from contract balance
    /// @param recipients list of addresses
    /// @param amounts matching amounts for each address
    function airDrop(address[] calldata recipients, uint256[] calldata amounts) external;

    /// @notice Distribute tokens from sender's balance (requires approval)
    /// @param recipients list of addresses
    /// @param amounts matching amounts for each address
    function airDropFrom(address[] calldata recipients, uint256[] calldata amounts) external;
}
