// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITranzitRouter {
    
    function getProtocolFee() external pure returns (uint256);
}