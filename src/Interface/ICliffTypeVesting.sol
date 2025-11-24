// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IVestingCliff
/// @notice Interface for cliff + linear vesting schedule
interface ICliffTypeVesting {

    /* -------------------------------------------------------------------------- */
    /*                                VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Address receiving the vested tokens
    function beneficiary() external view returns (address);

    /// @notice Total tokens allocated to vesting
    function totalTokens() external view returns (uint256);

    /// @notice Total vesting duration (including cliff)
    function vestingTime() external view returns (uint256);

    /// @notice Vesting start timestamp
    function startTime() external view returns (uint256);

    /// @notice Total tokens already released
    function releasedTokens() external view returns (uint256);

    /// @notice Cliff duration in seconds
    function cliffMonth() external view returns (uint256);

    /* -------------------------------------------------------------------------- */
    /*                              VESTING FUNCTION                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Claim tokens unlocked after cliff duration + linear vesting
    /// @return amount Newly unlocked tokens
    function cliffVesting() external returns (uint256);
}
