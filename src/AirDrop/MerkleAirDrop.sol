// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirDrop {
    IERC20 public token;
    bytes32 public merkleRoot;

    mapping(address => bool) public claimed;

    constructor(IERC20 _token, bytes32 _root) {
        token = _token;
        merkleRoot = _root;
    }

    function _leaf(address user, uint256 amount) internal pure returns (byte32) {
        return keccak256(abi.encode(keccak256(abi.encode(user, amount))));
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(amount != 0, "amount cannot be zero");
        require(!claimed[msg.sender], "Already Claimed");

        bytes32 leaf = _leaf(msg.sender, amount);
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Verification failed");

        claimed[msg.sender] = true;
        require(token.transfer(msg.sender, amount), "Transfer Failed");
    }
}
