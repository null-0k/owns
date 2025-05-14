// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IOwnsBuilder } from "./interfaces/IOwnsBuilder.sol";
import { IOwnsFont } from "./interfaces/IOwnsFont.sol";
import { IMnemonic } from "./interfaces/IMnemonic.sol";
import { OwnsMetadata } from "./libs/OwnsMetadata.sol";
import { OwnsRenderer } from "./libs/OwnsRenderer.sol";
import { Utils } from "./libs/Utils.sol";


/// @title
contract OwnsBuilder is Ownable, IOwnsBuilder {
    /// @notice OwnsFont contract instance
    IOwnsFont public font;

    /// @notice OwnsMnemonic contract instance
    IMnemonic public mnemonic; 

    /// @notice Access modifier for mint function
    bool public isFontLocked; 

    /// @notice Access modifier for burn function
    bool public isMnemonicLocked; 

    /**
     * @notice Require that the seeder has not been locked.
     */
    modifier whenFontNotLocked() {
        require(!isFontLocked, 'Font is locked');
        _;
    }

    /**
     * @notice Require that the seeder has not been locked.
     */
    modifier whenMnemonicNotLocked() {
        require(!isMnemonicLocked, 'Mnemonic is locked');
        _;
    }
    
    constructor(IOwnsFont _font, IMnemonic _mnemonic) Ownable(msg.sender) {
        font = _font;
        mnemonic = _mnemonic;
    }

    /**
     * @notice Set the font.
     * @dev This function can only be called by the owner.
     */
    function setFont(IOwnsFont _font) external onlyOwner whenFontNotLocked {
        address oldFont = address(font);
        font = _font;

        emit SetFontUpdated(oldFont, address(_font));
    }

    /**
     * @notice Lock the builder.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockFont() external onlyOwner whenFontNotLocked {
        require(!isFontLocked, "Already locked");
        isFontLocked = true;

        emit FontLocked();
    }

    /**
     * @notice Set the Mnemonic.
     * @dev This function can only be called by the owner.
     */
    function setMnemonic(IMnemonic _mnemonic) external onlyOwner whenMnemonicNotLocked {
        address oldMnemonic = address(mnemonic);
        mnemonic = _mnemonic;

        emit SetMnemonicUpdated(oldMnemonic, address(_mnemonic));
    }

    /**
     * @notice Lock the builder.
     * @dev This cannot be reversed and is only callable by the owner when not locked.
     */
    function lockMnemonic() external onlyOwner whenMnemonicNotLocked {
        require(!isMnemonicLocked, "Already locked");
        isMnemonicLocked = true;

        emit MnemonicLocked();
    }

    /**
     * @notice Given a token ID and seed, construct a token URI for an official Nouns DAO noun.
     * @dev The returned value may be a base64 encoded data URI or an API URL.
     */
    function tokenURI(uint256 tokenId, IOwnsBuilder.Seed memory seed) external view override returns (string memory) {
        return OwnsMetadata.tokenURI(tokenId, generateSVGParams(seed));
    }

    /**
     * @notice Given a seed, construct a base64 encoded SVG image.
     */
    function generateSVGImage(IOwnsBuilder.Seed memory seed) external view override returns (string memory) {
        return OwnsMetadata.generateSVGImage(generateSVGParams(seed));
    }

    /**
     * @notice Given a seed, Get raw svg
     */
    function svg(IOwnsBuilder.Seed memory seed) external view override returns (string memory) {
        return OwnsRenderer._generateSVG(generateSVGParams(seed));
    }

    /**
     * @notice Generates parameters necessary for SVG rendering.
     */
    function generateSVGParams(IOwnsBuilder.Seed memory seed) internal view returns (OwnsRenderer.SVGParams memory) {
        OwnsRenderer.SVGParams memory params = OwnsRenderer.SVGParams({
            letters: font.letters(),
            digits: font.digits(),
            mnemonic: mnemonic.generateMnemonic(seed.mnemonicStrength, seed.mnemonicSeed)
        });
        return params;
    }

    /**
     * @notice Generate a pseudo-random seed using the previous blockhash and tokenId.
     */
    function generateSeed(uint256 tokenId) external view override returns (Seed memory) {
        uint256 randomness    = Utils.random(tokenId);
        uint256 strengthIndex = 8;  

        return Seed({
            mnemonicSeed    : keccak256(abi.encodePacked(randomness)),
            mnemonicStrength: (Utils.random(randomness, strengthIndex) + 1) << 5 // Must be a multiple of 32 from 32 to 256
        });
    }
}
