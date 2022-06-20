// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// multiple owners for a wallet
///submit a transaction by one owner
///approve and revoke approval of pending transcations by others
///anyone can execute a transcation after enough owners has approved it.

contract MultiSigWallet{
    event Deposit(address indexed sender , uint amount, uint balance ) ;
    event Submit(
        address indexed owner,
        uint indexed txIndex,
        address indexed to ,
        uint value ,
        bytes data   
        ) ;
    event Confirm(address indexed owner , uint indexed txIndex) ;
    event Revoke(address indexed owner , uint indexed txIndex) ; 
    event Execute(address indexed owner , uint indexed txIndex) ;

    struct Transaction{
        address to;
        uint value ;
        bytes data ;
        bool executed ;
        uint numConfirmations ;
    }

    address[] public owners ;
    mapping(address => bool) public isOwner ;
    uint public required ;

    Transaction[] public transactions ;

    // mapping from tx index => owner => bool
    mapping(uint => mapping(address => bool)) public isConfirmed ;


    constructor(address[] memory _owners , uint _required){
        require(_owners.length>0,"Owners required");
        require(_required > 0 && _required <= _owners.length,"Invalid required owners");

        for(uint i ; i< _owners.length ; i++ ){
            address owner = _owners[i] ;
            require(owner != address(0),"invalid owner") ;
            require(!isOwner[owner], "owner is not unique") ;

            isOwner[owner] =true ;
            owners.push(owner);
        }

        required = _required ;

    }

    receive() external payable{
        emit Deposit(msg.sender, msg.value , address(this).balance);
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender],"not owner");
        _;
    }

    modifier txExists(uint _txIndex){
        require(_txIndex < transactions.length , "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txIndex){
        require(!transactions[_txIndex].executed ,"tx already executed ") ;
        _;

    }

    modifier notConfirmed(uint _txIndex){
        require(!isConfirmed[_txIndex][msg.sender],"tx already confirmed");
        _;
    }




    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner{
        uint txIndex = transactions.length ;
        
        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0  
            })
        );

        emit Submit(msg.sender , txIndex , _to , _value ,_data) ;
    }

    function confirmTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notConfirmed(_txIndex) notExecuted(_txIndex){
          Transaction storage transaction = transactions[_txIndex];
          transaction.numConfirmations +=1 ;
          isConfirmed[_txIndex][msg.sender] = true ;

          emit Confirm(msg.sender, _txIndex) ;
    }

    function executeTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex){
         Transaction storage transaction = transactions[_txIndex];

         require(transaction.numConfirmations >= required,"Cannot Execute") ;
         transaction.executed = true;

         emit Execute(msg.sender , _txIndex) ;

    }

    function revokeConfirmation(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender],"tx not confirmed") ;

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false ;

        emit Revoke(msg.sender , _txIndex) ;
    }

    function getOwners() public view returns(address[] memory) {
        return owners ;
    }

    function getTransaction(uint _txIndex) public view returns(
        address to ,
        uint value ,
        bytes memory data ,
        bool executed ,
        uint numConfirmations ){
            Transaction storage transaction = transactions[_txIndex];

            return(
                transaction.to,
                transaction.value,
                transaction.data,
                transaction.executed,
                transaction.numConfirmations
            );
        }

}