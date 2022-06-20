// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// - fetch the price of currency on chain with Chainlink contracts oracle
// - can refer docs 

interface AggregatorV3Interface {
    function latestRoundData() external view returns(uint80 roundId,int answer , uint startedAt,uint updatedAt,uint80 answeredInRound) ;
}

contract ChainlinkPrice{
    AggregatorV3Interface internal priceFeed ;

    //Address of the pair for which the price is requried
    //find them here : https://docs.chain.link/docs/reference-contracts/
    // select the chain and the pair and pass the address
    constructor(address _address) {
        priceFeed = AggregatorV3Interface(_address) ;
    }


    /// @dev - get the latest price 
    /// @return int - price fetched 
    function getLatestPrice() public view returns(int) {
        (uint80 roundId,int price, uint startedAt,uint timeStamp ,uint80 answeredInRound) =  priceFeed.latestRoundData();

        return price / 1e8 ; // return price acc to the pair , 
        // for Eg -  ETH/USD  price is scaled by 10**8 ;
    }
}