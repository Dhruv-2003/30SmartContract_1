// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// reference : https://rinkeby.etherscan.io/address/0x3916e037016d50c18b703d3852607899db66e74f#code 
/// creating interface for each token , we want to do airdrop from.
interface IERC20 {
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC721 {
  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}
interface IERC1155 {
  function safeTransferFrom( address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

//  A contract that can airdrop tokens , NFT to a set of user
// we will need to approve this contract to spend the tokens on our behalf from our account .

contract BulkAirdrop {
// we are running a loop for all the addresses we need to transfer to and also the respective values .
  
  function bulkAirdropERC20(IERC20 _token, address[] calldata _to, uint256[] calldata _value) public {
    require(_to.length == _value.length, "Receivers and amounts are different length");
    for (uint256 i = 0; i < _to.length; i++) {
      require(_token.transferFrom(msg.sender, _to[i], _value[i]));
    }
  }

  function bulkAirdropERC721(IERC721 _token, address[] calldata _to, uint256[] calldata _id) public {
    require(_to.length == _id.length, "Receivers and IDs are different length");
    for (uint256 i = 0; i < _to.length; i++) {
      _token.safeTransferFrom(msg.sender, _to[i], _id[i]);
    }
  }

  function bulkAirdropERC1155(IERC1155 _token, address[] calldata _to, uint256[] calldata _id, uint256[] calldata _amount) public {
    require(_to.length == _id.length, "Receivers and IDs are different length");
    for (uint256 i = 0; i < _to.length; i++) {
      _token.safeTransferFrom(msg.sender, _to[i], _id[i], _amount[i], "");
    }
  }
}