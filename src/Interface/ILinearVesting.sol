// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ILinearVesting
/// @notice Interface for linear time-based vesting contracts
interface ILinearVesting {
    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */



    /* -------------------------------------------------------------------------- */
    /*                                VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns the beneficiary address
    function beneficiary() external view returns (address);

    /// @notice Total tokens allocated for vesting
    function totalTokens() external view returns (uint256);

    /// @notice Vesting start timestamp
    function startTime() external view returns (uint256);

    /// @notice Total tokens already released
    function releasedTokens() external view returns (uint256);

    /// @notice Vesting duration (in seconds)
    function duration() external view returns (uint256);

    /* -------------------------------------------------------------------------- */
    /*                              VESTING FUNCTION                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Claim unlocked tokens according to linear vesting schedule
    /// @return claimable Amount of newly unlocked tokens
    function linearVestingClaim() external returns (uint256);
}
