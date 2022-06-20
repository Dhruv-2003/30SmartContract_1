// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Piggy Bank
// -  User can deposit in the wallet 
// - Owner can Withdraw the amount
// - The Contract should be destroyed after withdrawal

contract PiggyBank{
    address public owner;

    event Deposit(uint amount) ;
    event Withdraw(uint amount);

    constructor(){
        owner == payable(msg.sender);

    }

    modifier onlyOwner() {
        require(msg.sender==owner ,"You are not owner");
        _;
        /// usage of _(underscore indicates when to execute the function where modifier is used)
    }

    receive() external payable {
        emit Deposit(msg.value);
    }

    fallback() external payable{}

    // to withdraw the amount owner needs 
    function withdraw(uint amount) external onlyOwner{
        payable(msg.sender).transfer(amount) ;
        emit Withdraw(address(this).balance);
        selfdestruct(payable(owner)) ; 
        /// selfdestruct can be used to destory the contract 
        /// and send all the eth to the address mentioned  ,it deleted the ABI associated with it , therefore no function call work 
        /// there can be an attack too using selfdestruct where user can force send ether from attack contract
        /// to the target contract , destructing this attack contract , more on that in upcoming thread

    }

}