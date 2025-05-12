// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOwnsFont {
    struct Trait {
        address[] pages;   
        uint256  totalBytes; 
    }

    function lettersCount() external view returns (uint256);

    function digitsCount() external view returns (uint256);

    function letters() external view returns (bytes memory);

    function digits() external view returns (bytes memory);

    function addLetters(bytes calldata data) external;

    function addDigits(bytes calldata data) external;

    function addLettersFromPointer(address pointer, uint256 len) external;

    function addDigitsFromPointer(address pointer, uint256 len) external;

    event LettersPageAdded(uint256 indexed pageIndex, uint256 totalBytes);

    event DigitsPageAdded(uint256 indexed pageIndex, uint256 totalBytes);
 
    error EmptyBytes();

    error ZeroPinter();

    error BadLength();
}