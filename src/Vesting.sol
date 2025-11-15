// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Vesting
/// @notice Implements multiple vesting strategies (linear, cliff, step, event-based)
/// @dev Store-only contract for vesting parameters and release accounting; call claim
/// @dev functions to compute and record claimable amounts. Times in seconds.
contract Vesting {
    /// @notice Types of supported vesting schedules
    /// @dev Use these to select which claim function to call
    enum VestingType {
        Linear,
        CliffLinear,
        Step,
        EventBased
    }

    address beneficiary;
    uint256 totalTokens;
    uint256 vestingTime;
    uint256 startTime;

    uint256 releasedTokens;

    // vesting + cliff
    uint256 cliffMonth;
    uint256 duration;

    // step vesting
    uint256 stepTime;
    uint256 stepCount;

    uint256[] public eventWeights;
    bool[] public eventCompleted;

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
        uint256 _vestingTime,
        uint256 _startTime,
        uint256 _vestingType,
        // vesting + cliff
        uint256 _cliffTime,
        uint256 _duration,
        // step vesting
        uint256 _stepTime,
        uint256 _stepCount,
        uint256[] memory _eventWeights
    ) {
        require(_totalTokens != 0, "Total Tokens can't be zero");
        require(_startTime >= block.timestamp, "Start time should be greater then current block");
        require(_vestingTime != 0, "Vesting can't be zero");
        require(_beneficiary != address(0), "Can't be zero");

        beneficiary = _beneficiary;
        totalTokens = _totalTokens;
        vestingTime = _vestingTime;
        startTime = _startTime;

        cliffMonth = _cliffTime;
        duration = _duration;

        stepTime = _stepTime;
        stepCount = _stepCount;

        if (_vestingType == uint8(VestingType.EventBased)) {
            eventWeights = _eventWeights;
            eventCompleted = new bool[](_eventWeights.length);
        }
    }

    /// @notice Claim tokens unlocked by linear vesting since start
    /// @dev Calculates unlocked amount by elapsed time and updates releasedTokens
    /// @return claimable Amount of tokens that were marked released by this call
    function linearVesting() external returns (uint256) {
        if (releasedTokens >= totalTokens) {
            return 0;
        }

        if (block.timestamp < startTime) {
            return 0;
        }

        uint256 unlockedTokens;
        uint256 endTime = startTime + vestingTime;

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

    /// @notice Claim tokens after an initial cliff followed by linear vesting
    /// @dev No tokens claimable before cliff end; after cliff uses vestingTime
    /// @return amount Number of tokens claimed and added to releasedTokens
    function cliffVesting() external returns (uint256 amount) {
        if (releasedTokens >= totalTokens) {
            return 0;
        }
        if (block.timestamp <= startTime + cliffMonth) {
            return 0;
        }

        uint256 unlockedTokens;
        if (block.timestamp >= startTime + vestingTime) {
            unlockedTokens = totalTokens;
        } else {
            uint256 notClaimPeriod = startTime + cliffMonth;
            uint256 timePassed = block.timestamp - notClaimPeriod;
            uint256 linearDuration = vestingTime - cliffMonth;
            unlockedTokens = (totalTokens * timePassed) / linearDuration;
        }

        uint256 claimable = unlockedTokens - releasedTokens;

        releasedTokens += claimable;

        return claimable;
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

    /// @notice Claim tokens unlocked by completed off-chain events
    /// @dev Sum eventWeights for completed events and allow claiming the difference
    /// @return claimable Tokens claimed and recorded in releasedTokens
    function eventBasedVesting() external returns (uint256) {
        uint256 unlocked = 0;

        // Sum the weights of all completed events
        for (uint256 i = 0; i < eventWeights.length; i++) {
            if (eventCompleted[i]) {
                unlocked += eventWeights[i];
            }
        }

        // Prevent claiming after full unlock
        if (unlocked <= releasedTokens) {
            return 0;
        }

        uint256 claimable = unlocked - releasedTokens;

        releasedTokens += claimable;

        return claimable;
    }
}
