// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/cryptography/MerkleProof.sol" ;


// - A user can get whitelisted , without paying gas fees 
// -  just sign a message , which is made by keccak256 hashing algorithm

contract Whitelist {

    bytes32 public merkleRoot ;

    constructor(bytes32 _merkleRoot) {
        /// provide the merkle root initially which is obtained by using all the address whitelisted 
        merkleRoot = _merkleRoot ;
    }

    /// @dev to check if the address is in the whitelist 
    /// @param proof - proof which the user has 
    /// @param maxAllowanceToMint - max tokens that can be minted 
    /// @return bool - check the verification is true or not 
    function checkInWhitelist(bytes32[] calldata proof, uint64 maxAllowanceToMint) view public returns (bool) {

        /// keccak256 is a hashing function which can hash any amount of data we provide ,function used for all merkle trees
        bytes32 leaf = keccak256(abi.encode(msg.sender, maxAllowanceToMint));

        /// internal merkleproof function from openzepplin contract 
        bool verified = MerkleProof.verify(proof, merkleRoot,leaf );
        return verified ;

    }

}