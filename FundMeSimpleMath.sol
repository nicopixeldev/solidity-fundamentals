// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    // Sets the minimum USD value represented in 18 decimal precision (equivalent to 5 USD with 18 decimals)
    // 5e18 = 5 * (10 ** 18) = 5 * 1e18;
    uint256 public minimumUsd = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    // msg.value => globals 
    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent $5
        // msg.value is in terms of eth and minimumUsd are dollars - we need convert eth to USD
        // we need an Oracle -> https://data.chain.link/feeds/ethereum/mainnet/eth-usd
        require(getConversionRate(msg.value) >= minimumUsd, "didn't send enough ETH");
        // addressToAmountFunded[msg.sender] + msg.value; previosly added plus the new amount
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // In order to interact with the smart contracts we always need:
        // 1. Address - 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // 2. ABI (Application Binary Interface) - standardized interface for describing contract functionality, variables, and events
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 answer,,,) = priceFeed.latestRoundData();

        // 'answer' represents the price of ETH in USD terms.
        // Typically, 'answer' is a large integer, like 200000000000, since Solidity does not support floating-point numbers.
        // We can use the .decimals() method to confirm the number of decimals provided by the oracle.

        // msg.value represents the amount of ETH sent in the transaction, denominated in Wei.
        // Wei is the smallest unit of ETH, so 1 ETH is equivalent to 1,000,000,000,000,000,000 Wei, giving msg.value 18 decimal places.

        // By contrast, 'answer' has 8 decimal places to represent USD values (e.g., 2000.00000000).
        // To align 'answer' with the 18-decimal format of msg.value, we multiply 'answer' by 10^10 (1e10).
        // This operation shifts 'answer' from 8 decimals to 18 decimals, matching msg.value for accurate calculations.

        // Additionally, msg.value and answer are different types (uint256 vs int256), requiring type casting for compatibility.

        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        // Fetches the current price of 1 ETH in USD with 18 decimal places.
        // Example: if 1 ETH = $2000, ethPrice might return 2000_000000000000000000.
        uint256 ethPrice = getPrice();

        // To maintain precision when multiplying in Solidity, it’s important to multiply before dividing.
        // Here, we calculate the value of `ethAmount` in USD by multiplying `ethPrice` and `ethAmount`.
        // The result will have 36 decimal places (18 from ethPrice and 18 from ethAmount),
        // so we divide by 1e18 to scale it back to 18 decimals, matching standard USD formatting.
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        
        // Returns the USD equivalent of `ethAmount` in 18 decimal format.
        return ethAmountInUsd;
    }
}