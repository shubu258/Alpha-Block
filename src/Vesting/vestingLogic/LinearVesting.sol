// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../Interface/ILinearVesting.sol"


/// @title Vesting
/// @notice Implements multiple vesting strategies (linear, cliff, step, event-based)
/// @dev Store-only contract for vesting parameters and release accounting; call claim
/// @dev functions to compute and record claimable amounts. Times in seconds.
contract LinearVesting is ILinearVesting{
    /// @notice Types of supported vesting schedules
    /// @dev Use these to select which claim function to call

    address beneficiary;
    uint256 totalTokens;
    uint256 startTime;

    uint256 releasedTokens;
    uint256 duration;

    /// @notice Emitted when tokens are claimed via a vesting function
    /// @param amount Number of tokens marked as released in this action
    /// @dev This contract does not perform token transfers itself
    event VestingAmount(uint256 amount);

    /**
     * @notice Initialize vesting parameters for a beneficiary
     * @dev Times are expected in seconds; for event-based set `eventWeights`
     * @param _beneficiary Recipient of vested tokens
     */
    constructor(address _beneficiary, uint256 _totalTokens, uint256 _startTime, uint256 _duration) {
        require(_totalTokens != 0, "Total Tokens can't be zero");
        require(_startTime >= block.timestamp, "Start time should be greater then current block");
        require(_beneficiary != address(0), "Can't be zero");

        beneficiary = _beneficiary;
        totalTokens = _totalTokens;
        startTime = _startTime;
        duration = _duration;
    }

    /// @notice Claim tokens unlocked by linear vesting since start
    /// @dev Calculates unlocked amount by elapsed time and updates releasedTokens
    /// @return claimable Amount of tokens that were marked released by this call
    function linearVestingClaim() external returns (uint256) {
        if (releasedTokens >= totalTokens) {
            return 0;
        }

        if (block.timestamp < startTime) {
            return 0;
        }

        uint256 unlockedTokens;
        uint256 endTime = startTime + duration;

        if (block.timestamp >= endTime) {
            unlockedTokens = totalTokens;
        } else {
            uint256 timePassed = block.timestamp - startTime;
            unlockedTokens = (totalTokens * timePassed) / duration;
        }

        uint256 claimable = unlockedTokens - releasedTokens;

        releasedTokens += claimable;

        return claimable;
    }
}
