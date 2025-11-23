// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./vestingLogic/LinearVesting.sol";

/// @notice Simple factory / forwarder for deploying Vesting schedules
/// @dev Deploys a `Vesting` instance per schedule and allows forwarding claims
contract LinearVestingFactory {
    struct Record {
        address beneficiary;
        uint256 allocation;
    }

    address public owner;
    address[] public vestings;

    event VestingCreated(address indexed vesting);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not a Owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Deploy a new Vesting contract with the provided schedule params
    /// @dev Returns the deployed Vesting contract address
    function createVesting(address _beneficiary, uint256 _totalTokens, uint256 _startTime, uint256 _duration)
        public
        returns (address)
    {
        require(msg.sender == owner, "Not owner");

        LinearVesting v = new LinearVesting(_beneficiary, _totalTokens, _startTime, _duration);

        vestings.push(address(v));
        emit VestingCreated(address(v));
        return address(v);
    }

    /// @notice Forward a linear claim to a deployed Vesting instance
    /// @param index Index of the vesting in the factory's list
    /// @return claimed Amount returned by Vesting.linearVesting()
    function claimLinear(uint256 index) external returns (uint256 claimed) {
        address vestingAddr = vestings[index];
        claimed = LinearVesting(vestingAddr).linearVestingClaim();
    }

    /// @notice Number of Vesting instances created
    function vestingCount() external view returns (uint256) {
        return vestings.length;
    }

    function createInvestor( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _duration
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _duration);
    }

    function createDeveloper( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _duration
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _duration);
    }

    function createMarketing( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _duration
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _duration);
    }

    function createCommunity( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _duration
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _duration);
    }

    function createReserve( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _duration
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _duration);
    }
}
