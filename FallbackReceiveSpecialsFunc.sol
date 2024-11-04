// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Special functions in Solidity are designed to handle specific scenarios for receiving Ether.
contract FallbackExample {
    uint256 public result;

    // The receive function does not require the function keyword, as it is a special function.
    // This function is triggered whenever Ether is sent to the contract without accompanying data.
    // It will be called if the calldata associated with the transaction is empty.
    receive() external payable {
        result = 1;
    }

    // The fallback function is executed when no other functions match the provided calldata.
    fallback() external payable {
        result = 2;
    }
}

// Explainer from: https://solidity-by-example.org/fallback/
// Ether is sent to contract
//      Is msg.data empty?
//          /   \
//         yes  no
//         /     \
//    Call receive()?  Call fallback()
//     /   \
//   yes   no
//  /        \
//Call receive()  Call fallback()
