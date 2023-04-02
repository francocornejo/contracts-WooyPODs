// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract WOOYPODs is ERC721, ERC721URIStorage, Pausable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721("WOOYPODs", "WYP") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    mapping(bytes32 => uint256) private userToken;
    mapping(bytes32 => bool) private alreadyMinted;

    function safeMint(address to, string memory uri, bytes32 userTokenValue) public onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(userTokenValue.length > 0, "User token value can't be empty");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _tokenURIs[tokenId] = uri;
        userToken[userTokenValue] = tokenId;
        alreadyMinted[userTokenValue] = true;
    }

    function getTokenIdByUserToken(bytes32 userTokenValue) public view returns (uint256) {
        require(userTokenValue != "", "User token value cannot be empty");
        require(alreadyMinted[userTokenValue] == true, "User token value not found");
        return userToken[userTokenValue];
    }

    function tokenURI(uint256 tokenId) 
        public 
        view 
        override(ERC721, ERC721URIStorage)
        returns (string memory) {
        require(_exists(tokenId), "Token ID does not exist");
        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        } else {
            return super.tokenURI(tokenId);
        }
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}