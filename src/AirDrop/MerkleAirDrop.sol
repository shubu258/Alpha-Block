// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "../Interface/IMerkleAirDrop.sol";


/// @title MerkleAirDrop
/// @notice Distributes ERC20 tokens using Merkle tree proofs for gas-efficient claims
/// @dev Users prove eligibility with Merkle proofs; prevents double claims
contract MerkleAirDropV1 is IMerkleAirDrop {
    IERC20 public token;
    bytes32 public merkleRoot;

    event BlackListed(address user);
    event UnBlacklisted(address user);


    mapping(address => bool) public claimed;
    mapping(address => bool) public isBlackListed;

    address public owner;

    /// @notice Initialize the Merkle airdrop with token and root hash
    /// @param _token ERC20 token contract to distribute
    /// @param _root Merkle root hash representing all eligible claims
    constructor(IERC20 _token, bytes32 _root) {
        token = _token;
        merkleRoot = _root;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "msg.sender is not the owner");
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

    /// @notice Generate a leaf node for Merkle tree verification
    /// @param user Address of the claimant
    /// @param amount Token amount the user is eligible to claim
    /// @return Hashed leaf node for Merkle proof verification
    function _leaf(address user, uint256 amount) internal pure returns (bytes32) {
        return keccak256(abi.encode(keccak256(abi.encode(user, amount))));
    }

    /// @notice Claim airdrop tokens using a Merkle proof
    /// @param amount Number of tokens the caller is eligible to claim
    /// @param proof Array of Merkle proof hashes proving eligibility
    /// @dev Verifies proof against merkleRoot; prevents double claims
    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(amount != 0, "amount cannot be zero");
        require(!claimed[msg.sender], "Already Claimed");

        bytes32 leaf = _leaf(msg.sender, amount);
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Verification failed");

        claimed[msg.sender] = true;
        require(token.transfer(msg.sender, amount), "Transfer Failed");
    }
}
