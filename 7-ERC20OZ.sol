// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// import of ERC20 contract from openzepplin
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol" ;

/// this contract can be used anytime when we need to create a token
/// automatically inehrit functionss
contract Mytoken is ERC20 {
    constructor(string memory name , string memory symbol) ERC20 (name,symbol) {
        _mint(msg.sender,100 * 10**uint(decimals())) ;
}
