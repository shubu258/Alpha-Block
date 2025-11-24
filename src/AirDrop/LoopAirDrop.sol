// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "src/Interface/ILoopAirDrop.sol";


/// @title LoopAirDrop
/// @notice Distributes ERC20 tokens to multiple recipients with blacklist support
/// @dev Requires owner to approve/hold tokens before distribution
contract LoopAirDrop is ILoopAirDrop {
    IERC20 public token;

    /// @notice Emitted when tokens are airdropped to a recipient
    /// @param receiver Address receiving the airdrop
    /// @param amount Number of tokens transferred
    event AirDrop(address indexed receiver, uint256 amount);
    
    /// @notice Emitted when an address is added to the blacklist
    /// @param user Address that was blacklisted
    event BlackListed(address user);
    
    /// @notice Emitted when an address is removed from the blacklist
    /// @param user Address that was unblacklisted
    event UnBlacklisted(address user);

    mapping(address => bool) public isBlackListed;
    
    address public owner; 
    /// @notice Initialize the airdrop contract with a token
    /// @param _token ERC20 token contract address to distribute
    constructor(IERC20 _token) {
        token = _token;
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"Mag.sender is not the owner");
        _;
    }

    /// @notice Add an address to the blacklist to prevent receiving airdrops
    /// @param user Address to blacklist
    function addBlacklist(address user) external onlyOwner {
        require(user != address(0), "Zero address can not be set blacklist");
        isBlackListed[user] = true;
        emit BlackListed(user);
    }

    /// @notice Remove an address from the blacklist
    /// @param user Address to unblacklist
    function removeBlacklist(address user) external onlyOwner { 
        require(isBlackListed[user], "User is not blacklisted");
        isBlackListed[user] = false;
        emit UnBlacklisted(user);
    }

    /// @notice Distribute tokens from contract balance to multiple recipients
    /// @param recipients Array of addresses to receive tokens
    /// @param amounts Array of token amounts matching each recipient
    /// @dev Contract must hold sufficient tokens; skips blacklisted addresses
    function airDrop(address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Recipients not equal as amount");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Recipient is zero");

            require(!isBlackListed[recipients[i]], "Recipient is Blacklisted");

            token.transfer(recipients[i], amounts[i]);
            emit AirDrop(recipients[i], amounts[i]);
        }
    }

    /// @notice Distribute tokens from owner's balance to multiple recipients
    /// @param recipients Array of addresses to receive tokens
    /// @param amounts Array of token amounts matching each recipient
    /// @dev Owner must approve this contract before calling; skips blacklisted addresses
    function airDropFrom(address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Recipients not equal as amount");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Recipient is zero");

            require(!isBlackListed[recipients[i]], "Recipient is Blacklisted");

            token.transferFrom(msg.sender, recipients[i], amounts[i]);
            emit AirDrop(recipients[i], amounts[i]);
        }
    }
}
