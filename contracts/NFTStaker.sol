// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.4;

import "./GODtoken.sol";
import "./NFT/GodNFT.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

contract NFTStaker is Ownable, IERC721Receiver {
using SafeERC20 for IERC20;

  uint256 public totalStaked;
  IERC20 token;
  IERC721 nft;

 // struct to store a stake's token, owner, and earning values
  struct Staker {
    uint256 tokenId;
    uint256 timestamp;
    address owner;
  }

  mapping(uint256 => Staker) public stakers; 
    mapping (address => uint256) public tokenCounter;

   constructor(address _nft, address _token) { 
    nft = IERC721(_nft);
    token = IERC20(_token);
  }

   receive() external payable {}

  function stake(uint256[] calldata tokenIds) external {
    uint256 tokenId;
    totalStaked += tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      require(nft.ownerOf(tokenId) == msg.sender, "not your token");
      require(stakers[tokenId].tokenId == 0, 'already staked');

      nft.transferFrom(msg.sender, address(this), tokenId);
    //   emit NFTStaked(msg.sender, tokenId, block.timestamp);

      stakers[tokenId] = Staker({
        owner: msg.sender,
        tokenId: uint256(tokenId),
        timestamp: uint256(block.timestamp)
      });
      tokenCounter[msg.sender]++;
      token.safeTransfer(msg.sender, 10**18);
    }
    
  }

  function unstake(address _staker, uint256[] calldata tokenIds) external {
    uint256 tokenId;
    totalStaked -= tokenIds.length;
      require(token.balanceOf(msg.sender) >= tokenIds.length, "not enough GODS tokens");
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      Staker memory staked = stakers[tokenId];
      require(staked.owner == msg.sender, "not an owner");
    
      delete stakers[tokenId];
      tokenCounter[msg.sender]--;
    //   emit NFTUnstaked(account, tokenId, block.timestamp);
      nft.transferFrom(address(this), _staker, tokenId);
        token.safeTransferFrom(msg.sender, address(this), 10**18);
    }
  }
  // should never be used inside of transaction because of gas fee
  function tokensOfOwner(address _account) public view returns (uint256 ownerTokenAmount) {
      return tokenCounter[_account];
  }

  function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
      require(from == address(0x0), "Cannot send nfts to Pit");
      return IERC721Receiver.onERC721Received.selector;
    }
  
}