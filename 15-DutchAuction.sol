// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


/// creating interface for the nft function to be used 
interface IERC721 {
    function transferFrom(
        address _from, 
        address _to,
        uint _nftId
    ) external;
}

// - Seller can deploy and this auction lasts for a time period
// -  Price of NFT decreases , participants can buy by depositing a greater price 
// - Auction ends when a buyer buys NFT

contract DutchAuction {
    // duration of the the contract 
    uint private constant DURATION = 7 days;

    // instance of nft contract
    IERC721 public immutable nft;
    uint public immutable nftId;

    // other variables for the start and end of auction
    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    // discount rate at which the price decreases 
    uint public immutable discountRate;

    /// events
    event sold(address buyer , uint price) ;

    // getting the starting price ,  discount rates and all other info for nft to be auctioned
    constructor(
        uint _startingPrice,
        uint _discountRate,
        address _nft,
        uint _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;

        // starting contract from the deployement time
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        discountRate = _discountRate;


        /// we need to check if the starting price is greater then the discounted rate after the durations
        require(_startingPrice >= _discountRate * DURATION, "starting price < min");

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    // to get the current price of the nft 
    function getPrice() public view returns (uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    // to buy the nft by paying greater price then the current price 
    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");

        uint price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        emit sold(msg.sender, msg.value);

        // to destory the contract after the sale is completed 
        selfdestruct(seller);
    }
}