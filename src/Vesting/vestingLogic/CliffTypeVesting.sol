// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Vesting
/// @notice Implements multiple vesting strategies (linear, cliff, step, event-based)
/// @dev Store-only contract for vesting parameters and release accounting; call claim
/// @dev functions to compute and record claimable amounts. Times in seconds.
contract VestingCliff {

    address beneficiary;
    uint256 totalTokens;
    uint256 vestingTime;
    uint256 startTime;

    uint256 releasedTokens;

    // vesting + cliff
    uint256 cliffMonth;

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
        uint256 _cliffTime
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

}
