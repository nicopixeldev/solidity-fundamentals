// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/**
 * SafeMathTester contract demonstrates overflow and underflow handling
 * in Solidity versions before and after 0.8.0.
 * 
 * Prior to Solidity 0.8, arithmetic operations on integers (e.g., uint, int)
 * did not have built-in overflow or underflow checks by default. This meant
 * that calculations exceeding the bounds of a data type would "wrap around,"
 * potentially causing unexpected behavior in contracts. For example:
 * 
 *      uint8 max = 255;
 *      max + 1; // would wrap around to 0 in pre-0.8 versions
 * 
 * The SafeMath library was commonly used in versions <0.8 to prevent such issues
 * by explicitly reverting transactions on overflow or underflow.
 *
 * From Solidity 0.8 onward, overflow and underflow checks are built-in for
 * integers by default, making the SafeMath library largely unnecessary.
 */
contract SafeMathTester {
    // Define a uint8 variable which has a maximum value of 255
    uint8 public bigNumber = 255;

    /**
     * Adds 1 to bigNumber.
     * 
     * In Solidity versions before 0.8, this would cause an overflow,
     * wrapping bigNumber back to 0 due to lack of built-in overflow checks.
     * In Solidity 0.8+, this operation will automatically revert on overflow
     * without needing external libraries like SafeMath.
     *
     * However, we can use the "unchecked" block in Solidity 0.8+ to skip 
     * these checks for more gas-efficient code when we're confident an
     * overflow won't occur.
     */
    function add() public {
        // Uncomment the following block in Solidity 0.8+ to revert
        // to the unchecked overflow behavior of pre-0.8 versions.

        // unchecked { 
        //     bigNumber = bigNumber + 1;
        // }

        // By default in Solidity 0.8+, this addition is checked, so
        // if bigNumber is 255, this operation will revert.
        bigNumber = bigNumber + 1;
    }
}
