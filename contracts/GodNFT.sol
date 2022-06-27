// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./token/onft/ONFT.sol";
import "./interfaces/IGodNFT.sol";
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

}