// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOwnsBuilder {
    struct Seed {
        bytes32 mnemonicSeed;
        uint256 mnemonicStrength;
    }

    event SetFontUpdated(address, address);

    event FontLocked();

    event SetMnemonicUpdated(address, address);

    event MnemonicLocked();

    event BIP39Updated(address, address);

    function tokenURI(uint256 tokenId, IOwnsBuilder.Seed memory seed) external view returns (string memory);

    function generateSVGImage(IOwnsBuilder.Seed memory seed) external view returns (string memory);

    function svg(IOwnsBuilder.Seed memory seed) external view returns (string memory);

    function generateSeed(uint256 tokenId) external view returns (Seed memory);
}