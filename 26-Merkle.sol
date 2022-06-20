// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// importing the openzeppling merkle proof contracts to access the verify function 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/cryptography/MerkleProof.sol" ;

// -  should generate Merkle proof & verify it. 


contract Merkle{
    /// merkle root for the merkle tree
    bytes32 public merkleRoot ;

    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot ;

    }

    /// @dev to generate a merkle hash for a set of data 
    /// @param _address - address of msg.sender
    /// @param _nonce -  nonce value just an additional protection
    /// @return _hash - hash value in bytes is returned
    function hash(address _address , uint256 _nonce) public returns(bytes32) {
        return keccak256(abi.encodePacked(_address,_nonce));
    }

    /// @dev verify root with the proof the user has 
    /// @param _proof the proof which can be used to verify
    /// @param _hash the hash which user got while hashing the values
    /// @return bool whether the verification is done or not 
    function verify(bytes32[] calldata _proof ,bytes32 _hash ) public returns(bool){
        bytes leaf = _hash ;
        return MerkleProof.verify(_proof, merkleRoot,leaf );
    }
}