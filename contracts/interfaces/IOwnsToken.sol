// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOwnsToken {
    event BuilderUpdated(address, address _builder);

    event BuilderLocked();

    event OwnsBurned(uint256);

    event DefaultRoyaltySet(address, uint96);
}