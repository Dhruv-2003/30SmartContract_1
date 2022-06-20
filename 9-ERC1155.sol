// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// - create  a ERC1155 token standard , that enable batch mint and batch transfer 
// - Multi token standard for NFT and tokens
// - Openzepplin library can be used

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";

contract MyNFT is ERC1155, Ownable {
    // _paused is used to pause the contract in case of an emergency
    bool public _paused;

    // baseUri for the nft metadata
    string _baseTokenURI ;

    // rate and supply
    uint256 rate = 0.01 ether;
    uint256 supply = 10000;
    uint256 minted = 0;


    /// pause modifier to check if the contract is not paused
    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    //base uri is the location where you nft data is stored using json format , be it is IPFS too
    constructor(string memory baseURI) ERC1155(baseURI) {
        _baseTokenURI = baseURI;
    }

    ///  using payable to make the function payable while minting
    function mint() public payable {
        require(minted+1<=supply,"Exceeded maximum CricDAO NFT supply");
        require(msg.value >= rate,"Not Enough Ether");
        _mint(msg.sender, 1, 1, "");
        minted += 1 ;
    }

    /**
     * @dev setPaused makes the contract paused or unpaused 
     * it is helpful when launching a main chain project to stop the minting in case of any issue.
     */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    /**
     * @dev withdraw sends all the ether in the contract
     * to the owner of the contract
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}