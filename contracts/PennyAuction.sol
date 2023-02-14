// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./AuctionItem.sol";

contract PennyAuction {
    event NewHighestBid(address bidder, uint256 bid, uint256 itemId);
    event AuctionStarted(uint256 itemId);
    event AuctionEnded(address winner, uint256 highestBid, uint256 itemId);

    mapping(uint256 => AuctionItem) public auctionItems;
    mapping(uint256 => uint256) public currentPrices;
    mapping(uint256 => uint256) public highestBidCounts;
    mapping(uint256 => mapping(address => uint256)) public bids;
    mapping(uint256 => address) public highestBidders;
    mapping(uint256 => bool) public activeBids; 
    mapping(uint256 => uint256) public biddingDeadlines;
    mapping(uint256 => uint256) public biddingFees;

    address public owner;
    uint256 public productCount = 0;

    constructor() {
        owner = msg.sender;
    }

    function addProduct(AuctionItem _auctionItem) public {
        require(
            msg.sender == owner,
            "Only the auction owner can add a product."
        );

        auctionItems[++productCount] = _auctionItem;
    }

    function startAuction(uint256 itemId) public {
        require(
            msg.sender == owner,
            "Only the auction owner can start an auction."
        );
        require(
            !activeBids[itemId],
            "An auction for this product is already in progress."
        );

        biddingDeadlines[itemId] = block.timestamp + 20;
        currentPrices[itemId] = 0;
        highestBidCounts[itemId] = 0;
        activeBids[itemId] = true;

        emit AuctionStarted(itemId);
    }

    function bid(uint256 itemId) public payable {
        require(msg.sender != owner, "The auction owner cannot place a bid.");

        require(
            msg.value == biddingFees[itemId],
            "The bidding amount is incorrect"
        );

        require(
            block.timestamp <= biddingDeadlines[itemId],
            "The bidding deadline has passed."
        );

        require(activeBids[itemId], "This item is not up for bidding.");

        uint256 _bid = currentPrices[itemId] + biddingFees[itemId];

        biddingDeadlines[itemId] = biddingDeadlines[itemId] + 20;

        currentPrices[itemId] = _bid;
        bids[itemId][msg.sender] += 1;

        if (highestBidCounts[itemId] < bids[itemId][msg.sender]) {
            highestBidCounts[itemId] = bids[itemId][msg.sender];
            highestBidders[itemId] = msg.sender;
        }

        emit NewHighestBid(msg.sender, _bid, itemId);
    }

    function endAuction(uint256 itemId) public {
        require(
            msg.sender == owner,
            "Only the auction owner can end the auction."
        );
        require(
            block.timestamp > biddingDeadlines[itemId],
            "The bidding deadline has not passed."
        );

        emit AuctionEnded(
            highestBidders[itemId],
            currentPrices[itemId],
            itemId
        );

        biddingDeadlines[itemId] = 0;
        activeBids[itemId] = false;
    }

    function claim(uint256 itemId) public payable {
        require(
            !activeBids[itemId] || biddingDeadlines[itemId] == 0,
            "This item is still up for bidding."
        );

        require(
            msg.sender == highestBidders[itemId],
            "You are not the winner."
        );

        require(
            msg.value == currentPrices[itemId],
            "The item amount is incorrect"
        );

        auctionItems[itemId].transferOwnership(highestBidders[itemId]);
    }
}
