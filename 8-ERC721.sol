// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ERC721 
// - A ERC721 Token with a mint method 
// - Openzepplin library can be used

// Import the openzepplin contracts
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/ERC721.sol";
 
// MyNFT is  ERC721 signifies that the contract we are creating imports ERC721 and follows ERC721 contract from openzeppelin
contract myNFT is ERC721 {

    /// assigning the rate & supply
    uint256 rate = 0.01 ether;
    uint256 supply = 10000;

    uint256 minted = 0;

    constructor() ERC721("MyNFT", "MN") {
        // mint an NFT to yourself
        _mint(msg.sender, 1);
    }

    // to mint the NFT 
    function mint() public payable {
        require(minted+1<=supply,"Exceeded maximum NFT supply");
        require(msg.value >= rate,"Not Enough Ether");
        _mint(msg.sender, 1);
        minted += 1 ;
    }

    // to withdraw the amount by the owner 
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