// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;

import "../token/onft/ONFT.sol";
import "../interfaces/IGodNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GodNFT is ONFT, IGodNFT {
    uint public nextMintId;
    uint public maxSupply;
    address public managerAddress;

    modifier onlyManager() {
        require(msg.sender == managerAddress, "Only manager can call this function.");
        _;
    }

    /// @param _layerZeroEndpoint handles message transmission across chains
    constructor(address _layerZeroEndpoint, uint _maxSupply) ONFT("GodNFT", "BNFT", _layerZeroEndpoint) {
        nextMintId = 0;
        maxSupply = _maxSupply;
    }

    /// @notice Mint your ONFT
    function mintFor(address minter) external override onlyManager {
        require(nextMintId <= maxSupply, "ONFT: Max Mint limit reached");

        uint newId = nextMintId;
        nextMintId++;

        _safeMint(minter, newId);
    }

    function setManagerAddress(address _managerAddress) public onlyOwner {
        managerAddress = _managerAddress;
    }
    function getTokenList(address account) external view returns (uint256[] memory) {
        require(msg.sender != address(0));
        require(account != address(0));

        address selectedAccount = msg.sender;
        if (owner() == msg.sender)
            selectedAccount = account;

        uint256 count = balanceOf(selectedAccount);
        uint256[] memory tokenIdList = new uint256[](count);

        if (count == 0)
            return tokenIdList;

        uint256 cnt = 0;
        for (uint256 i = 1; i < (nextMintId + 1); i++) {

            if (_exists(i) && (ownerOf(i) == selectedAccount)) {
                tokenIdList[cnt++] = i;
            }

            if (cnt == count)
                break;
        }

        return tokenIdList;
    }
}