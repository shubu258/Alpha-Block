// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Vesting
/// @notice Implements multiple vesting strategies (linear, cliff, step, event-based)
/// @dev Store-only contract for vesting parameters and release accounting; call claim
/// @dev functions to compute and record claimable amounts. Times in seconds.
contract TimeVesting {
    /// @notice Types of supported vesting schedules
    /// @dev Use these to select which claim function to call

    address beneficiary;
    uint256 totalTokens;
    uint256 startTime;

    uint256 releasedTokens;

    // step vesting
    uint256 stepTime;
    uint256 stepCount;

    /// @notice Emitted when tokens are claimed via a vesting function
    /// @param amount Number of tokens marked as released in this action
    /// @dev This contract does not perform token transfers itself
    event VestingAmount(uint256 amount);

    /**
     * @notice Initialize vesting parameters for a beneficiary
     * @dev Times are expected in seconds; for event-based set `eventWeights`
     * @param _beneficiary Recipient of vested tokens
     */
    constructor(
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        // step vesting
        uint256 _stepTime,
        uint256 _stepCount
    ) {
        require(_totalTokens != 0, "Total Tokens can't be zero");
        require(_startTime >= block.timestamp, "Start time should be greater then current block");
        require(_beneficiary != address(0), "Can't be zero");

        beneficiary = _beneficiary;
        totalTokens = _totalTokens;
        startTime = _startTime;

        stepTime = _stepTime;
        stepCount = _stepCount;
    }

    /// @notice Claim tokens unlocked by discrete step vesting
    /// @dev Each step unlocks a fraction (1/stepCount) of totalTokens
    /// @return claimable Number of tokens claimed and added to releasedTokens
    function stepVesting() external returns (uint256) {
        if (block.timestamp < startTime) {
            return 0;
        }

        // Step 1: Calculate steps passed
        uint256 stepsPassed = (block.timestamp - startTime) / stepTime;

        // Step 2: Cap stepsPassed to stepCount
        if (stepsPassed > stepCount) {
            stepsPassed = stepCount;
        }

        // Step 3: Calculate unlocked tokens
        uint256 unlocked = (totalTokens * stepsPassed) / stepCount;

        // Step 5: Calculate claimable tokens
        uint256 claimable = unlocked - releasedTokens;

        // Step 6: Update releasedTokens
        releasedTokens += claimable;

        return claimable;
    }
}
