// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Ether Wallet
// - Should accept Ether 
// - Owner will be able to withdraw

contract EtherWallet {

    // address of the owner set at the deployement of the contract
    address payable public owner;

    // event for the withdrawl and deposit
    event Deposit(address indexed account , uint amount) ;
    event Withdraw(address indexed account, uint amount );

    constructor(){
        owner = payable(msg.sender) ; // payable is used to indicate that this address must be paid 
    }

    // to check onlyOwner can call some function
    modifier onlyOwner() {
        require(msg.sender==owner, "caller is not owner") ;
        _; 
    } 


    // to fetch the balance of the wallet i.e. this Contract
    function getBalance() external view returns(uint balance){
        return address(this).balance ;
    }

    // to withdraw the amount owner needs 
    function withdraw(uint amount) external onlyOwner{
        payable(msg.sender).transfer(amount) ;

        emit Withdraw(msg.sender, amount);
    }

    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }

    fallback() external payable{}


    ////Tip///
    /// underscore is the special character which is only used inside the function modifier 
    /// this tells that after this condition the other function will be executed. 
    /// if the underscore was there in the first then fist that function will be executed than the condition will be checked.
}