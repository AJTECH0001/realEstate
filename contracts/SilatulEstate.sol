// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SilatuEstateInvestmentContract {
    address public owner;
    uint256 public nextTokenId = 1;
    uint256 public fractionalDecimal = 3;

    struct TokenizedAsset {
        address owner;
        uint256 totalSupply;
        uint256 remainingSupply;
        uint256 price;
        string uri;
    }

    mapping(uint256 => TokenizedAsset) public tokenizedAssets;
    mapping(address => mapping(uint256 => uint256)) public fractionalBalances;

    event AssetCreated(uint256 indexed tokenId, address indexed owner, uint256 totalSupply, uint256 price, string uri);
    event OwnershipTransferred(uint256 indexed tokenId, address indexed from, address indexed to);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createAsset(uint256 totalSupply, uint256 price, string memory uri) external onlyOwner {
        require(totalSupply > 0, "Total supply must be greater than zero");
        require(price > 0, "Price must be greater than zero");

        tokenizedAssets[nextTokenId] = TokenizedAsset({
            owner: owner,
            totalSupply: totalSupply,
            remainingSupply: totalSupply,
            price: price,
            uri: uri
        });

        nextTokenId++;

        emit AssetCreated(nextTokenId - 1, owner, totalSupply, price, uri);
    }

    function transferOwnership(uint256 tokenId, address to, uint256 amount) external {
        TokenizedAsset storage asset = tokenizedAssets[tokenId];
        require(asset.owner == msg.sender, "Only the owner can transfer ownership");
        require(amount > 0 && amount <= asset.remainingSupply, "Invalid amount to transfer");

        asset.remainingSupply -= amount;
        fractionalBalances[to][tokenId] += amount;

        emit OwnershipTransferred(tokenId, msg.sender, to);
    }

    function fractionalOwnership(uint256 tokenId, address ownerAddress) external view returns (uint256) {
        return fractionalBalances[ownerAddress][tokenId];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return tokenizedAssets[tokenId].uri;
    }
}
