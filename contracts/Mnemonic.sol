// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IMnemonic } from "./interfaces/IMnemonic.sol";
import { BIP39 } from "./libs/BIP39.sol";
import { BIP39Storage } from "./libs/BIP39Storage.sol";


/// @title
contract Mnemonic is Ownable, IMnemonic {
    using BIP39Storage for BIP39Storage.Storage;

    /// @notice Storage structure holding a BIP-39 word list of 2048 words
    BIP39Storage.Storage private bip39Storage;

    /// @notice Whether Wordlist can be updated.
    bool public isSetWordListLocked;

    /**
     * @notice Allow execution only if wordlist is not locked.
     */
    modifier whenSetWordListUnlocked() {
        require(!isSetWordListLocked, 'BIP39 is locked');
        _;
    }

    constructor(address initialOwner) Ownable(initialOwner) {}

    /**
     * @notice Generate a BIP-39 mnemonic from the given seed.
     */
    function generateMnemonic(uint256 strength, bytes32 seed) public view returns (string[] memory) {
        return BIP39.generate(bip39Storage, strength, seed);
    }

    /**
     * @notice Verifies if the mnemonic is valid and returns the original entropy if correct.
     */
    function isValidMnemonic(string[] calldata words) public view returns (bytes memory) {
        return BIP39.toEntropy(bip39Storage, words);
    }

    /**
     * @notice 
     * @dev Only callable by the owner when not locked.
     */
    function setWordList(uint16 wordIndex, bytes calldata word) external onlyOwner whenSetWordListUnlocked {
        bip39Storage.setWordList(wordIndex, word);
    }

    /**
     * @notice  Registers a word in the specified index. 
     * Can be executed only before locking.
     * @dev Only callable by the owner when not locked.
     */
    function wordList(uint16 wordIndex) external view returns (string memory)  {
        return bip39Storage.wordList(wordIndex);
    }

    /**
     * @notice Retrieve a word from the index.
     */
    function indexOfWordList(string calldata word) external view returns (uint16) {
        return bip39Storage.indexOfWordList(word);
    }

    /**
     * @notice Locks the word list and permanently prohibits further changes.
     */
    function lockWordList() external onlyOwner whenSetWordListUnlocked {
        isSetWordListLocked = true;

        emit SetWordListLocked();
    }
}