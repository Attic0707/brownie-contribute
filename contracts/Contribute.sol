// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract Contribute {
    address public owner;
    address[] public funders;
    mapping(address => uint256) public amountPerAddress;
    mapping(uint256 => bool) public uniqueCheck;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    struct Item {
        uint256 id;
        string itemName;
        bool unique;
        address ownerAddress;
    }

    Item[] public items;

    function addItem(
        uint256 _id,
        string memory _itemName,
        bool _unique,
        address _ownerAddress
    ) public {
        items.push(
            Item({
                id: _id,
                itemName: _itemName,
                unique: _unique,
                ownerAddress: _ownerAddress
            })
        );
        uniqueCheck[_id] = _unique;
    }

    function transferItem(
        uint256 _id,
        address fromAdd,
        address toAdd,
        bool confirm
    ) public view {
        if (confirm) {
            for (uint256 itemIndex = 0; itemIndex < items.length; itemIndex++) {
                if (items[itemIndex].id == _id) {
                    fromAdd = toAdd;
                }
            }
        }
    }

    function contribute() public payable {
        uint256 minimumUSD = 50 * 10**18;
        require(getConversionRate(msg.value) >= minimumUSD, "Yetersiz bakiye");
        amountPerAddress[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getETHPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    function getETHPrice() public view returns (uint256) {
        (, int256 result, , , ) = priceFeed.latestRoundData();
        return uint256(result * 10000000000);
    }

    function getBTCPrice() public view returns (uint256) {
        (, int256 result, , , ) = priceFeed.latestRoundData();
        return uint256(result * 10000000000);
    }

    function getForBTC(uint256 btcAmount) public view returns (uint256) {
        uint256 currentBTC = getBTCPrice();
        uint256 btcAmountInUsd = (btcAmount * currentBTC) / 1000000000000000000;
        return btcAmountInUsd;
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 currentEth = getETHPrice();
        uint256 ethAmountInUsd = (ethAmount * currentEth) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function withdraw() public payable onlyOwner {
        // msg.sender.transfer(address(this).balance);
        payable(msg.sender).transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            amountPerAddress[funder] = 0;
        }
        funders = new address[](0);
    }
}
