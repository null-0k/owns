// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC2981 } from "@openzeppelin/contracts/token/common/ERC2981.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { IOwnsBuilder } from "./interfaces/IOwnsBuilder.sol";
import { IOwnsToken } from "./interfaces/IOwnsToken.sol";
import { Utils } from "./libs/Utils.sol";
import { ERC721A } from "erc721a/contracts/ERC721A.sol";

/// @title
contract OwnsToken is IOwnsToken, ERC721A, Ownable, ReentrancyGuard, ERC2981 {
    /// @notice OwnsBuild contract instance
    IOwnsBuilder public builder; 

    /// @notice Max supply
    uint256 public constant MAX_SUPPLY = 7777; 

    /// @notice Mint price
    uint256 public constant PRICE = 0.01 ether; 

    /// @notice Access modifier for mint function
    bool public isMintActive; 

    /// @notice Access modifier for burn function
    bool public isBurnActive; 

    /// @notice Access modifier for builder function
    bool public isBuilderLocked; 

    /// @notice Mapping of tokenId to seed
    mapping(uint256 => IOwnsBuilder.Seed) public seeds; 

    /**
     * @notice Require that the seeder has not been locked.
     */
    modifier whenBuilderNotLocked() {
        require(!isBuilderLocked, 'Builder is locked');
        _;
    }

    constructor(
        address receiver, 
        uint96 feeNumerator,
        IOwnsBuilder _builder
    ) ERC721A("Owns", "OWNS") 
      Ownable(msg.sender) { 
        _setDefaultRoyalty(receiver, feeNumerator);
        builder = _builder;
    } 

    /**
     * @notice Set the builder.
     * @dev This function can only be called by the owner.
     */
    function setBuilder(IOwnsBuilder _builder) external onlyOwner whenBuilderNotLocked {
        address oldBuilder = address(builder);
        builder = _builder;

        emit BuilderUpdated(oldBuilder, address(_builder));
    }

    /**
     * @notice Lock the builder.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockBuilder() external onlyOwner whenBuilderNotLocked {
        isBuilderLocked = true;

        emit BuilderLocked();
    }

    /**
     * @notice Securely mint the specified quantity of tokens.
     * @dev To counter reentry attacks, use ReentrancyGuard to protect 
     * against malicious duplicate calls.
     * @param quantity The number of tokens to mint.
     */
    function safeMint(uint256 quantity) external payable nonReentrant {
        require(isMintActive, "Owns Mint Not Active");
        require(totalSupply() + quantity <= MAX_SUPPLY, "Exceeds token supply");
        require(PRICE * quantity == msg.value,  "Not enough ETH sent: check price.");

        uint256 startId = _nextTokenId();
        for (uint256 i = 0; i < quantity; ++i) {
            seeds[startId + i] = builder.generateSeed(startId + i);
        }

        _safeMint(msg.sender, quantity);
    }

    /**
     * @notice Mint active status updated.
     * @dev This function can only be called by the owner.
     */
    function setMintActive(bool _val) external onlyOwner {
        isMintActive = _val;
    }

    /**
     * @notice Burn active status updated.
     * @dev This function can only be called by the owner.
     */
    function setBurnActive(bool _val) external onlyOwner {
        isBurnActive = _val;
    }

    /**
     * @notice Burn a token.
     */
    function burn(uint256 tokenId) external {
        require(isBurnActive, "Burning is not active");
        _burn(tokenId, true);

        emit OwnsBurned(tokenId);
    }

    /**
     * @notice Render the SVG for a given token.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token: URI query for nonexistent token");
        return builder.tokenURI(tokenId, seeds[tokenId]);
    }
    
    /**
     * @notice Renders base64-encoded JSON metadata for the specified token.
     */
    function generateSVGImage(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token: URI query for nonexistent token");
        return builder.generateSVGImage(seeds[tokenId]);
    }

    /**
     * @notice Render the SVG for a given token.
     */
    function svg(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token: URI query for nonexistent token");
        return builder.svg(seeds[tokenId]);
    } 

    /**
     * @notice Reset default royalties.
     * @dev This function can only be called by the owner.
     * @param receiver New royalty recipient address.
     * @param feeNumerator feeNumerator Percentage of royalties (n/10000).
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
        require(feeNumerator <= 1000, "Royalty too high");
        _setDefaultRoyalty(receiver, feeNumerator);

        emit DefaultRoyaltySet(receiver, feeNumerator);
    }

    /**
     * @notice Interface support determination.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Withdraw ether from the contract.
     * @dev This function can only be called by the owner.
     */
    function withdraw() external onlyOwner nonReentrant {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        // send ETH to msg.sender
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}
