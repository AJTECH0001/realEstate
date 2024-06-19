Silatu Estate Investment Contract
The Silatu Estate Investment Contract is a smart contract built on Ethereum that facilitates the tokenization of real estate assets. This contract allows for the creation of tokenized assets, transfer of fractional ownership, and retrieval of asset details, providing a decentralized and efficient way to manage real estate investments.

Features
Asset Creation: Owners can create new tokenized real estate assets with a specified total supply, price, and metadata URI.
Ownership Transfer: Owners can transfer fractional ownership of an asset to other addresses.
Querying: Users can query the fractional ownership of assets and retrieve asset metadata URIs.

Contract Overview
State Variables
owner: The address of the contract owner.
nextTokenId: Counter for the next token ID to be assigned.
fractionalDecimal: Decimal precision for fractional ownership.
tokenizedAssets: Mapping of token IDs to TokenizedAsset structures.
fractionalBalances: Nested mapping tracking fractional ownership by address.

Token Issuance
Token issuance involves creating a new tokenized asset and making it available for fractional ownership.

Function: createAsset
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

Purpose: This function allows the contract owner to create a new tokenized asset.
Parameters:
totalSupply: Total number of fractions available for the asset.
price: The price per fraction.
uri: Metadata URI for the asset.
Process: The function stores the asset details in the tokenizedAssets mapping and increments the nextTokenId.


Ownership Transfer
Ownership transfer allows the current owner to transfer fractional ownership of an asset to another address.

Function: transferOwnership

function transferOwnership(uint256 tokenId, address to, uint256 amount) external {
    TokenizedAsset storage asset = tokenizedAssets[tokenId];
    require(asset.owner == msg.sender, "Only the owner can transfer ownership");
    require(amount > 0 && amount <= asset.remainingSupply, "Invalid amount to transfer");

    asset.remainingSupply -= amount;
    fractionalBalances[to][tokenId] += amount;

    emit OwnershipTransferred(tokenId, msg.sender, to);
}

Purpose: This function allows the asset owner to transfer fractional ownership to another address.
Parameters:
tokenId: The ID of the asset.
to: The recipient address.
amount: The amount of ownership being transferred.
Process: The function checks if the caller is the asset owner and ensures the amount is valid. It then updates the remainingSupply and fractionalBalances.

Dividend Distribution
Dividend distribution allows the owner to distribute earnings generated from the real estate assets to fractional owners.

New Function: distributeDividends

To implement dividend distribution, you need to add a function that allows the owner to distribute Ether proportionally to fractional owners.

event DividendDistributed(uint256 indexed tokenId, uint256 amount);

function distributeDividends(uint256 tokenId) external payable onlyOwner {
    TokenizedAsset storage asset = tokenizedAssets[tokenId];
    uint256 totalSupply = asset.totalSupply;
    uint256 dividendPerFraction = msg.value / totalSupply;

    for (uint256 i = 0; i < totalSupply; i++) {
        address owner = fractionalBalances[i][tokenId];
        uint256 ownerBalance = fractionalBalances[owner][tokenId];
        uint256 dividend = ownerBalance * dividendPerFraction;
        payable(owner).transfer(dividend);
    }

    emit DividendDistributed(tokenId, msg.value);
}


Purpose: This function distributes Ether dividends to all fractional owners of a specific asset.
Parameters:
tokenId: The ID of the asset.
msg.value: The total amount of Ether to distribute.
Process: The function calculates the dividend per fraction and transfers the corresponding amount to each fractional owner.

Buyback Mechanisms
Buyback mechanisms allow the contract owner or asset owner to buy back fractions of the asset from current holders.

New Function: buyBackTokens

To implement a buyback mechanism, you can add a function that allows the owner to buy back fractions from holders at a specified price.

event TokensBoughtBack(uint256 indexed tokenId, address indexed from, uint256 amount, uint256 price);

function buyBackTokens(uint256 tokenId, address from, uint256 amount, uint256 price) external payable onlyOwner {
    TokenizedAsset storage asset = tokenizedAssets[tokenId];
    require(msg.value == amount * price, "Incorrect Ether sent for buyback");

    uint256 ownerBalance = fractionalBalances[from][tokenId];
    require(ownerBalance >= amount, "Insufficient balance to buy back");

    fractionalBalances[from][tokenId] -= amount;
    asset.remainingSupply += amount;
    payable(from).transfer(msg.value);

    emit TokensBoughtBack(tokenId, from, amount, price);
}

Purpose: This function allows the contract owner to buy back fractions from current holders.
Parameters:
tokenId: The ID of the asset.
from: The address from which fractions are bought back.
amount: The amount of ownership being bought back.
price: The price per fraction for the buyback.
Process: The function verifies the amount and Ether sent, updates the remainingSupply and fractionalBalances, and transfers Ether to the seller.
