// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* ERC20 is an implementation of the Interface defined in IERC20 .
 *IERC20 defines function signatures without specifying behavior; the function names, inputs and outputs, but no process.
 *ERC20 inherits this Interface and is required to implement all the functions described or else the contract will not deploy 
*/

interface IERC20{
    function totalSupply() external view returns(uint) ;

    function balanceOf(address account) external view returns(uint);

    function transfer(address recipient , uint amoun) external returns(bool) ;

    function allowance(address owner, address apender) external view returns(uint) ;

    function approve(address spender, uint amount) external returns(bool) ;

    function transferFrom(
        address sender,
        address recepient,
        uint amount
    ) external returns(bool) ;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

// ERC20 
// - An ERC20 token with a name and symbol 
// - Mint , Burn , Transfer functions 
// - OpenZepplin library can not be used

contract ERC20 is IERC20 {
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "Solidity by Example";
    string public symbol = "SOLBYEX";
    uint8 public decimals = 18;

    /// no constructor is needed , as we have already defined all the variables requires

    /// transfer to recepient 
    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /// approval to someone else to spend some amount
    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// transfer from sender to recepient 
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    /// mint tokens and increase total supply
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    /// burn some tokens and decrease supply
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}