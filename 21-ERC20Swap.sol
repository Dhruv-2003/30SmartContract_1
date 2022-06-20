// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol" ;

// - 2 tokens can be swapped 
// - decided by the users for the exchange price of both the token

contract swapToken{

    // creating instance of the 2 tokens we need to transfer 
    IERC20 public token1;
    address public owner1;
    uint public amount1;
    IERC20 public token2;
    address public owner2;
    uint public amount2;

    // taking in the address of deployed contracts of the tokens, the owners and their respective amount to be transferred

    constructor(
        address _token1,
        address _owner1,
        uint _amount1,
        address _token2,
        address _owner2,
        uint _amount2

    ){

        //intialize the token for the transfer function to work ;
       token1 = IERC20(_token1) ;
       owner1 = _owner1 ;
       amount1 = _amount1 ;


       //intialize the token for the transfer function to work ;
       token2 = IERC20(_token2) ;
       owner2 = _owner2 ;
       amount2 = _amount2 ;

    }

    /// swap erc20 tokens 
    function swap() public{
        // check that owners are only calling this function
        require(msg.sender == owner1 || msg.sender == owner2, "Not owner") ;

        // check that the approved amount to be able to spend is equal to the amount for the swap
        require(
            token1.allowance(owner1 ,address(this)) >= amount1 ,
            "token 1 allowance too low to spend"
        );

        require(
            token1.allowance(owner2 ,address(this)) >= amount2 ,
            "token 2 allowance too low to spend"
        );

        // transder those tokens 1-1 , with the amount specified 

        _safeTransferFrom(token1 ,owner1 , owner2 , amount1) ;
        _safeTransferFrom(token2 ,owner2 , owner1 , amount2) ;
        
    }

    /// transfer the tokens
    function _safeTransferFrom(IERC20 token , address sender,  address recepient, uint amount)
    private{
        // sending the tokens using transferFrom and getting the output in boolean 
        bool sent= token.transferFrom(sender, recepient, amount);

        require(sent ,"Transfer Failed") ;
    }
}