// SPDX-License-Identifier: MIT
pragma solidity 0.8.8; // If we put ^ it will take everything above as well; we can use >= <= as well

import "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__InsufficientAmount();
error FundMe__WithdrawError();

/**
 * @title A contract for crowd funding
 * @author Boris Kolev
 * @notice This contract is to demo a sample fund me contract
 * @dev This implements price feeds as a library
 */
contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address public immutable owner;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    AggregatorV3Interface public priceFeed;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert FundMe__NotOwner();
        }
        // equire(msg.sender == i_owner, "Sender is not owner!");
        _; // run the rest of the funciton
    }

    constructor(address priceFeedAddress) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * @notice This function funds the contract
     * @dev This implements price feeds as a library
     */
    function fund() public payable {
        if (msg.value.getConversionRate(priceFeed) < MINIMUM_USD) {
            revert FundMe__InsufficientAmount();
        }
        // require(msg.value.getConversionRate() > MINIMUM_USD, "Did not send enough money!");
        funders.push(msg.sender); // Add all funders to our contract
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        if (!callSuccess) {
            revert FundMe__WithdrawError();
        }
    }
}
