// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.4;

import "./GODtoken.sol";
import "./GodNFT.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract NFTStaker is Ownable, IERC721Receiver {
using SafeERC20 for IERC20;

  uint256 public totalStaked;
  IERC20 token;
  IERC721 nft;

 // struct to store a stake's token, owner, and earning values
  struct Staker {
    uint256 timestamp;
    address owner;
  }

  mapping(uint256 => Staker) public stakers; 
  // Enumeration
  mapping(address => mapping(uint256 => uint256)) public ownedStakes; // (address, index) => tokenid
  mapping(uint256 => uint256) public ownedStakesIndex; // tokenId => index in its owner's stake list
  mapping (address => uint256) public ownedStakesBalance;

   constructor(address _nft, address _token) { 
    nft = IERC721(_nft);
    token = IERC20(_token);
  }

   receive() external payable {}

  function stake(uint256[] calldata tokenIds) external {
    uint256 tokenId;
    address _owner = msg.sender;
    totalStaked += tokenIds.length;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      require(nft.ownerOf(tokenId) == msg.sender, "not your token");
      require(stakers[tokenId].timestamp == 0, "already staked");

      stakers[tokenId] = Staker({
        owner: _owner,
        timestamp: uint256(block.timestamp)
      });
      
      uint256 length = ownedStakesBalance[_owner];
      ownedStakes[_owner][length] = tokenId;
      ownedStakesIndex[tokenId] = length;
      ownedStakesBalance[_owner]++;
      
      nft.transferFrom(msg.sender, address(this), tokenId);
      token.safeTransfer(msg.sender, 1);
    }
  }

  function unstake(address _staker, uint256[] calldata tokenIds) external {
    uint256 tokenId;
    address _owner = msg.sender;
    totalStaked -= tokenIds.length;
      require(token.balanceOf(msg.sender) >= tokenIds.length, "not enough GODS tokens");
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      Staker memory staked = stakers[tokenId];
      require(staked.owner == msg.sender, "not an owner");
    
      delete stakers[tokenId];

      uint256 lastTokenIndex = ownedStakesBalance[_owner] - 1;
      uint256 tokenIndex = ownedStakesIndex[tokenId];

      if (tokenIndex != lastTokenIndex) {
          uint256 lastTokenId = ownedStakes[_owner][lastTokenIndex];
          ownedStakes[_owner][tokenIndex] = lastTokenId;
          ownedStakesIndex[lastTokenId] = tokenIndex;
      }

      delete ownedStakesIndex[tokenId];
      delete ownedStakes[_owner][lastTokenIndex];

      ownedStakesBalance[msg.sender]--;
      nft.transferFrom(address(this), _staker, tokenId);
      token.safeTransferFrom(msg.sender, address(this), 1);
    }
  }

  // should never be used inside of transaction because of gas fee
  function batchedStakesOfOwner(
      address _owner,
      uint256 _offset,
      uint256 _maxSize
  ) public view returns (uint256[] memory) {
      if (_offset >= ownedStakesBalance[_owner]) {
          return new uint256[](0);
      }

      uint256 outputSize = _maxSize;
      if (_offset + _maxSize >= ownedStakesBalance[_owner]) {
          outputSize = ownedStakesBalance[_owner] - _offset;
      }
      uint256[] memory outputs = new uint256[](outputSize);

      for (uint256 i = 0; i < outputSize; i++) {
          uint256 tokenId = ownedStakes[_owner][_offset + i];
          outputs[i] = tokenId;
      }
      return outputs;
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