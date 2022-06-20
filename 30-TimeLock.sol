// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// - A Contract that accepts deposit 
// - Withdrawal after a particular time duration is allowed
// - Before that no one can withdraw any sort of money 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol" ;

contract TimeLock {
    /// duration of the time lock contract 
    uint public constant duration = 365 days ;

    /// immutable keyword can be used to make a variable constant once and for all , no body can change value after that
    uint public immutable end ;
    /// payable makes an address as immutable  
    address payable public immutable owner ;

    constructor (address payable _owner) {
        end = block.timestamp + duration ;
        owner= _owner ;       
    }

    /// @dev to deposit the amount in the contract 
    /// @param token -  the token address which the user wants to deposit
    /// @param amount - 
    function deposit(address token , uint amount) external{
        // directly transfer token by intializing IERC20
        IERC20(token).transferFrom(msg.sender, address(this), amount) ;
    }

    receive() external payable {}

    /// @dev to withdraw the amount after the duration
    /// @param token -  address of token to be withdrawn
    /// @param amount - amount to be withdrawn
    function withdraw(address token ,uint amount) external {

        /// only owner can access
        require(msg.sender == owner,"only owner" );

        /// check the timestamp
        require(block.timestamp >= end ,"too early");

        /// check token and transfer the amount
        if(token == address(0)) {
            owner.transfer(amount);
        }else{
            IERC20(token).transfer(owner,amount) ;
        }
    }


}
