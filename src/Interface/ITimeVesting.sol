// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ITimeVesting
/// @notice Interface for step-based time vesting
interface ITimeVesting {

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    /// @notice Emitted when tokens are claimed via a vesting function
    /// @param amount Number of tokens marked as released in this action
    event VestingAmount(uint256 amount);


    /* -------------------------------------------------------------------------- */
    /*                                VIEW FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Return address receiving vested tokens
    function beneficiary() external view returns (address);

    /// @notice Total tokens allocated for vesting
    function totalTokens() external view returns (uint256);

    /// @notice Vesting start timestamp
    function startTime() external view returns (uint256);

    /// @notice Number of tokens already claimed
    function releasedTokens() external view returns (uint256);

    /// @notice Time duration of each vesting step
    function stepTime() external view returns (uint256);

    /// @notice Total number of vesting steps
    function stepCount() external view returns (uint256);


    /* -------------------------------------------------------------------------- */
    /*                             VESTING FUNCTIONS                               */
    /* -------------------------------------------------------------------------- */

    /// @notice Claim tokens unlocked by step-based vesting
    /// @return claimable Number of tokens newly unlocked and claimable
    function stepVesting() external returns (uint256);
}
