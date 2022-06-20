// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/access/Ownable.sol";


interface INFT{
    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

}

// - A user whitelisted Can mint the tokens 
// - Check and get functions

contract MyToken is ERC20, Ownable {
      uint256 public constant tokenPrice = 0.001 ether;
      // Each NFT would give the user 10 tokens
      // It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
      // By default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
      // is actually equal to (10 ^ -18) tokens.
      // Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
      uint256 public constant tokensPerNFT = 10 * 10**18;
      // the max total supply is 10000 for Tokens
      uint256 public constant maxTotalSupply = 10000 * 10**18;
      // NFT contract instance
      INFT NFT ;
      // Mapping to keep track of which tokenIds have been claimed
      mapping(uint256 => bool) public tokenIdsClaimed;

      constructor(address _nft) ERC20("MyToken", "MT") {
          NFT = INFT(_nft);
      }


      /// mint tokens
      function mint(uint256 amount) public payable {
          // the value of ether that should be equal or greater than tokenPrice * amount;
          uint256 _requiredAmount = tokenPrice * amount;
          require(msg.value >= _requiredAmount, "Ether sent is incorrect");
          // total tokens + amount <= 10000, otherwise revert the transaction
          uint256 amountWithDecimals = amount * 10**18;
          require(
              (totalSupply() + amountWithDecimals) <= maxTotalSupply,
              "Exceeds the max total supply available."
          );
          // call the internal function from Openzeppelin's ERC20 contract
          _mint(msg.sender, amountWithDecimals);
      }
      
      /// to claim tokens if user owns nft
      function claim() public {
          address sender = msg.sender;
          // Get the number of NFT's held by a given sender address
          uint256 balance = NFT.balanceOf(sender);
          // If the balance is zero, revert the transaction
          require(balance > 0, "You dont own any  NFT's");
          // amount keeps track of number of unclaimed tokenIds
          uint256 amount = 0;
          // loop over the balance and get the token ID owned by `sender` at a given `index` of its token list.
          for (uint256 i = 0; i < balance; i++) {
              uint256 tokenId = NFT.tokenOfOwnerByIndex(sender, i);
              // if the tokenId has not been claimed, increase the amount
              if (!tokenIdsClaimed[tokenId]) {
                  amount += 1;
                  tokenIdsClaimed[tokenId] = true;
              }
          }
          // If all the token Ids have been claimed, revert the transaction;
          require(amount > 0, "You have already claimed all the tokens");
          // call the internal function from Openzeppelin's ERC20 contract
          // Mint (amount * 10) tokens for each NFT
          _mint(msg.sender, amount * tokensPerNFT);
      }

      // Function to receive Ether. msg.data must be empty
      receive() external payable {}

      // Fallback function is called when msg.data is not empty
      fallback() external payable {}
  }
