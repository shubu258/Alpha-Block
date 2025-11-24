// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IMerkleAirDrop {
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

    /// @notice Claim airdrop tokens using a Merkle proof
    /// @param amount Number of tokens the caller is eligible to claim
    /// @param proof Array of Merkle proof hashes proving eligibility
    /// @dev Verifies proof against merkleRoot; prevents double claims
    function claim(uint256 amount, bytes32[] calldata proof) external;
}
