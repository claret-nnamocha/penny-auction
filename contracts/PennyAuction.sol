// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract PennyAuction {
    event NewHighestBid(address bidder, uint256 bid, uint256 productId);

    mapping(uint256 => uint256) public highestBids;

    mapping(uint256 => address) public highestBidders;

    mapping(uint256 => uint256) public biddingDeadlines;

    mapping(uint256 => string) public productDescriptions;

    mapping(uint256 => uint256) public startingBids;

    mapping(uint256 => uint256) public increasingBidSize;

    address public owner;

    uint256 public productCount = 0;

    function addProduct(string memory _description, uint256 _startingBid)
        public
    {
        require(
            msg.sender == owner,
            "Only the auction owner can add a product."
        );

        productDescriptions[++productCount] = _description;
        startingBids[productCount] = _startingBid;
    }

    function startAuction(uint256 productId) public {
        require(
            msg.sender == owner,
            "Only the auction owner can start an auction."
        );
        require(
            biddingDeadlines[productId] == 0,
            "An auction for this product is already in progress."
        );
        uint256 biddingDeadline = block.timestamp + 60;
        biddingDeadlines[productId] = biddingDeadline;

        highestBids[productId] = startingBids[productId];
    }

    function bid(uint256 productId) public payable {
        require(msg.sender != owner, "The auction owner cannot place a bid.");

        uint256 _bid = highestBids[productId] + increasingBidSize[productId];

        require(
            _bid > highestBids[productId],
            "The bid must be higher than the current highest bid."
        );

        require(msg.value == _bid, "The bidding amount is incorrect");

        require(
            block.timestamp <= biddingDeadlines[productId],
            "The bidding deadline has passed."
        );

        biddingDeadlines[productId] = biddingDeadlines[productId] + 20;

        highestBids[productId] = _bid;
        highestBidders[productId] = msg.sender;

        emit NewHighestBid(msg.sender, _bid, productId);
    }

    function endAuction(uint256 productId) public {
        require(
            msg.sender == owner,
            "Only the auction owner can end the auction."
        );
        require(
            block.timestamp > biddingDeadlines[productId],
            "The bidding deadline has not passed."
        );

        uint256 productAmount = highestBids[productId];

        payable(highestBidders[productId]).transfer(productAmount);
        biddingDeadlines[productId] = 0;
        highestBidders[productId] = address(0);
    }

    function transferOwnership(address newOwner) public {
        require(
            msg.sender == owner,
            "Only the current owner can transfer ownership."
        );
        owner = newOwner;
    }
}
