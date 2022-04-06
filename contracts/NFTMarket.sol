// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 iteamId;
        address nftContractAddress;
        address payable owner;
        address payable seller;
        uint256 tokenId;
        uint256 price;
        bool sold;
    }

    // market item id ==> market item
    mapping(uint256 => MarketItem) private idToMarketitem;

    event CreateMarketItem(
        uint256 indexed itemId,
        address indexed nftContractAddress,
        uint256 indexed tokenId,
        uint256 price,
        address owner,
        address seller,
        bool sold
    );

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // create an item on market
    function createMarketItem(
        address _nftContractAddress,
        uint256 _tokenId,
        uint256 _price
    ) public payable nonReentrant {
        require(_price > 0, "Prices must be at lease 1 wei");
        require(
            msg.value == listingPrice,
            "Price is must be equal to listing price"
        );

        _itemIds.increment();
        uint256 newItemId = _itemIds.current();

        idToMarketitem[newItemId] = MarketItem(
            newItemId,
            _nftContractAddress,
            payable(address(this)),
            payable(msg.sender),
            _tokenId,
            _price,
            false
        );

        IERC721(_nftContractAddress).transferFrom(
            msg.sender,
            address(this),
            newItemId
        );

        emit CreateMarketItem(
            newItemId,
            _nftContractAddress,
            _tokenId,
            _price,
            address(this),
            msg.sender,
            false
        );
    }

    // sell item
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
    {
        uint256 price = idToMarketitem[itemId].price;
        uint256 tokenId = idToMarketitem[itemId].tokenId;
        address payable seller = idToMarketitem[itemId].seller;

        bool sold = idToMarketitem[itemId].sold;

        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );

        require(!sold, "Item was sold");

        idToMarketitem[itemId].owner = payable(msg.sender);
        idToMarketitem[itemId].sold = true;
        idToMarketitem[itemId].seller = payable(address(0));
        _itemsSold.increment();

        seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
    }

    // return all unsold market items
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _itemIds.current();
        uint256 unSoldItemCount = _itemIds.current() - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unSoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idToMarketitem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;
                MarketItem storage currnetItem = idToMarketitem[currentId];
                items[currentIndex] = currnetItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    // return items that a user has purchased
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemIds.current();
        uint256 itemsCount = 0;
        uint256 currnetIndex = 0;

        for (uint256 i = 0; i < totalItems; i++) {
            if (idToMarketitem[i + 1].owner == msg.sender) {
                itemsCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemsCount);

        for (uint256 i = 0; i < totalItems; i++) {
            if (idToMarketitem[i + 1].owner == msg.sender) {
                uint256 currnetId = i + 1;
                MarketItem storage currentItem = idToMarketitem[currnetId];
                items[currnetIndex] = currentItem;
                currnetIndex += 1;
            }
        }

        return items;
    }

    // return items a user has listed
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint256 totalItems = _itemIds.current();
        uint256 itemsCount = 0;
        uint256 currnetIndex = 0;

        for (uint256 i = 0; i < totalItems; i++) {
            if (idToMarketitem[i + 1].seller == msg.sender) {
                itemsCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemsCount);

        for (uint256 i = 0; i < totalItems; i++) {
            if (idToMarketitem[i + 1].seller == msg.sender) {
                uint256 currnetId = i + 1;
                MarketItem storage currentItem = idToMarketitem[currnetId];
                items[currnetIndex] = currentItem;
                currnetIndex += 1;
            }
        }

        return items;
    }
}
