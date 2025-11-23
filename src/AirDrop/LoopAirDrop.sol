// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract LoopAirDrop is Ownable {
    IERC20 public token;

    event AirDrop(address indexed receiver, uint256 amount);
    event BlackListed(address user);
    event UnBlacklisted(address user);

    mapping(address => bool) public isBlackListed;

    constructor(IERC20 _token) {
        token = _token;
    }

    function addBlacklist(address user) external onlyOwner {
        require(user != address(0), "Zero address can not be set blacklist");
        isBlackListed[user] = true;
        emit BlackListed(user);
    }

    function removeBlacklist(address user) external onlyOwner { 
        require(isBlackListed[user], "User is not blacklisted");
        isBlackListed[user] = false;
        emit UnBlacklisted(user);
    }

    function airDrop(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Recipients not equal as amount");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Recipient is zero");

            require(!isBlackListed[recipients[i]], "Recipient is Blacklisted");

            token.transfer(recipients[i], amounts[i]);
            emit AirDrop(recipients[i], amounts[i]);
        }
    }

    function airDropFrom(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Recipients not equal as amount");

        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Recipient is zero");

            require(!isBlackListed[recipients[i]], "Recipient is Blacklisted");

            token.transferFrom(msg.sender, recipients[i], amounts[i]);
            emit AirDrop(recipients[i], amounts[i]);
        }
    }
}
