// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

/**
 * @title Math
 * @dev Library providing mathematical functions.
 */
library Math {
    /**
     * @dev Calculates the percentage of a number with a given percentage value and decimals.
     * @param base_number The base number to calculate the percentage of.
     * @param percentage_value The percentage value to apply.
     * @param decimals The number of decimals for precision in calculations.
     * @return result The calculated result after applying the percentage.
     */
    function pc(uint256 base_number, uint64 percentage_value, uint8 decimals) internal pure returns (uint256 result) {
        uint256 _decimalScalingFactor = 10**decimals;
        result = (((percentage_value * _decimalScalingFactor) / 100) * base_number) / _decimalScalingFactor;
        return result;
    }

    function getDaysDifference(uint256 timestamp1, uint256 timestamp2) internal pure returns (uint256) {
        require(timestamp1 <= timestamp2, "Invalid timestamps order");
        
        // Calculate the difference in seconds
        uint256 timeDifference = timestamp2 - timestamp1;
        
        // Convert seconds to days
        uint256 daysDifference = timeDifference / 1 days;
        
        return daysDifference;
    }

    function getYearsDifference(uint256 timestamp1, uint256 timestamp2) internal pure returns (uint256) {
        require(timestamp1 <= timestamp2, "Invalid timestamps order");
        
        // Calculate the difference in seconds
        uint256 timeDifference = timestamp2 - timestamp1;
        
        // Convert seconds to years
        uint256 yearsDifference = timeDifference / (365 days);
        
        return yearsDifference;
    }
}
