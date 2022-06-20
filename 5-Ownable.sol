// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//Ownable 👨👩
// - the owner can be set who is deploying 
// - Check function if the user is owner or not 
// - the ownership can be transferred by calling a function

contract Ownable{

    address public owner ;

    // events
    event OwnershipTransferred(address indexed previousOwner , address indexed newOwner) ;

    constructor() {
        owner == msg.sender ;
    }

    // modifier for owner check 
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function currentOwner() public view returns(address) {
        return owner ;
    }

    function transferOwnership(address newOwner ) public onlyOwner{
        require(newOwner != address(0),"The new Owner address is not valid");
        owner = newOwner ;
        emit OwnershipTransferred(msg.sender , owner) ;
    }

    // function to leave the contract without owner , therefore disabling all the functions that requie onleOwner
    function renounceOwnership() public virtual onlyOwner {
        owner =  address(0) ;

        /// address(0) = 0x00...000 ,  zero address , which is not owner by anyone 
    }

}