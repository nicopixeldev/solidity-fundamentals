// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { PriceConverter } from "./PriceConverter.sol";

// Transaction gas cost before optimization: 77,2197.
// See below for the use of 'constant' and 'immutable' keywords to optimize gas costs.

error NotOwner();

contract FundMe {
    // Enables the use of functions from the PriceConverter library for all uint256 variables
    using PriceConverter for uint256;

    // Sets the minimum USD value required (5 USD represented in 18 decimal precision)
    // Using 'constant' reduces the transaction gas cost from 77,2197 to 75,1829
    // also is cheeper to read from this variable:
    // without constant = execution cost = 2446
    // with constant = execution cost = 347
    uint256 public constant MINIMUM_USD = 5e18;

    // List of addresses of the funders
    address[] public funders;

    // Mapping that associates each funder's address with the amount they have funded
    mapping(address => uint256) public addressToAmountFunded;

    // Immutable variables: set once in the constructor.
    // Using 'immutable' saves gas, as the variable is stored in the contract's bytecode rather than in storage.
    address public immutable i_owner;

    // called at deploying your contract
    constructor() {
        i_owner = msg.sender;
    }

    // The 'fund' function allows users to send funds to the contract
    function fund() public payable {        
        // Ensures that the amount sent (converted to USD) is at least the minimum required
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH");

        // Updates the total amount funded by the sender
        addressToAmountFunded[msg.sender] += msg.value;
        // Adds the sender to the list of funders
        funders.push(msg.sender);
    }

    // The 'withdraw' function allows the owner to withdraw the funds
    function withdraw() public onlyOwner {
        // Modifiers allows to do this - see onlyOwner function bellow
        // require(msg.sender == owner, "Must be the owner!");
        // Resets each funder's funded amount to zero
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // Resets the funders array
        funders = new address[](0) ; // Specifies a new empty array of addresses
        
        // Now we need to withdraw the funds from the contract

        // We can send Ether (or the native blockchain currency) using three different methods:

        // 1. TRANSFER
        // The transfer method sends a specified amount of ETH to an address.
        // The address(this).balance function returns the amount of ETH currently stored in this contract.
        // The contract holds value because it receives Ether through the fund() function.
        // Note that the transfer method is capped at 2300 gas. If an error occurs, more gas may be used,
        // and the transaction will automatically revert.
        /*
            EXAMPLE 
            payable(msg.sender).transfer(address(this).balance); // Sends the contract's balance to the owner
        */
        

        // 2. SEND
        // The send function also sends ETH to a specified address but behaves differently from transfer.
        // It does not throw an error but returns a boolean indicating whether the transfer was successful.
        // Since the send method does not revert the transaction on failure, we must manually check the result
        // and throw an error if it fails.
        /*
            EXAMPLE 
            bool sendSuccess = payable(msg.sender).send(address(this).balance);
            require(sendSuccess, "Send failed"); // Ensures the send was successful 
        */

        // 3. CALL
        // The call function is a low-level command that is incredibly powerful.
        // It allows us to call virtually any function in Ethereum without needing the ABI.
        // In this case, we use an empty string "" because we don't need to call a specific function.
        // The call function returns two values: 
        // 1. bool - indicates whether the function was successfully called
        // 2. bytes - contains the data returned by the transaction
        // Since the bytes object is an array, we need to use the 'memory' keyword.
        // Here, we are not calling any specific function, so we don't need to capture the returned data.
        /*
            EXAMPLE 
            (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
            require(callSuccess, "Call failed"); // Ensures the call was successful
        */
        // see #https://solidity-by-example.org/sending-ether/

        // call is the recommended way to send/receive tokens

        (bool callSuccess, ) = payable(msg.sender).call{ value: address(this).balance }("");
        require(callSuccess, "Call failed");
    }

    // revert => undo any actions that have been done, and send the remaining gas back
    modifier onlyOwner() {
        // Another way to optimize gas is by refining 'require' statements.
        // Each character in an error message increases storage costs, so shorter messages save gas.
        // custom errors can save more gas
        // require(msg.sender == i_owner, "Sender is not owner!");

        // Custom errors store only the error identifier and parameters, 
        // eliminating text messages and reducing gas costs compared to traditional error messages.

        // More readable error handling with revert statement.
        // require(msg.sender == i_owner, NotOwner());
        
        // More gas efficient than using require with a custom error.
        if (msg.sender != i_owner) { revert NotOwner(); }

        // The underscore (_) tells the modifier where to insert the modified function's code.
        // If the require statement passes, execution will continue at this point.
        _;
    }

    /*
        What happens if someone sends ETH to this contract without directly calling the `fund` function?
        
        If ETH is sent directly to the contract without calling `fund`, we risk losing track of who the sender is. 
        Tracking the sender is useful for various reasons, such as rewarding contributors or keeping a record of all funders.

        In Solidity, we have two special functions, `receive` and `fallback`, which handle unexpected ETH transfers:
        
        - `receive`: This function is triggered when ETH is sent directly to the contract without any data.
        Here, we call `fund` to ensure that every incoming ETH transfer is properly tracked and attributed to a sender.
        
        - `fallback`: This function is triggered when the contract is called with data that does not match any 
        existing function signature. In our case, we call `fund` here as well, so any unmatched function call 
        that includes ETH will still result in funds being tracked.

        By using `receive` and `fallback` to call `fund`, we ensure that all ETH sent to this contract is properly 
        processed, even when the transfer does not directly call the `fund` function.
    */

    receive() external payable {
        fund(); // Automatically call `fund` to track any direct ETH transfer
    }

    fallback() external payable {
        fund(); // Call `fund` for unmatched function calls that include ETH
    }

}

/* Remember:
    How Contracts Store Ether:

    Contracts can receive Ether through:
    - Fallback Functions: Executed when Ether is sent without data; accepted if the contract is payable.
    - Payable Functions: Marked as payable (like the fund function), allowing users to send Ether, accessed via msg.value.
*/
