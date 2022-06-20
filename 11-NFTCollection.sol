// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @dev ERC721Enumerable implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */

// Task
// - Make a contract to make a NFT collection of 10 NFTs 
// - To mint & transfer these tokens
// - withdraw function for owner

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";

  contract MyNFTCollection is ERC721Enumerable, Ownable {
      /**
       * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
       * token will be the concatenation of the `baseURI` and the `tokenId`.
       */
      string _baseTokenURI;

      //  _price is the price of one NFT
      uint256 public _price = 0.01 ether;

      // _paused is used to pause the contract in case of an emergency
      bool public _paused;

      // max number of
      uint256 public maxTokenIds = 20;

      // total number of tokenIds minted
      uint256 public tokenIds;

      modifier onlyWhenNotPaused {
          require(!_paused, "Contract currently paused");
          _;
      }

      constructor (string memory baseURI, address whitelistContract) ERC721(" ", "CD") {
          _baseTokenURI = baseURI;
      }

      function mint() public payable onlyWhenNotPaused {
          require(tokenIds < maxTokenIds, "Exceed maximum supply");
          require(msg.value >= _price, "Ether sent is not correct");
          tokenIds += 1;
          _safeMint(msg.sender, tokenIds);
      }

      /**
      * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
      * returned an empty string for the baseURI
      */

      /// override can be used to overwrite a function whichn is present in the parent contract.
      function _baseURI() internal view virtual override returns (string memory) {
          return _baseTokenURI;
      }

      /**
      * @dev setPaused makes the contract paused or unpaused
       */
      function setPaused(bool val) public onlyOwner {
          _paused = val;
      }

      /**
      * @dev withdraw sends all the ether in the contract
      * to the owner of the contract
       */
      function withdraw() public onlyOwner  {
          address _owner = owner();
          uint256 amount = address(this).balance;
          (bool sent, ) =  _owner.call{value: amount}("");
          require(sent, "Failed to send Ether");
      }

       // Function to receive Ether. msg.data must be empty
      receive() external payable {}

      // Fallback function is called when msg.data is not empty
      fallback() external payable {}
  }