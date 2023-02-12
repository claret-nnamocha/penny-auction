// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./AuctionItem.sol";

contract PennyAuction {
    event NewHighestBid(address bidder, uint256 bid, uint256 itemId);
    event AuctionStarted(uint256 startingBid, uint256 itemId);
    event AuctionEnded(address winner, uint256 highestBid, uint256 itemId);

    AuctionItem public auctionItem;
    mapping(uint256 => AuctionItem) public auctionItems;

    mapping(uint256 => uint256) public highestBids;
    mapping(uint256 => address) public highestBidders;
    mapping(uint256 => uint256) public biddingDeadlines;
    mapping(uint256 => uint256) public startingBids;
    mapping(uint256 => uint256) public increasingBidSizes;

    address public owner;
    uint256 public productCount = 0;

    function addProduct(AuctionItem _auctionItem, uint256 _startingBid) public {
        require(
            msg.sender == owner,
            "Only the auction owner can add a product."
        );

        auctionItems[++productCount] = _auctionItem;
        startingBids[productCount] = _startingBid;
    }

    function startAuction(uint256 itemId) public {
        require(
            msg.sender == owner,
            "Only the auction owner can start an auction."
        );
        require(
            biddingDeadlines[itemId] == 0,
            "An auction for this product is already in progress."
        );
        uint256 biddingDeadline = block.timestamp + 60;
        biddingDeadlines[itemId] = biddingDeadline;

        highestBids[itemId] = startingBids[itemId];

        emit AuctionStarted(startingBids[itemId], itemId);
    }

    function bid(uint256 itemId) public payable {
        require(msg.sender != owner, "The auction owner cannot place a bid.");

        require(
            msg.value == increasingBidSizes[itemId],
            "The bidding amount is incorrect"
        );

        require(
            block.timestamp <= biddingDeadlines[itemId],
            "The bidding deadline has passed."
        );

        uint256 _bid = highestBids[itemId] + increasingBidSizes[itemId];

        biddingDeadlines[itemId] = biddingDeadlines[itemId] + 20;

        highestBids[itemId] = _bid;
        highestBidders[itemId] = msg.sender;

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

        auctionItems[itemId].transferOwnership(highestBidders[itemId]);

        emit AuctionEnded(highestBidders[itemId], highestBids[itemId], itemId);

        biddingDeadlines[itemId] = 0;
        highestBidders[itemId] = address(0);
    }
}
