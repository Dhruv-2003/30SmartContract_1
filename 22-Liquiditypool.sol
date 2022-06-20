// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// - Create a pool contract that accepts deposit from lenders , who earn interest on lending
// - User  or borrower can borrow some amount of tokens (limited) , and pay back with some interest for some time period. 
// - lender can withdraw the amount later with some interest 

// interface of the tokens to be awarded as rewards for the user 
interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}



contract LiquidityPool{

    /// intialize token
    IERC20 token;
    uint256 totalSupply;

    /// the rate earned by the lender per second
    uint256 lendRate = 100 ;   
    /// the rate paid by the borrower per second
    uint256 borrowRate = 130 ;

    uint256 peroidBorrowed ;

    ///  struct with amount and date of borrowing or lending 
    struct amount{
        uint amount;
        uint start;
    }

    // mapping to check if the address has lended any amount 
    mapping(address => amount) lendAmount ;
    // mapping for the interest earned by the lender ;
    mapping(address => uint256) earnedInterest ;

    // arrays to store the info about lender & borrowers
    mapping(address => bool) lenders;
    mapping(address => bool) borrowers ;

    // mapping to check if the address has borrowed any amount
    mapping(address => amount) borrowAmount ;
    // mapping for the interest to be paid by the borrower ;
    mapping(address => uint256) payInterest ;

    /// events


    /// making the contract payable and adding the tokens in starting to the pool

    constructor(address _tokenAddress,uint _amount) payable {
        token = IERC20(_tokenAddress);
        token.transferFrom(msg.sender,address(this), _amount);
    }

    /// @dev - to lend the amount by  , add liquidity 
    /// @param _amount - the amount to be lender
    function lend(uint _amount) external {
        require(_amount!= 0 ," amount can not be 0");

        /// transferring the tokens to the pool contract
        token.transferFrom(msg.sender, address(this), _amount);

        /// adding in lending and lenders array for record
        lendAmount[msg.sender].amount = _amount;
        lendAmount[msg.sender].start = block.timestamp;
        lenders[msg.sender] = true ;

        /// updating total supply 
        totalSupply += _amount ;
    }

    /// @dev - to borrow token
    /// @param _amount - amount to be withdraw
    function borrow(uint _amount) external {
        require(_amount!= 0 ," amount can not be 0");

        /// updating records first
        borrowAmount[msg.sender].amount = _amount ;
        borrowAmount[msg.sender].start = block.timestamp ;
        totalSupply -= _amount ;

        /// then transfer 
        token.transfer(msg.sender, _amount);
        borrowers[msg.sender] = true ;
    }


    /// @dev  - repay the whole loan 
    function repay() external {
        /// check borrower
        require(borrowers[msg.sender] ,"not a borrower");

        /// total amount to be repaid with intrest 
        amount storage amount_ = borrowAmount[msg.sender] ;
        uint _amount = (amount_.amount + amount_.amount*((block.timestamp - amount_.start)*borrowRate*1e18)/totalSupply) ;

        require(_amount!= 0 ," amount can not be 0");

        /// transferring the tokens 
        token.transferFrom(msg.sender, address(this), _amount) ;

        /// updating records and deleting the record of borrowing 
        delete borrowAmount[msg.sender] ;
        borrowers[msg.sender] = false ;

        /// update total supply at the end 
        totalSupply += _amount ;

    }

    /// @dev  - to withdraw the amount for the lender
    function withdraw() external {
        /// checking if the caller is a lender or not 
        require(lenders[msg.sender],"you are not a lender");

        // calculating the total amount along with the interest
        amount storage amount_ = lendAmount[msg.sender] ;
        uint _amount = (amount_.amount + amount_.amount*((block.timestamp - amount_.start)*lendRate*1e18)/totalSupply) ;

        require(_amount!= 0 ," amount can not be 0");

        /// deleting the records and updating the list 
        delete lendAmount[msg.sender] ;
        lenders[msg.sender]= false ;

        /// updating total supply earlier before transfering token , so as to be safe from attacks
        totalSupply -= _amount ;

        /// transferring the tokens in the end 
        token.transfer(msg.sender, _amount);


    }

}