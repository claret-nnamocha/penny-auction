// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AuctionItem is ERC721 {
    uint256 public itemId;
    string public itemName;
    string public itemDescription;
    uint256 public startingBid;
    address public owner;

    constructor(
        uint256 _itemId,
        string memory _itemName,
        string memory _itemDescription,
        uint256 _startingBid
    ) ERC721(_itemName, string.concat("AUCITEM ", Strings.toString(_itemId))) {
        itemId = _itemId;
        itemName = _itemName;
        itemDescription = _itemDescription;
        startingBid = _startingBid;
        owner = msg.sender;
        _mint(owner, itemId);
    }

    function transferOwnership(address newOwner) public {
        require(
            msg.sender == owner,
            "Only the current owner can transfer ownership."
        );
        owner = newOwner;
    }
}
