// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { SSTORE2 } from "./SSTORE2.sol";
                                   
/**
 * 
 * ██████╗ ██╗██████╗ ██████╗  █████╗ 
 * ██╔══██╗██║██╔══██╗╚════██╗██╔══██╗
 * ██████╔╝██║██████╔╝ █████╔╝╚██████║
 * ██╔══██╗██║██╔═══╝  ╚═══██╗ ╚═══██║
 * ██████╔╝██║██║     ██████╔╝ █████╔╝
 * ╚═════╝ ╚═╝╚═╝     ╚═════╝  ╚════╝ 
 * 
 * @title BIP-39 Mnemonic Word-List Storage Library.
 */
library BIP39Storage {
    error WordIndexOutOfRange(uint16 wordIndex);

    error EmptyWord();

    event WordListSet(uint16 wordIndex, bytes word);

    error NotFoundWord();

    struct Storage {
        mapping(uint16 => address) mnemonicPointers;
        mapping(bytes => uint16) mnemonicIndexes;
    } 

    /**
     * @notice Register/overwrite words in the specified index.
     * @param self Storage references on which the library operates
     * @param wordIndex Index of Registered Locations (0-2047)
     * @param word  UTF-8 byte sequence of the word
     */
    function setWordList(Storage storage self, uint16 wordIndex, bytes calldata word) internal {
        if (wordIndex >= 2048) {
            revert WordIndexOutOfRange(wordIndex);
        }
        if (word.length == 0) {
            revert EmptyWord();
        }
        self.mnemonicPointers[wordIndex] = SSTORE2.write(word);
        self.mnemonicIndexes[word] = wordIndex;

        emit WordListSet(wordIndex, word);
    }

    /**
     * @notice Retrieve a word from the index.
     * @param self Storage Reference
     * @param wordIndex Index of the word you want to retrieve
     */
    function wordList(Storage storage self, uint16 wordIndex) internal view returns (string memory) {
        address pointer = self.mnemonicPointers[wordIndex];
        if (pointer == address(0)) {
            revert NotFoundWord();
        }
        return string(SSTORE2.read(pointer));
    }

    /**
     * @notice Search the index by word.
     * @param self Storage Reference
     * @param word The word you want to search for (UTF-8)
     */
    function indexOfWordList(Storage storage self, string calldata word) internal view returns (uint16) {
        bytes memory w = bytes(word);
        if (w.length == 0) revert EmptyWord();
        uint16 idx = self.mnemonicIndexes[w];

        address ptr = self.mnemonicPointers[idx];
        if (ptr == address(0) || keccak256(SSTORE2.read(ptr)) != keccak256(w)) {
            revert NotFoundWord();
        }
        return idx;
    }
}