// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./vestingLogic/TimeVesting.sol";

/// @notice Simple factory / forwarder for deploying Vesting schedules
/// @dev Deploys a `Vesting` instance per schedule and allows forwarding claims
contract TimeVestingFactory {
    /// @notice Record of step-based vesting allocation details
    /// @param beneficiary Address receiving vested tokens
    /// @param allocation Total token amount allocated
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

    /// @notice Initialize factory and set deployer as owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Deploy a new TimeVesting contract with step-based schedule
    /// @param _beneficiary Address that will receive vested tokens
    /// @param _totalTokens Total amount of tokens to vest
    /// @param _startTime Unix timestamp when vesting begins
    /// @param _stepTime Duration of each vesting step in seconds
    /// @param _stepCount Total number of steps in the vesting schedule
    /// @return Address of the deployed TimeVesting contract
    function createVesting(
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _stepTime,
        uint256 _stepCount
    ) public returns (address) {
        require(msg.sender == owner, "Not owner");

        TimeVesting v = new TimeVesting(_beneficiary, _totalTokens, _startTime, _stepTime, _stepCount);

        vestings.push(address(v));
        emit VestingCreated(address(v));
        return address(v);
    }

    /// @notice Forward a linear claim to a deployed Vesting instance
    /// @param index Index of the vesting in the factory's list
    /// @return claimed Amount returned by Vesting.linearVesting()
    function claimLinear(uint256 index) external returns (uint256 claimed) {
        address vestingAddr = vestings[index];
        claimed = TimeVesting(vestingAddr).stepVesting();
    }

    /// @notice Number of Vesting instances created
    function vestingCount() external view returns (uint256) {
        return vestings.length;
    }

    /// @notice Deploy a TimeVesting contract for investor category
    /// @param _beneficiary Investor address receiving vested tokens
    /// @param _totalTokens Total tokens allocated to investor
    /// @param _startTime Vesting start timestamp
    /// @param _stepTime Duration of each vesting step in seconds
    /// @param _stepCount Total number of vesting steps
    /// @return Address of the deployed vesting contract
    function createInvestor( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _stepTime,
        uint256 _stepCount
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _stepTime, _stepCount);
    }

    /// @notice Deploy a TimeVesting contract for developer category
    /// @param _beneficiary Developer address receiving vested tokens
    /// @param _totalTokens Total tokens allocated to developer
    /// @param _startTime Vesting start timestamp
    /// @param _stepTime Duration of each vesting step in seconds
    /// @param _stepCount Total number of vesting steps
    /// @return Address of the deployed vesting contract
    function createDeveloper( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _stepTime,
        uint256 _stepCount
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _stepTime, _stepCount);
    }

    /// @notice Deploy a TimeVesting contract for marketing category
    /// @param _beneficiary Marketing address receiving vested tokens
    /// @param _totalTokens Total tokens allocated to marketing
    /// @param _startTime Vesting start timestamp
    /// @param _stepTime Duration of each vesting step in seconds
    /// @param _stepCount Total number of vesting steps
    /// @return Address of the deployed vesting contract
    function createMarketing( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _stepTime,
        uint256 _stepCount
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _stepTime, _stepCount);
    }

    /// @notice Deploy a TimeVesting contract for community category
    /// @param _beneficiary Community address receiving vested tokens
    /// @param _totalTokens Total tokens allocated to community
    /// @param _startTime Vesting start timestamp
    /// @param _stepTime Duration of each vesting step in seconds
    /// @param _stepCount Total number of vesting steps
    /// @return Address of the deployed vesting contract
    function createCommunity( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _stepTime,
        uint256 _stepCount
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _stepTime, _stepCount);
    }

    /// @notice Deploy a TimeVesting contract for reserve category
    /// @param _beneficiary Reserve address receiving vested tokens
    /// @param _totalTokens Total tokens allocated to reserve
    /// @param _startTime Vesting start timestamp
    /// @param _stepTime Duration of each vesting step in seconds
    /// @param _stepCount Total number of vesting steps
    /// @return Address of the deployed vesting contract
    function createReserve( /* address token, */
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _startTime,
        uint256 _stepTime,
        uint256 _stepCount
    ) external onlyOwner returns (address) {
        return createVesting(_beneficiary, _totalTokens, _startTime, _stepTime, _stepCount);
    }
}
