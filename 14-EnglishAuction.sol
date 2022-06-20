// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IERC721{
    /// creating interface for the function we will be using in our mein contract
    /// to transfer the NFT automatically after the bid.
    function safeTransferFrom(
        address from , 
        address to ,
        uint tokenId
    ) external ;

    function transferFrom(
        address from ,
        address to,
        uint tokenId
    ) external ;
}

// - Seller can deploy and this auction lasts for a time period
// - Participants can bid and the highest bidder wins 
// - Remaining can withdraw and highest one becomes owner  of NFT
// - Seller can withdraw

contract EnglishAuction{
    /// creating events
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount) ;

    // intializing nft contract 
    IERC721 public nft ;
    uint public nftId;

    // assigning seller payable to withdraw the payment later
    address payable public seller;
    uint public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;

    /// taking input which nft from which nft contract is to be sold
    /// the intial bidding amount
    constructor(
        address _nft,
        uint _nftId,
        uint _startingBid
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;

        seller = payable(msg.sender);
        highestBid = _startingBid;
    }


    // function to start the auction 
    function start() external {
        require(!started, "started");
        require(msg.sender == seller, "not seller");

        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        /// using block.timestamp to check, from when the start is called 
        endAt = block.timestamp + 7 days;

        emit Start();
    }


    // the bid function called by the bidder for creating the highest bid 
    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest");

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        /// msg.value is the amount the bidder sends while bidding and sending the bid request
        /// it is the amount the sender sends in the transaction above gas fees 
        highestBid = msg.value;

        emit Bid(msg.sender, msg.value);
    }

    // withdraw function for the bidders who sent eth to the contract for bidding 
    function withdraw() external {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    // to end the sale and transfer the nft to the highest bidder and send the money to the seller
    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;
        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}